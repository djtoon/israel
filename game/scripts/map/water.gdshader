shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx, depth_draw_always;

#include "res://scripts/map/hexcommon.gdshaderinc"

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D wave_n1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D wave_n2 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform vec3 shallow_col : source_color = vec3(0.10, 0.78, 0.74);
uniform vec3 mid_col : source_color = vec3(0.0, 0.40, 0.66);
uniform vec3 deep_col : source_color = vec3(0.0, 0.10, 0.36);
uniform float grid_alpha = 0.07;
uniform vec3 border_color : source_color = vec3(1.0, 0.78, 0.30);
global uniform float dn_night;   // v5 day / night (daynight.gd): 0 by day
global uniform vec4 dn_sea;      // v5: rgb = the sea's colour x (1 by day; a cooler, dimmer mint-blue at dawn), a = its sky reflection x

varying vec3 wpos;

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME;
	float wave = sin(w.x * 1.3 + t * 0.9) * 0.008 + sin(w.z * 1.7 - t * 1.1 + w.x * 0.4) * 0.006;
	VERTEX.y += wave;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// seabed height is known analytically (same function as the terrain shader)
	float bed_h = terrain_height(wpos.xz);
	float depth = max(0.0, wpos.y - bed_h);
	vec3 vdir = normalize(wpos - CAMERA_POSITION_WORLD);
	float vdist = depth / max(0.2, abs(vdir.y));
	vec2 p = wpos.xz;
	float t = TIME;
	// colour by depth
	float k1 = 1.0 - exp(-depth * 6.5);
	float k2 = 1.0 - exp(-depth * 2.6);
	vec3 wcol = mix(shallow_col, mid_col, k1);
	wcol = mix(wcol, deep_col, k2);
	// subtle large-scale variation
	wcol *= 0.92 + 0.16 * vnoise(p * 0.25 + t * 0.01);

	// refraction / transparency in the shallows
	vec3 n1 = texture(wave_n1, p * 0.22 + vec2(t * 0.012, t * 0.007)).rgb;
	vec3 n2 = texture(wave_n2, p * 0.37 - vec2(t * 0.009, -t * 0.013)).rgb;
	vec3 nm = normalize(mix(n1, n2, 0.5) * 2.0 - 1.0);
	vec2 ruv = SCREEN_UV + nm.xy * 0.006 * clamp(depth * 6.0, 0.0, 1.0);
	vec3 under = textureLod(screen_tex, ruv, 0.0).rgb;
	float clarity = exp(-vdist * 14.0);
	vec3 col = mix(wcol, under * mix(vec3(1.0), shallow_col * 1.25, 0.55), clarity * 0.85);

	// shoreline foam: thin band at contact + animated surf lines
	float fn = vnoise(p * 6.0 + vec2(t * 0.25, -t * 0.18));
	float contact = 1.0 - smoothstep(0.0, 0.018 + 0.02 * fn, depth);
	float bands = smoothstep(0.65, 0.95, sin(depth * 70.0 - t * 1.6 + fn * 4.0) * 0.5 + 0.5);
	float surf = bands * (1.0 - smoothstep(0.015, 0.06, depth)) * smoothstep(0.3, 0.65, fn);
	float surf2 = smoothstep(0.55, 0.9, vnoise(p * vec2(14.0, 4.0) + vec2(-t * 0.4, t * 0.2))) * (1.0 - smoothstep(0.01, 0.05, depth));
	float foam = clamp(contact + surf * 0.75 + surf2 * 0.35, 0.0, 1.0);
	// sparse small whitecaps far out
	float cap = smoothstep(0.90, 0.97, vnoise(p * vec2(7.0, 11.0) + vec2(t * 0.3, 0.0))) * smoothstep(0.55, 0.8, vnoise(p * 0.6 + 3.0)) * k2;
	foam = max(foam, cap * 0.45);
	// wave crest shading so open water is not flat
	float crest = clamp(nm.x * 0.6 + nm.y * 0.4, -1.0, 1.0);
	col *= 0.9 + 0.25 * crest;
	col *= 1.0 - 0.3 * dn_night;   // v5: a deeper, moonlit navy at night
	col *= dn_sea.rgb;
	col = mix(col, vec3(0.97, 0.98, 1.0), foam * 0.92);

	// hex grid lines on water
	ivec2 cell; int edir;
	float ed = hex_edge_dist(p, cell, edir);
	float px = fwidth(ed);
	float grid = 1.0 - smoothstep(0.0, max(0.012, px * 1.2), ed);
	col = mix(col, mix(col, vec3(0.85, 0.95, 1.0), 0.6), grid * grid_alpha * 2.0);

	vec3 emis = vec3(0.0);
	ivec2 off = axial_to_offset(cell);
	int own = hex_info(off).b;
	if (own > 0) {
		ivec2 noff = axial_to_offset(cell + AX_DIRS[edir]);
		int nown = in_map(noff) ? hex_info(noff).b : own;
		// only land-to-land borders (lake hexes count as land); never along the sea coast
		bool sea_here = hex_info(off).r <= 1;
		bool sea_there = !in_map(noff) || hex_info(noff).r <= 1;
		if ((nown > 0) != (own > 0) && !sea_here && !sea_there) {
			float line = 1.0 - smoothstep(0.012, 0.03 + px, abs(ed - 0.045));
			col = mix(col, border_color, line * 0.95);
			emis += border_color * line * 0.35;
		}
	}

	ALBEDO = col;
	EMISSION = emis;
	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), nm * 0.5 + 0.5, 1.0 - foam);
	NORMAL_MAP_DEPTH = 0.5;
	ROUGHNESS = mix(0.12, 0.6, foam);
	METALLIC = 0.0;
	SPECULAR = 0.12 * dn_sea.a;
	ALPHA = 1.0;
}
