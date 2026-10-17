shader_type spatial;
// HD-mode sea (HDRender swaps it in for water.gdshader). Same uniforms, waves, grid and borders as SD, plus:
// two-scale ripple normals with sun sparkle, sky reflection (engine radiance + fresnel), depth colour from turquoise
// shallows to deep navy, refraction where the lit seabed is passed through as emission (no double lighting),
// visible reef rocks, and broken shoreline foam lines that also wrap the rocks.
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx, depth_draw_always;

#include "res://scripts/map/hexcommon.gdshaderinc"
#include "res://scripts/map/hdplus.gdshaderinc"

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D wave_n1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D wave_n2 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D ripple_n : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 shallow_col : source_color = vec3(0.18, 0.78, 0.76);
uniform vec3 mid_col : source_color = vec3(0.02, 0.46, 0.64);
uniform vec3 deep_col : source_color = vec3(0.01, 0.11, 0.36);
uniform float grid_alpha = 0.07;
uniform vec3 border_color : source_color = vec3(1.0, 0.78, 0.30);
// v5 day / night (daynight.gd): the glitter path's colour and strength (sun by day, gold at sunset, the moon at night)
// and the town lights reflected on the water next to lit coastal towns
global uniform vec4 dn_glint;
global uniform float dn_lights;
global uniform float dn_night;

varying vec3 wpos;

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME;
	float wave = sin(w.x * 1.3 + t * 0.9) * 0.008 + sin(w.z * 1.7 - t * 1.1 + w.x * 0.4) * 0.006;
	VERTEX.y += wave;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float bed_h = terrain_height(wpos.xz);
	float depth = max(0.0, wpos.y - bed_h);
	vec3 vdir = normalize(wpos - CAMERA_POSITION_WORLD);
	float vdist = depth / max(0.2, abs(vdir.y));
	float cam_d = length(wpos - CAMERA_POSITION_WORLD);
	vec2 p = wpos.xz;
	float t = TIME;

	// ---- normals: broad swell (noise maps) + fine ripples (generated periodic-wave map, two directions)
	vec3 n1 = texture(wave_n1, p * 0.22 + vec2(t * 0.012, t * 0.007)).rgb * 2.0 - 1.0;
	vec3 n2 = texture(wave_n2, p * 0.37 - vec2(t * 0.009, -t * 0.013)).rgb * 2.0 - 1.0;
	vec3 r1 = texture(ripple_n, p * 1.35 + vec2(t * 0.035, t * 0.018)).rgb * 2.0 - 1.0;
	vec3 r2 = texture(ripple_n, p * vec2(2.3, 2.0) + vec2(-t * 0.028, t * 0.04) + 0.37).rgb * 2.0 - 1.0;
	float fine = 1.0 - smoothstep(10.0, 30.0, cam_d);          // fade fine ripples with distance (no shimmer)
	vec2 sl = (n1.xy + n2.xy) * 0.5 + (r1.xy + r2.xy) * 0.3 * (0.4 + 0.6 * fine);
	vec3 nm = normalize(vec3(sl, 1.0));

	// ---- colour by depth: turquoise shallows -> teal -> deep navy, with slow large-scale variation
	// a broad teal shallow band (the shelf), then a steeper drop to navy
	float k1 = 1.0 - exp(-depth * 9.0);
	float k2 = 1.0 - exp(-depth * 3.8);
	vec3 wcol = mix(shallow_col, mid_col, k1);
	wcol = mix(wcol, deep_col, k2);
	wcol *= 0.9 + 0.2 * vnoise(p * 0.25 + t * 0.01);
	// far sea: large, slow patches of lighter / darker / greener water and wind streaks (not one flat navy)
	float big = fbm(p * 0.07 + vec2(t * 0.002, 0.0));
	wcol *= mix(1.0, 0.78 + 0.45 * big, k2);
	wcol = mix(wcol, wcol * vec3(0.75, 1.12, 1.08), smoothstep(0.45, 0.7, fbm(p * 0.16 + 9.0)) * k2 * 0.55);
	vec2 wp = mat2(vec2(0.94, 0.34), vec2(-0.34, 0.94)) * p;
	float streak = smoothstep(0.45, 0.85, vnoise(wp * vec2(0.5, 7.0) + vec2(t * 0.03, 0.0))) * smoothstep(0.3, 0.7, vnoise(p * 0.4 + 5.0));
	wcol *= mix(1.0, 1.0 + 0.22 * streak, k2);

	// ---- refraction: the lit seabed through the water, absorbed toward blue-green with the optical path
	vec2 ruv = SCREEN_UV + nm.xy * 0.008 * clamp(depth * 6.0, 0.0, 1.0);
	vec3 under = textureLod(screen_tex, ruv, 0.0).rgb;
	vec3 absorb = exp(-vdist * vec3(14.0, 4.0, 3.2));               // red goes first: turquoise tint
	float clarity = exp(-vdist * 7.0);
	vec3 trans = under * absorb * clarity;

	// ---- foam, in world distance from the waterline (depth / bed slope), so its width does not depend on how gently
	// the seabed shelves: a broken contact band, surf lines rolling in, and foam wrapping the reef rocks
	float fn = vnoise(p * 6.0 + vec2(t * 0.25, -t * 0.18));
	float fn2 = vnoise(p * vec2(18.0, 7.0) + vec2(-t * 0.5, t * 0.3));
	float sd = 1.0;
	if (depth < 0.12) {
		float e = 0.04;
		vec2 grad = vec2(terrain_height(p + vec2(e, 0.0)) - bed_h, terrain_height(p + vec2(0.0, e)) - bed_h) / e;
		sd = depth / max(length(grad), 0.03);
	}
	float lace = smoothstep(0.3, 0.75, vnoise(p * 24.0 + vec2(t * 0.5, t * 0.2)) * 0.6 + vnoise(p * 61.0 - vec2(t * 0.3, 0.0)) * 0.4);
	float contact = 1.0 - smoothstep(0.03, 0.07 + 0.06 * fn, sd);
	float ph = sd * 48.0 - t * 1.6 + fn * 3.0;
	float lines = smoothstep(0.8, 0.96, sin(ph) * 0.5 + 0.5);
	float band = 1.0 - smoothstep(0.06, 0.24, sd);
	float surf = lines * band * smoothstep(0.2, 0.5, fn) * mix(0.35, 1.0, lace);
	float rk = hd_rocks(p);
	float rockfoam = smoothstep(0.3, 0.6, rk) * (1.0 - smoothstep(0.04, 0.2, sd)) * lace;
	float foam = clamp(contact * mix(0.55, 1.0, lace) + surf + rockfoam * 0.7, 0.0, 1.0);
	// sparse small whitecaps out at sea
	float cap = smoothstep(0.93, 0.985, vnoise(p * vec2(16.0, 24.0) + vec2(t * 0.3, 0.0))) * smoothstep(0.55, 0.8, vnoise(p * 0.6 + 3.0)) * k2;
	foam = max(foam, cap * 0.35 * (1.0 - smoothstep(5.0, 11.0, cam_d)));   // v3r: no whitecap speckle from far out (shimmered in motion)
	// intersection foam: wherever opaque geometry (shore boulders, ledges, quays, piers, hulls) meets the surface
	float zd = textureLod(depth_tex, SCREEN_UV, 0.0).r;
	vec4 vs = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, zd, 1.0);
	float thick = max(0.0, (-vs.z / vs.w) - (-VERTEX.z)) * abs(vdir.y);   // water thickness in front of the object
	// only where the object stands clearly above the seabed (the seabed itself gets the distance-based shore foam)
	float isect = (1.0 - smoothstep(0.0015, 0.008 + 0.006 * fn, thick)) * smoothstep(0.004, 0.012, depth - thick);
	foam = max(foam, isect * mix(0.55, 1.0, lace) * (1.0 - smoothstep(4.0, 20.0, cam_d) * 0.5));

	// ---- sun sparkle: glints on ripple facets toward a light just above the far horizon (the low sun's glitter path)
	vec3 V = -vdir;
	vec3 Nw = normalize(vec3(sl.x * 1.6, 1.0, sl.y * 1.6));
	vec3 Lg = normalize(vec3(vdir.x, 0.0, vdir.z) * 0.9 + vec3(0.0, 0.42, 0.0));
	vec3 Hg = normalize(V + Lg);
	float glint = pow(max(dot(Nw, Hg), 0.0), 1800.0);
	glint *= smoothstep(0.5, 0.85, vnoise(p * 1.3 + t * 0.05)) * (0.35 + 0.65 * fine) * k2 * (1.0 - foam);
	glint *= 1.0 - 0.98 * smoothstep(5.0, 11.0, cam_d);   // v3r: far-zoom sparkle shimmered; fade the glints with distance

	vec3 col = wcol * (1.0 - clarity * 0.9);
	col = mix(col, vec3(0.96, 0.97, 0.98), foam * 0.93);

	float cloud = hdp_cloud(wpos);   // HD cloud shadows: darker water, no glitter under a cloud
	col *= cloud;
	col *= 1.0 - 0.3 * dn_night;   // v5: a deeper, moonlit navy at night (foam and the grid stay readable)
	glint *= cloud * cloud;

	// hex grid lines on water
	ivec2 cell; int edir;
	float ed = hex_edge_dist(p, cell, edir);
	float px = fwidth(ed);
	float grid = 1.0 - smoothstep(0.0, max(0.012, px * 1.2), ed);
	col = mix(col, mix(col, vec3(0.85, 0.95, 1.0), 0.6), grid * grid_alpha * 3.6);

	vec3 emis = trans * (1.0 - foam);
	ivec2 off = axial_to_offset(cell);
	int own = hex_info(off).b;
	if (own > 0) {
		ivec2 noff = axial_to_offset(cell + AX_DIRS[edir]);
		int nown = in_map(noff) ? hex_info(noff).b : own;
		bool sea_here = hex_info(off).r <= 1;
		bool sea_there = !in_map(noff) || hex_info(noff).r <= 1;
		if ((nown > 0) != (own > 0) && !sea_here && !sea_there) {
			float line = 1.0 - smoothstep(0.012, 0.03 + px, abs(ed - 0.045));
			col = mix(col, border_color, line * 0.95);
			emis += border_color * line * 0.35;
		}
	}
	emis += dn_glint.rgb * glint * 6.0 * dn_glint.a;
	if (dn_lights > 0.001) {
		// harbour and promenade lights on the water: warm, broken reflections in the ripples next to lit coastal towns
		float town = 0.0;
		if ((hex_info(off).a & 4) != 0) town = 1.0;
		for (int i = 0; i < 6; i++) {
			ivec2 no = axial_to_offset(cell + AX_DIRS[i]);
			if (in_map(no) && (hex_info(no).a & 4) != 0 && hex_info(no).r > 1) town += 0.5;
		}
		town = min(town, 1.5);
		if (town > 0.0) {
			// reflections stretch toward the viewer: streaks along the view direction, broken by the ripples
			float near_ = exp(-sd * 9.0);
			vec2 vf = normalize(vdir.xz + vec2(1e-4));
			vec2 sp = vec2(dot(p, vec2(-vf.y, vf.x)), dot(p, vf));
			float shimmer = smoothstep(0.45, 0.9, vnoise(vec2(sp.x * 60.0, sp.y * 7.0) + nm.xy * 2.5 + vec2(0.0, t * 0.4)));
			emis += vec3(1.0, 0.68, 0.32) * town * near_ * (0.06 + 0.7 * shimmer) * (1.0 - foam) * dn_lights * 0.4;
		}
	}

	ALBEDO = col;
	EMISSION = emis;
	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), nm * 0.5 + 0.5, (1.0 - foam) * 0.85);
	NORMAL_MAP_DEPTH = 0.6;
	ROUGHNESS = mix(0.06 + streak * 0.08 * k2, 0.7, foam);
	METALLIC = 0.0;
	SPECULAR = mix(0.25, 0.1, foam) * cloud;
	ALPHA = 1.0;
}
