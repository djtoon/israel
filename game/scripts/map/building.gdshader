shader_type spatial;
// City building kit. Unit meshes scaled per instance; INSTANCE_CUSTOM: rgb = tint * 0.5, a = (style + 0.5) / 10.
// Styles (city_builder.gd): 0 limestone, 1 Bauhaus, 2 shikun, 3 glass tower, 4 plaster house,
// 5 plain stone (quays, minarets, domes), 6 terracotta tile roof, 7 ma'abara hut.
// Facades are textures from assets/kit (generated), mapped in world units so storeys line up with STOREY.
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

#include "res://scripts/map/hdplus.gdshaderinc"
#include "res://scripts/map/daynight.gdshaderinc"

uniform sampler2D t_stone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_bauhaus : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_shikun : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_glass : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_roof_flat : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_roof_tiles : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_paving : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D n_stone : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D n_bauhaus : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D n_shikun : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D n_glass : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D n_roof_tiles : hint_normal, filter_linear_mipmap, repeat_enable;
// HD mode (HDRender): the kit's baked AO maps, contact shadow at the street, roughness variation
global uniform float hd_mode;
uniform sampler2D ao_stone : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D ao_bauhaus : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D ao_shikun : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D ao_glass : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D ao_roof_flat : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D ao_roof_tiles : hint_default_white, filter_linear_mipmap, repeat_enable;
// v5 day / night (daynight.gd): lit windows at dusk and night (every mode), harbour lamps along the quays
global uniform float dn_lights;

const float SINK = 0.02;
const float STOREY = 0.037;

varying vec3 lpos;
varying vec3 lnrm;
varying vec4 cd;
varying vec3 wpos;
varying float seed;
varying vec3 vn;
varying vec3 vt;
varying vec3 vb;

float h1(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void vertex() {
	vec3 sc = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
	lpos = VERTEX * sc;
	lnrm = NORMAL;
	cd = INSTANCE_CUSTOM;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	seed = h1(MODEL_MATRIX[3].xz * 13.7);
	// explicit view-space basis: the procedural meshes' winding doesn't match their normals, and with
	// cull_disabled Godot would flip the normal on "back" faces
	vn = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vt = (MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz;
	vb = (MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz;
}

void fragment() {
	NORMAL = normalize(vn);
	if (dot(vt, vt) > 1e-6) { TANGENT = normalize(vt); BINORMAL = normalize(vb); }
	int style = int(cd.a * 10.0);
	vec3 tint = cd.rgb * 2.0;
	vec3 col = tint;
	vec3 nm = vec3(0.5, 0.5, 1.0);
	float rough = 0.85;
	float metal = 0.0;
	float spec = 0.35;
	bool side = abs(lnrm.y) < 0.5;
	float v = lpos.y - SINK;                 // height above the ground line
	float u = abs(lnrm.x) > 0.5 ? lpos.z : lpos.x;
	if (abs(lnrm.x) < 0.5 && abs(lnrm.z) < 0.5) u = lpos.x;
	float useed = floor(seed * 4.0) * 0.25;  // whole-bay offsets keep windows aligned with corners
	bool hd = hd_mode > 0.5;
	float ao = 1.0;
	vec3 lit = vec3(0.0);   // v5: night lights (emission)

	if (style == 8) {
		col = tint;
		rough = 0.5;
	} else if (style == 6) {
		// terracotta tiles projected from above along the slope
		vec2 ruv = wpos.xz * 14.0 + vec2(seed * 3.0, 0.0);
		col = texture(t_roof_tiles, ruv).rgb * tint;
		nm = texture(n_roof_tiles, ruv).rgb;
		if (hd) ao = texture(ao_roof_tiles, ruv).r;
		rough = 0.7;
	} else if (style == 5 || style == 7) {
		vec2 puv = (side ? vec2(u, v) : wpos.xz) * 9.0;
		vec3 base = style == 7 ? vec3(0.62, 0.62, 0.6) : vec3(0.86, 0.80, 0.70);
		col = mix(base, texture(t_paving, puv).rgb, style == 7 ? 0.15 : 0.45) * tint;
		if (style == 7 && side) col *= 0.9 + 0.1 * step(0.5, fract(u * 120.0)); // corrugated tin
		rough = style == 7 ? 0.5 : 0.85;
		metal = style == 7 ? 0.3 : 0.0;
	} else if (side) {
		// facade texture: S = world size of one texture tile; rows of storeys from the ground up
		float S = 2.0 * STOREY;                            // limestone: 2 storeys
		if (style == 1 || style == 4) S = 5.0 * STOREY;    // Bauhaus: 5 storeys
		if (style == 2) S = 4.0 * STOREY;                  // shikun: 4 storeys
		if (style == 3) S = 8.0 * STOREY;                  // glass: 8 floors
		vec2 fuv = vec2(u / S + useed, 1.0 - v / S);
		if (hd) ao = style == 0 ? texture(ao_stone, fuv).r : (style == 1 || style == 4) ? texture(ao_bauhaus, fuv).r : style == 2 ? texture(ao_shikun, fuv).r : texture(ao_glass, fuv).r;
		if (style == 0) {
			col = texture(t_stone, fuv).rgb; nm = texture(n_stone, fuv).rgb;
			col = mix(col, vec3(dot(col, vec3(0.3, 0.55, 0.15))), 0.35) * vec3(1.12, 1.08, 1.0);   // paler Jerusalem limestone
		}
		else if (style == 1 || style == 4) {
			col = texture(t_bauhaus, fuv).rgb; nm = texture(n_bauhaus, fuv).rgb;
			// White City plaster: lift the walls toward white, keep the windows dark
			float lum = dot(col, vec3(0.3, 0.55, 0.15));
			col = mix(col, vec3(lum) * 1.3, smoothstep(0.3, 0.7, lum) * 0.92);
		}
		else if (style == 2) {
			col = texture(t_shikun, fuv).rgb; nm = texture(n_shikun, fuv).rgb;
			float lum = dot(col, vec3(0.3, 0.55, 0.15));
			col = mix(col, vec3(lum) * 1.1, smoothstep(0.35, 0.75, lum) * 0.6);
		}
		else {
			col = texture(t_glass, fuv).rgb; nm = texture(n_glass, fuv).rgb; rough = 0.15; metal = 0.35; spec = 0.6;
			col = mix(col, vec3(dot(col, vec3(0.3, 0.5, 0.2))), 0.55) * 0.9;   // less saturated sky reflections
		}
		if (dn_lights > 0.001 && v > 0.012) {
			// v5 lit windows: the facade's own dark, cool window texels, one switch per window (storey x bay cell),
			// 30-60 % of a building's windows lit (fixed per building), warm home light (#ffb860, daynight.gdshaderinc);
			// glass towers: whole lit office floors in runs of three bays, warm too (critic v5 D1: not white)
			float wl = dot(col, vec3(0.3, 0.55, 0.15));
			float glassy = style == 3 ? 1.0 : 0.0;
			float mask = (1.0 - smoothstep(mix(0.17, 0.30, glassy), mix(0.33, 0.62, glassy), wl)) * step(col.r, col.b + 0.07 + glassy);
			mask = mix(mask, max(mask, 0.85), glassy);   // a lit office floor glows across its whole glass band
			vec2 wq = vec2(u / (STOREY * mix(0.9, 1.65, glassy)) + seed * 13.0, v / STOREY);
			vec2 wc = floor(wq);
			if (style == 0 || style == 4) {
				// old stone and plaster houses: their textures have few dark window texels, so each storey x bay
				// cell also gets a small window of its own (old towns and villages read as lit at night, not dark)
				vec2 wf = abs(fract(wq) - 0.5);
				mask = max(mask, step(wf.x, 0.15) * step(wf.y, 0.19));
			}
			float hw = h1(wc + seed * 31.7);
			float on = step(hw, dn_lit_share(fract(seed * 7.77 + 0.31), dn_lights));
			vec3 lc = dn_window(h1(wc * 1.7 + 4.0));
			lc = mix(lc, vec3(1.0, 0.32, 0.06), glassy * 0.35);   // offices: a slightly paler warm white
			// lit panes, plus a faint warm bounce of spilled light on the wall
			lit = (lc * mask * on * mix(1.7, 1.4, glassy) + DN_BOUNCE) * dn_lights;
		}
		col *= tint;
		if (style == 4) col *= vec3(1.0, 0.96, 0.88);
		// ambient occlusion at the street and a lighter parapet line at the top
		col *= mix(0.62, 1.0, smoothstep(0.0, 0.03, v));
	} else {
		// roofs: flat roofs with solar water heaters, tanks and parapets (one rooftop per building)
		vec2 ruv = (wpos.xz - MODEL_MATRIX[3].xz) * 2.6 + vec2(seed, fract(seed * 7.3));
		col = texture(t_roof_flat, ruv).rgb * mix(vec3(1.0), tint, 0.5);
		if (hd) ao = texture(ao_roof_flat, ruv).r;
		if (style == 0) col = mix(col, tint * vec3(0.85, 0.80, 0.70), 0.5);
		if (style == 1 || style == 4) col = mix(col, vec3(0.93, 0.92, 0.9), 0.55);   // whitewashed roofs
		if (style == 3) col *= 0.8;
	}
	if (hd) {
		// grounded: a soft contact shadow where walls meet the street (on top of SD's darker base), warm sun-baked
		// limestone tone, roughness varies with the texture (dirt and mortar matte, smooth plaster a bit glossier)
		float lumc = dot(col, vec3(0.3, 0.55, 0.15));
		if (side) ao *= mix(0.55, 1.0, smoothstep(0.0, 0.05, v));
		rough = clamp(rough + (0.45 - lumc) * 0.2, 0.1, 1.0);
		AO = ao;
		AO_LIGHT_AFFECT = 0.35;
		col *= vec3(1.07, 1.03, 0.96);   // a touch brighter and warmer in the low sun
		if (hdp_decals > 0.5 && style != 3) {
			// HD city grime (procedural decal masks): rain streaks below the roof line and window sills in broken
			// vertical runs, splash dirt at the street, soot and lichen patches on roofs
			if (side) {
				float colk = fract(sin(floor(u * 140.0 + seed * 17.0) * 12.9898) * 43758.5453);
				float run = smoothstep(0.55, 0.95, colk) * (0.5 + 0.5 * sin(v * 90.0 + colk * 6.0));
				float fromtop = smoothstep(0.0, 0.12, v) * (0.4 + 0.6 * smoothstep(0.6, 0.0, fract(v / STOREY)));
				col *= 1.0 - 0.13 * run * fromtop;
				col *= mix(0.84, 1.0, smoothstep(0.0, 0.016, v));
			} else {
				float sp = smoothstep(0.55, 0.8, fract(sin(dot(floor(wpos.xz * 90.0), vec2(12.9898, 78.233))) * 43758.5453) * 0.5 + h1(floor(wpos.xz * 23.0)) * 0.5);
				col *= 1.0 - 0.12 * sp;
			}
		}
	}
	float cloud = hd ? hdp_cloud(wpos) : 1.0;   // HD cloud shadows
	col *= cloud;
	spec *= cloud;
	if (dn_lights > 0.001) {
		if (style == 5 && !side && wpos.y < 0.06) {
			// v5 harbour lamps: a row of warm points along quays and moles, each with a soft pool of light
			vec2 g = fract(wpos.xz * 18.0) - 0.5;
			float d = length(g);
			lit += vec3(1.0, 0.74, 0.42) * (smoothstep(0.1, 0.0, d) * 3.0 + smoothstep(0.5, 0.0, d) * 0.35 * col.g) * dn_lights;
		}
		EMISSION = lit;
	}
	// v5 night grade (daynight.gdshaderinc): walls about 55 % darker and moonlit blue, roofs darker still, so the
	// town is a dark mass with a warm grid of windows and lamps (critic v5 D1: no more "sugar cubes")
	float dnk = dn_k();
	if (dnk > 0.0) col = (side && style != 6) ? dn_wall(col, dnk) : dn_roof(col, dnk);
	ALBEDO = col;
	NORMAL_MAP = nm;
	NORMAL_MAP_DEPTH = side ? 1.2 : 0.6;
	ROUGHNESS = rough;
	METALLIC = metal;
	SPECULAR = spec;
}
