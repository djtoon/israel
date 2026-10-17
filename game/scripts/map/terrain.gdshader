shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

#include "res://scripts/map/hexcommon.gdshaderinc"
#include "res://scripts/map/hdplus.gdshaderinc"
#include "res://scripts/map/daynight.gdshaderinc"

uniform sampler2D detail_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D t_grass : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_plains : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_hills : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_rock : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_sand : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_marsh : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_beach : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_forest : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D t_basalt : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float use_textures = 0.0;
uniform sampler2D t_paving : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float use_paving = 0.0;
const float BPX = 0.6;       // city_builder.gd lot grid (PX, PZ, SW)
const float BPZ = 0.5;
const float BSW = 0.08;
uniform float tex_scale = 0.42;
uniform sampler2D hl_tex : filter_nearest, repeat_disable;   // per-hex highlight colours (MapView.highlight_tiles)
uniform ivec2 hover_off = ivec2(-99, -99);
uniform ivec2 select_off = ivec2(-99, -99);
uniform float grid_alpha = 0.16;
uniform vec3 border_color : source_color = vec3(1.0, 0.78, 0.30);
uniform float time_s = 0.0;
// HD mode (HDRender): generated detail maps, RGBA = normal xy, cavity AO, roughness (assets/textures/hd/*_nrm.png)
global uniform float hd_mode;
global uniform float dn_lights;   // v5 day / night (daynight.gd): street lamps and the warm glow of towns at night
// (dn_night, v5 darkness: daynight.gdshaderinc; no warm cliff bounce at night, the night grade of the land)
uniform sampler2D n_grass : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D n_plains : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D n_hills : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D n_rock : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D n_sand : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D n_beach : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D n_paving : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
// HD effects: seabed caustics (assets/textures/hd/hdp_caustics.png, set by hdplus.gd)
uniform sampler2D hdp_caustic_tex : hint_default_black, filter_linear_mipmap, repeat_enable;

varying vec3 wpos;
varying float vslope;   // per-vertex slope: HD computes a per-pixel normal where the ground is steep

vec3 height_normal(vec2 p) {
	float e = 0.06;
	float hx1 = terrain_height(p + vec2(e, 0.0)), hx0 = terrain_height(p - vec2(e, 0.0));
	float hz1 = terrain_height(p + vec2(0.0, e)), hz0 = terrain_height(p - vec2(0.0, e));
	return normalize(vec3(hx0 - hx1, 2.0 * e, hz0 - hz1));
}

// HD: the normal without the per-hex cliff-edge steps (makhtesh walls)
vec3 height_normal_smooth(vec2 p) {
	float e = 0.05;
	float hx1 = terrain_height_k(p + vec2(e, 0.0), false), hx0 = terrain_height_k(p - vec2(e, 0.0), false);
	float hz1 = terrain_height_k(p + vec2(0.0, e), false), hz0 = terrain_height_k(p - vec2(0.0, e), false);
	return normalize(vec3(hx0 - hx1, 2.0 * e, hz0 - hz1));
}

// HD: -1e9 unless p is within reach of a makhtesh wall, else the signed distance to that crater's outline
float hd_crater_near(vec2 p, out int ci_out) {
	ci_out = -1;
	float best = 1e9;
	for (int ci = 0; ci < 3; ci++) {
		if (crater_b[ci].x <= 0.0) continue;
		float csd = crater_sd(p, ci);
		if (csd > -0.2 && csd < 0.5 && abs(csd) < abs(best)) { best = csd; ci_out = ci; }
	}
	return best;
}

void vertex() {
	vec2 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	float h = terrain_height(p);
	VERTEX.y = h;
	NORMAL = height_normal(p);
	vslope = 1.0 - NORMAL.y;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// textures are sampled in linear space; convert back to the sRGB-ish working space used below
vec3 tx(sampler2D t, vec2 uv) { return pow(texture(t, uv).rgb, vec3(1.0 / 2.2)); }

vec3 tex_mix(sampler2D t, vec2 uv, vec3 fallback, float k) {
	if (use_textures < 0.5) return fallback;
	vec3 s = tx(t, uv);
	// HD: blend in a rotated, larger-scale second sample so the texture's directional grain breaks up
	if (hd_mode > 0.5) s = mix(s, tx(t, mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * uv * 0.53 + vec2(0.21, 0.67)), 0.5);
	return mix(fallback, s, k);
}

// albedo for one terrain type at p (sRGB-ish working space)
// fk: weight of the green-field patchwork on plains (1; faded at far zoom in HD so it does not read as a checkerboard)
vec3 terrain_albedo(int t, vec2 p, float n1, float n2, float fieldt, float elev, float fk) {
	vec2 uv = p * tex_scale;
	vec2 uv2 = p * tex_scale * 0.37 + vec2(0.31, 0.77);
	if (t == 3) { // grassland
		vec3 c = mix(vec3(0.20, 0.36, 0.09), vec3(0.34, 0.46, 0.13), n1);
		c = tex_mix(t_grass, uv, c, 0.8) * mix(0.82, 1.12, fieldt);
		c = mix(c, c * vec3(1.15, 1.05, 0.7), smoothstep(0.6, 0.85, n2) * 0.5);
		return c;
	}
	if (t == 4) { // plains
		vec3 c = mix(vec3(0.52, 0.48, 0.24), vec3(0.40, 0.44, 0.18), n1);
		c = tex_mix(t_plains, uv, c, 0.8) * mix(0.82, 1.12, fieldt);
		// green fields among the dry ones
		c = mix(c, tex_mix(t_grass, uv2, vec3(0.3, 0.42, 0.12), 0.8), step(0.62, fieldt) * 0.65 * fk);
		return c;
	}
	if (t == 5) { // hills: limestone garrigue
		vec3 c = mix(vec3(0.44, 0.46, 0.24), vec3(0.56, 0.52, 0.32), n1);
		vec3 tc = tex_mix(t_hills, uv, c, 0.6);
		if (use_textures > 0.5) tc = mix(tc, tx(t_plains, uv2) * vec3(0.95, 1.0, 0.85), 0.3);
		return tc;
	}
	if (t == 6) { // mountains
		vec3 c = mix(vec3(0.52, 0.47, 0.40), vec3(0.66, 0.60, 0.52), n1);
		vec3 r = tex_mix(t_rock, uv, c, 0.75);
		if (use_textures > 0.5) r = mix(r, tx(t_hills, uv2), 0.35);
		return r;
	}
	if (t == 7) { // desert
		vec3 c = mix(vec3(0.86, 0.71, 0.48), vec3(0.93, 0.80, 0.58), n1);
		return tex_mix(t_sand, uv, c, 0.85) * (0.92 + 0.12 * n1);
	}
	if (t == 8) { // desert hills
		vec3 c = mix(vec3(0.72, 0.52, 0.36), vec3(0.82, 0.65, 0.46), n1);
		return tex_mix(t_rock, uv, c, 0.85);
	}
	if (t == 9) { // marsh
		vec3 c = mix(vec3(0.22, 0.36, 0.18), vec3(0.35, 0.45, 0.22), n1);
		return tex_mix(t_marsh, uv, c, 0.85);
	}
	// sea / lake bed
	return tex_mix(t_beach, uv, mix(vec3(0.80, 0.72, 0.55), vec3(0.72, 0.66, 0.50), n1), 0.6);
}

vec4 hd_nrm(int t, vec2 uv) {
	if (t == 3 || t == 9) return texture(n_grass, uv);
	if (t == 4) return texture(n_plains, uv);
	if (t == 5) return texture(n_hills, uv);
	if (t == 6 || t == 8) return texture(n_rock, uv);
	if (t == 7) return texture(n_sand, uv);
	return texture(n_beach, uv);
}

float seg_dist(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}

void fragment() {
	vec2 p = wpos.xz;
	vec2 pw = warp(p);
	ivec2 a0 = axial_round(pw);
	float n1 = fbm(p * 0.9);
	float n2 = fbm(p * 2.3 + vec2(5.0, 1.0));
	// field patchwork for farmland
	vec2 fp = mat2(vec2(0.86, 0.5), vec2(-0.5, 0.86)) * p * 3.2;
	vec2 fc = floor(fp + vec2(vnoise(p * 2.0), vnoise(p * 2.0 + 9.0)) * 0.6);
	float fieldt = hash2(int(fc.x), int(fc.y));
	float fieldk = 1.0;
	float sd_far = 0.0;   // SD: how far out the camera is (0 close .. 1 far zoom)
	if (hd_mode > 0.5 && hdp_terrain > 0.25) {
		// HD far-field fix (critic v3 B7): from far out the 0.3-unit field cells turned into a blocky checkerboard
		// (HD's straw / green grading exaggerates their contrast); fade the patchwork with camera distance
		float ffar = smoothstep(7.0, 16.0, length(wpos - CAMERA_POSITION_WORLD));
		fieldt = mix(fieldt, 0.5, ffar * 0.8);
		fieldk = 1.0 - ffar * 0.7;
	} else if (hd_mode < 0.5) {
		// SD far-field fix (critic v3r N1): the 0.3-unit field cells read as sharp-edged squares from a distance;
		// fade the patchwork with camera distance (close views are unchanged)
		// (v5: about 40 % of the patchwork contrast stays at far zoom, so the hills do not go one khaki tone, critic v5 S1)
		float ffar = smoothstep(3.0, 9.0, length(wpos - CAMERA_POSITION_WORLD));
		fieldt = mix(fieldt, 0.5, ffar * 0.6);
		fieldk = 1.0 - ffar * 0.6;
		sd_far = ffar * ffar;
	}

	vec3 col = vec3(0.0); float wsum = 0.0;
	bool hd = hd_mode > 0.5;
	vec4 nrm = vec4(0.0);
	float forest = 0.0, orchard = 0.0, urban = 0.0, wadi = 0.0, oasis = 0.0, reef = 0.0, urban_lat = 0.0;
	float farm = 0.0;   // HD decals: grassland / plains share (field-edge dirt tracks)
	float hillw = 0.0;  // SD far zoom: hills share (garrigue patchwork)
	float river = 0.0;
	float stream = 0.0;
	{
		ivec2 off0 = axial_to_offset(a0);
		vec4 d20 = texelFetch(hex_data2, clamp_off(off0), 0);
		int sl = int(round(d20.g * 255.0));
		bool wonder0 = (int(round(d20.r * 255.0)) & 64) != 0;
		if ((sl & 64) != 0 && !wonder0) {
			vec2 c = axial_center(a0);
			vec2 ps = pw + (vec2(vnoise(p * 4.0), vnoise(p * 4.0 + 7.0)) - 0.5) * 0.22;
			bool any = false;
			for (int k = 0; k < 6; k++) {
				if (((sl >> k) & 1) == 1) {
					any = true;
					vec2 e = (c + axial_center(a0 + AX_DIRS[k])) * 0.5;
					stream = max(stream, 1.0 - smoothstep(0.012, 0.03, seg_dist(ps, c, e)));
				}
			}

		}
	}
	for (int i = 0; i < 7; i++) {
		ivec2 a = i == 0 ? a0 : a0 + AX_DIRS[i - 1];
		ivec2 off = axial_to_offset(a);
		vec2 c = axial_center(a);
		float d = length(pw - c);
		float w = 1.0 - smoothstep(0.55, 1.35, d);
		if (w <= 0.0) continue;
		ivec4 inf = hex_info(off);
		vec3 alb = terrain_albedo(inf.r, p, n1, n2, fieldt, 0.0, fieldk);
		ivec4 inf2 = ivec4(round(texelFetch(hex_data2, clamp_off(off), 0) * 255.0));
		if ((inf2.r & 64) != 0 && inf.r == 7) {
			// makhtesh floor: multicoloured sandstone, gypsum and dark basalt patches
			float m1 = vnoise(p * 2.5), m2 = vnoise(p * 6.0 + 4.0);
			alb = mix(vec3(0.74, 0.46, 0.36), vec3(0.86, 0.70, 0.52), m1);
			alb = mix(alb, vec3(0.66, 0.42, 0.42), smoothstep(0.55, 0.85, m2) * 0.35);
			alb = mix(alb, vec3(0.36, 0.30, 0.27), smoothstep(0.8, 0.9, vnoise(p * 1.7 + 9.0)) * 0.5);
		}
		if (inf2.b > 0 && (inf.r == 5 || inf.r == 6 || inf.r == 8)) {
			vec3 under = terrain_albedo(inf2.b - 1, p, n1, n2, fieldt, 0.0, fieldk);
			alb = mix(alb, under, inf.r == 6 ? 0.3 : 0.5);
		}
		col += w * alb;
		wsum += w;
		if (hd) nrm += w * hd_nrm(inf.r, p * tex_scale);
		forest += w * float(inf.g == 1);
		orchard += w * float(inf.g == 2);
		wadi += w * float(inf.g == 3 && (inf2.r & 64) == 0);   // no wadi channels on wonder hexes (makhtesh floors)
		oasis += w * float(inf.g == 4);
		farm += w * float(inf.r == 3 || inf.r == 4);
		hillw += w * float(inf.r == 5);
		reef += w * float(inf.g == 5);
		float urb_reach = (inf.a & 64) != 0 ? 1.0 : 1.0 - smoothstep(0.25, 0.6, d);
		urban += w * float((inf.a & 4) != 0) * urb_reach;
		urban_lat += w * float((inf.a & 4) != 0 && (inf.a & 128) == 0);
		// rivers: centre-to-centre segments along the CPU-computed flow direction (A bits 3..5)
		if (i == 0) {
			vec2 pr = pw + (vec2(vnoise(p * 3.0), vnoise(p * 3.0 + 4.0)) - 0.5) * 0.25;
			int d0 = ((inf.a >> 3) & 7) - 1;
			if (d0 >= 0) {
				ivec2 nb = a + AX_DIRS[d0];
				bool nwater = hex_info(axial_to_offset(nb)).r <= 2;
				vec2 cb = nwater ? mix(c, axial_center(nb), 0.75) : axial_center(nb);
				river = max(river, 1.0 - smoothstep(0.022, 0.05, seg_dist(pr, c, cb)));
			}
			for (int k = 0; k < 6; k++) {
				ivec2 nb = a + AX_DIRS[k];
				ivec4 ni = hex_info(axial_to_offset(nb));
				int nd = ((ni.a >> 3) & 7) - 1;
				if (nd >= 0 && nb + AX_DIRS[nd] == a) {
					river = max(river, 1.0 - smoothstep(0.022, 0.05, seg_dist(pr, c, axial_center(nb))));
				}
			}
		}
	}
	col /= max(wsum, 1e-4);
	forest /= max(wsum, 1e-4); orchard /= max(wsum, 1e-4); urban /= max(wsum, 1e-4); urban_lat /= max(wsum, 1e-4);
	if (sd_far > 0.0) {
		// SD far zoom (critic v5 S1): the hills' texture detail averages out to one khaki tone; keep a soft
		// grass / ochre patchwork (half-hex patches) and a little more green (close views are unchanged)
		float hk = hillw / max(wsum, 1e-4) * sd_far;
		if (hk > 0.0) {
			vec3 tone = mix(vec3(1.025, 1.0, 0.96), vec3(0.95, 1.035, 0.92), smoothstep(0.3, 0.7, vnoise(p * 1.7 + 3.0)));
			col = mix(col, col * tone, hk);
		}
	}
	urban_lat = urban > 0.01 ? urban_lat / urban : 0.0;
	wadi /= max(wsum, 1e-4); oasis /= max(wsum, 1e-4); reef /= max(wsum, 1e-4); farm /= max(wsum, 1e-4);
	nrm /= max(wsum, 1e-4);

	float h = wpos.y;
	vec3 N = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	if (hd && hdp_terrain > 0.25 && vslope > 0.035) {
		// HD fix (critic v3 B3, Makhtesh Ramon): the vertex normals are interpolated across the 0.16-unit mesh, so
		// on walls only one or two triangles wide the slope (and every rock / strata band keyed to it) followed the
		// triangles in a sawtooth rim and diagonal streaks. Steep ground takes the normal of the analytic height
		// per pixel instead; at the switch-over the ground is nearly flat, so there is no seam.
		int cn;
		float csd0 = hd_crater_near(p, cn);
		// on the makhtesh walls also without the old per-hex cliff-edge steps
		N = cn >= 0 ? height_normal_smooth(p) : height_normal(p);
		if (cn >= 0) {
			// the wiggly crater outline turns the walls through the direction of the low HD sun, so the light
			// flipped on and off in hard vertical columns (warm / grey-blue): tilt the wall's shading normal
			// toward the sky so the whole wall catches some sun and the turns read as soft shading
			// (shading only: N, the slope and the triplanar weights keep the true wall)
			float wz0 = smoothstep(-0.14, -0.02, csd0) * (1.0 - smoothstep(0.26, 0.38, csd0));
			NORMAL = normalize((VIEW_MATRIX * vec4(normalize(N + vec3(0.0, 0.9 * wz0, 0.0)), 0.0)).xyz);
		} else {
			NORMAL = normalize((VIEW_MATRIX * vec4(N, 0.0)).xyz);
		}
	}
	float slope = 1.0 - N.y;

	// features tint the ground
	vec3 ffloor = use_textures > 0.5 ? tx(t_forest, p * tex_scale) * vec3(0.75, 0.95, 0.7) : col * vec3(0.62, 0.78, 0.55);
	col = mix(col, ffloor, forest * 0.75);
	float rows_ = smoothstep(0.35, 0.5, abs(fract(dot(p, vec2(0.3, 1.0)) * 9.0) - 0.5));
	col = mix(col, mix(vec3(0.50, 0.40, 0.26), vec3(0.36, 0.45, 0.18), rows_), orchard * 0.55);
	col = mix(col, vec3(0.55, 0.62, 0.30), oasis * 0.7);
	if (hd) {
		// HD ground: straw-coloured dry grass in broad patches, olive (not lime) greens, terra-rossa soil, pale stones
		float lum = dot(col, vec3(0.3, 0.55, 0.15));
		float green = clamp((col.g - max(col.r, col.b)) * 6.0, 0.0, 1.0);
		float dry = smoothstep(0.3, 0.75, fbm(p * 0.7 + vec2(13.0, 3.0)));
		float keep = clamp(1.0 - forest * 0.8 - oasis, 0.0, 1.0);
		vec3 straw = vec3(lum) * vec3(1.48, 1.17, 0.56);
		// HD season: winter rains turn the hills green, summer burns them to straw (spring = HD as is)
		float sdry = clamp(1.0 + 0.55 * hdp_season.x, 0.25, 1.6);
		col = mix(col, straw, clamp(green * mix(0.25, 0.85, dry) * keep * sdry, 0.0, 1.0));
		if (hdp_season.x < 0.0) col = mix(col, col * vec3(0.84, 1.07, 0.74), clamp(green * 2.0, 0.0, 1.0) * keep * -hdp_season.x * 0.55);
		else col = mix(col, vec3(dot(col, vec3(0.3, 0.55, 0.15))) * vec3(1.12, 1.0, 0.8), keep * hdp_season.x * 0.18);
		col = mix(col, col * vec3(0.95, 0.94, 0.78), green * 0.5);
		float soil = smoothstep(0.55, 0.75, fbm(p * 1.6 + vec2(7.0, 1.0))) * (1.0 - smoothstep(0.15, 0.4, slope));
		col = mix(col, vec3(0.50, 0.34, 0.22) * (0.85 + 0.3 * n2), soil * 0.4 * keep);
		float stones = smoothstep(0.82, 0.94, vnoise(p * 30.0)) * smoothstep(0.45, 0.75, vnoise(p * 3.0 + 5.0));
		col = mix(col, vec3(0.78, 0.74, 0.64), stones * 0.25 * keep);
		// sunlit, saturated ground: golden ochre rather than grey-olive
		float lum2 = dot(col, vec3(0.3, 0.55, 0.15));
		col = mix(vec3(lum2), col, 1.0 + 0.1 * keep) * mix(vec3(1.0), vec3(1.05, 1.02, 0.95), keep);
	}
	if (hd && hdp_decals > 0.5) {
		// HD decals: dirt tracks and bare soil along the field edges (same cells as the field patchwork above)
		vec2 fq = fp + vec2(vnoise(p * 2.0), vnoise(p * 2.0 + 9.0)) * 0.6;
		vec2 fe = abs(fract(fq) - 0.5);
		float ed2 = 0.5 - max(fe.x, fe.y);
		float fw = fwidth(ed2);
		float track = 1.0 - smoothstep(0.012, 0.03 + fw, ed2);
		track *= step(0.45, hash2(int(floor(fq.x * 2.0 + 0.5)) + 31, int(floor(fq.y * 2.0 + 0.5)) + 7));   // only some field edges are tracks
		track *= 1.0 - smoothstep(0.06, 0.16, fw);   // far: fades out, no moire
		float fk = farm * (1.0 - forest) * (1.0 - smoothstep(0.1, 0.3, slope)) * smoothstep(0.02, 0.05, h);
		col = mix(col, vec3(0.56, 0.44, 0.31) * (0.9 + 0.2 * n2), track * fk * (0.25 + 0.25 * vnoise(p * 20.0)));
	}
	// wadis: dry pale channels
	float wd = abs(vnoise(p * 1.6) - 0.5);
	col = mix(col, vec3(0.93, 0.86, 0.70), wadi * (1.0 - smoothstep(0.02, 0.05, wd)) * 0.8);
	// urban ground: pale stone with street grid
	vec3 pav = use_paving > 0.5 ? tx(t_paving, p * 2.2) : mix(vec3(0.66, 0.62, 0.55), vec3(0.76, 0.72, 0.64), n2);
	vec3 urb = pav * vec3(0.95, 0.93, 0.9);
	// street grid (city_builder.gd block grid): asphalt carriageway, pale sidewalks, block interiors
	vec2 bf = fract(vec2(p.x / BPX, p.y / BPZ));
	float de = min(min(bf.x, 1.0 - bf.x) * BPX, min(bf.y, 1.0 - bf.y) * BPZ);   // distance to street centreline
	float asphalt = 1.0 - smoothstep(BSW * 0.27, BSW * 0.32, de);
	float sidewalk = (1.0 - smoothstep(BSW * 0.5, BSW * 0.56, de)) * (1.0 - asphalt);
	vec3 road = vec3(0.29, 0.29, 0.30) * (0.9 + 0.2 * n2);
	// lane markings
	float dash = step(0.5, fract((bf.x + bf.y) * 6.0)) * (1.0 - smoothstep(0.002, 0.004, abs(de - 0.0)));
	road = mix(road, vec3(0.85, 0.85, 0.8), dash * 0.0);
	vec3 walk = pav * vec3(1.08, 1.06, 1.02);
	if (hd && hdp_decals > 0.5) {
		// HD decals: crumbling dusty carriageway edges, patched asphalt, darker wheel tracks, gutter grime
		float wear = smoothstep(0.35, 0.75, vnoise(p * 55.0));
		float edge = smoothstep(BSW * 0.17, BSW * 0.27, de) * asphalt;
		road = mix(road, vec3(0.50, 0.46, 0.40), edge * wear * 0.75);
		road *= mix(1.0, 0.8, smoothstep(0.68, 0.78, vnoise(p * 23.0 + 3.0)));
		road *= mix(1.0, 0.86, (1.0 - smoothstep(0.0, BSW * 0.1, abs(de - BSW * 0.13))) * 0.6);
		walk *= mix(1.0, 0.8, (1.0 - smoothstep(BSW * 0.3, BSW * 0.42, de)) * smoothstep(0.35, 0.7, vnoise(p * 40.0)));
		pav *= mix(1.0, 0.86, smoothstep(0.6, 0.85, fbm(p * 12.0)));   // city grime: stains on squares and plazas
	}
	// courtyards: gardens in the middle of blocks
	// block interiors are gardens: lawn and shrubs with a few paved paths and courtyards
	float court = smoothstep(0.035, 0.06, de);
	vec3 lawn = (use_textures > 0.5 ? tx(t_grass, p * 1.3) : vec3(0.3, 0.42, 0.16)) * vec3(0.95, 1.05, 0.85);
	lawn = mix(lawn, lawn * 0.7, smoothstep(0.55, 0.75, vnoise(p * 14.0)));
	float paved = smoothstep(0.62, 0.7, vnoise(p * 6.0 + 3.0));
	vec3 inner = mix(pav * 0.92, mix(lawn, pav * 0.9, paved * 0.7), court * 0.85);
	// dense urban core: paved courtyards and plazas, small planters only (no lawns)
	int a2 = int(round(texelFetch(hex_data2, clamp_off(axial_to_offset(a0)), 0).a * 255.0));
	if ((a2 & 1) != 0) {
		// dense core: courtyard gardens (lawn, shrubs, bougainvillea), slightly more paved paths
		inner = mix(inner, mix(lawn, pav * 0.92, smoothstep(0.55, 0.7, vnoise(p * 7.0 + 1.0))), court * 0.4);
	}
	float lattice_w = clamp(urban_lat, 0.0, 1.0);
	vec3 sgrid = mix(inner, walk, sidewalk);
	sgrid = mix(sgrid, road, asphalt);
	urb = mix(urb, sgrid, lattice_w);
	float organic = 1.0 - smoothstep(0.0, 0.1, abs(vnoise(p * 7.0) - 0.5)); // alleys for old towns
	urb = mix(urb, urb * 0.8, organic * 0.5 * (1.0 - lattice_w));
	col = mix(col, urb, urban * 0.92);
	// v5 night lights: street lamps along the lattice streets (a pool of light around each head), lit alleys in the
	// old towns, and a faint warm glow over every built-up area so towns read from far out
	float lamp_pool = 0.0, lamp_head = 0.0, town_glow = 0.0;
	if (dn_lights > 0.001 && urban > 0.01) {
		float sx = BPX * 0.25, sz = BPZ * 0.25;
		float dh = length(vec2((fract(p.x / sx) - 0.5) * sx, min(bf.y, 1.0 - bf.y) * BPZ));
		float dv = length(vec2(min(bf.x, 1.0 - bf.x) * BPX, (fract(p.y / sz) - 0.5) * sz));
		float dl = min(dh, dv);
		lamp_pool = exp(-dl * dl / 0.0011) * lattice_w * urban;
		lamp_head = (1.0 - smoothstep(0.0025, 0.006, dl)) * lattice_w * urban;
		town_glow = urban * (0.1 + 0.35 * organic * (1.0 - lattice_w) * smoothstep(0.4, 0.7, vnoise(p * 31.0)));
	}

	// seasonal streams / named wadis: pale gravel bed with a darker edge (rivers are blue)
	stream *= 1.0 - smoothstep(0.18, 0.35, slope);   // no wadi lines up cliffs and crater walls
	float sedge = stream * (1.0 - stream) * 4.0;
	col = mix(col, col * 0.72, sedge * 0.6);
	col = mix(col, vec3(0.90, 0.84, 0.70) * (0.9 + 0.15 * n2), smoothstep(0.45, 0.9, stream) * 0.85);

	// slopes: triplanar rock (no stretched UVs on cliffs); on green-based hills (Carmel, Galilee, Naftali,
	// western Judea) maquis and pine-oak scrub instead of bare rock
	vec3 an = abs(N);
	vec3 rx = tx(t_rock, vec2(wpos.z, wpos.y) * tex_scale * 1.6);
	vec3 rz = tx(t_rock, vec2(wpos.x, wpos.y) * tex_scale * 1.6);
	vec3 ry = tx(t_rock, p * tex_scale * 0.8);
	vec3 rock = use_textures > 0.5 ? (rx * an.x + rz * an.z + ry * an.y) / max(an.x + an.y + an.z, 1e-3) * 0.95 : mix(vec3(0.55, 0.50, 0.43), vec3(0.68, 0.62, 0.54), n2);
	int b0 = int(round(texelFetch(hex_data2, clamp_off(axial_to_offset(a0)), 0).b * 255.0)) - 1;
	int t0 = hex_info(axial_to_offset(a0)).r;
	bool green = b0 == 3 || ((t0 == 5 || t0 == 6) && b0 != 7 && b0 != 4) || t0 == 3;
	vec3 maquis = mix(vec3(0.24, 0.36, 0.14), vec3(0.36, 0.42, 0.2), n2);
	maquis = mix(maquis, rock * vec3(0.9, 0.95, 0.85), smoothstep(0.6, 0.85, vnoise(p * 9.0)) * 0.35);
	if (hd && hdp_terrain > 0.75) {
		// HD+ terrain: height-blended slopes. Rock shows first in the low (dark) texels of the ground and holds
		// its bright ledges; higher ground exposes more rock; red terra-rossa soil (scree in the desert) collects
		// at the foot of the slopes. Steep faces keep the triplanar rock above (and get triplanar normals below).
		vec3 top = green ? maquis : rock;
		float hr = dot(top, vec3(0.33)) + (green ? 0.0 : 0.15);
		float hg = dot(col, vec3(0.33));
		float alt = smoothstep(0.5, 1.4, h) * (green ? 0.08 : 0.16) * (1.0 - urban);
		float s2 = clamp(smoothstep(0.12, 0.48, slope) * (green ? 0.8 : 0.82) + alt, 0.0, 1.0);
		float a1 = hg + (1.0 - s2), a2 = hr + s2;
		float ma = max(a1, a2) - 0.12;
		float b1 = max(a1 - ma, 0.0), b2 = max(a2 - ma, 0.0);
		float hb = b2 / max(b1 + b2, 1e-4);
		float foot = smoothstep(0.05, 0.13, slope) * (1.0 - smoothstep(0.17, 0.3, slope)) * (1.0 - urban) * smoothstep(0.03, 0.08, h);
		vec3 soil = (green ? vec3(0.52, 0.31, 0.20) : vec3(0.66, 0.55, 0.42)) * (0.85 + 0.3 * vnoise(p * 9.0));
		col = mix(col, soil, foot * smoothstep(0.35, 0.65, vnoise(p * 3.3 + 2.0)) * 0.45);
		col = mix(col, top, hb * smoothstep(0.04, 0.16, slope + alt));
	} else {
		col = mix(col, green ? maquis : rock, smoothstep(0.18, 0.45, slope) * (green ? 0.8 : 0.75));
	}
	// sedimentary strata on steep faces (makhtesh walls, rift escarpments)
	float cliffk = smoothstep(0.45, 0.75, slope);
	if (hd && hdp_terrain > 0.25 && !green) cliffk = smoothstep(0.26, 0.55, slope);   // HD: warm strata over more of the desert walls, not grey rock
	float hy = wpos.y;
	float hpix = wpos.y;   // HD: the per-pixel analytic height where it was computed (cliffs), else the mesh's
	// HD: per-pixel height, so the strata follow the real contours rather than the facets of the 0.16-unit mesh
	// (on walls one or two triangles wide those facets turned the bands into diagonal streaks)
	if (hd && hdp_terrain > 0.25 && cliffk > 0.0) { hy = terrain_height(p); hpix = hy; }
	float strata = sin(hy * 140.0 + vnoise(p * 3.0) * 4.0) * 0.5 + 0.5;
	float sdark = 0.6;
	if (hd && hdp_terrain > 0.25) {
		strata = 0.5 + (strata - 0.5) * (0.35 + 0.4 * vnoise(p * 5.0 + 3.0));   // HD: softer, uneven bands (no zebra)
		sdark = 0.35;
	}
	vec3 band = mix(vec3(0.72, 0.52, 0.38), vec3(0.88, 0.78, 0.62), strata);
	band = mix(band, vec3(0.55, 0.36, 0.30), smoothstep(0.8, 0.95, sin(hy * 47.0 + 1.3) * 0.5 + 0.5) * sdark);
	col = mix(col, band, cliffk * (green ? 0.25 : 0.85));

	// makhtesh floors: dark, multicoloured rock (red/ochre sandstone, white gypsum, dark basalt) and a darker rim shadow
	for (int ci = 0; ci < 3; ci++) {
		if (crater_b[ci].x <= 0.0) continue;
		float csd = crater_sd(p, ci);
		float fl = 1.0 - smoothstep(-0.25, 0.1, csd);
		if (fl <= 0.0) continue;
		float m1 = vnoise(p * 3.1), m2 = vnoise(p * 7.0 + 4.0), m3 = vnoise(p * 1.3 + 11.0);
		vec3 fc = mix(vec3(0.40, 0.22, 0.17), vec3(0.62, 0.42, 0.26), m1);
		fc = mix(fc, vec3(0.58, 0.40, 0.36), smoothstep(0.5, 0.8, m3) * 0.5);
		fc = mix(fc, vec3(0.80, 0.74, 0.60), smoothstep(0.75, 0.9, m2) * 0.3);
		fc = mix(fc, vec3(0.20, 0.17, 0.16), smoothstep(0.62, 0.78, vnoise(p * 1.9 + 2.0)) * 0.45);
		fc *= 0.85 + 0.25 * (1.0 - smoothstep(-0.9, -0.1, csd));   // slightly lighter toward the middle
		col = mix(col, fc, fl * 0.92);
	}
	float cwall = 0.0;   // HD: makhtesh wall mask (also used for the rock normals below)
	if (hd && hdp_terrain > 0.25) {
		float hyw = -1e9;   // per-pixel height (strata follow the real contours)
		// HD fix (critic v3 B3): makhtesh walls painted from the analytic crater outline, not from the slope
		// (at about 40 degrees the walls are too gentle for the slope-keyed strata, so the per-hex albedo of the
		// desert / desert-hills hexes showed through in grey blocks a hex long). Real Ramon walls: a pale
		// limestone-dolomite cap, variegated red / ochre / white sandstone below, a talus apron at the foot.
		for (int ci = 0; ci < 3; ci++) {
			if (crater_b[ci].x <= 0.0) continue;
			float csd = crater_sd(p, ci);
			if (csd < -0.2 || csd > 0.5) continue;
			if (hyw < -1e8) { hyw = terrain_height_k(p, false); hpix = hyw; }   // strata without the cliff steps
			float wz = smoothstep(-0.14, -0.02, csd) * (1.0 - smoothstep(0.26, 0.38, csd));
			float wt = smoothstep(-0.04, 0.3, csd);   // 0 at the foot .. 1 at the top (crater_carve's wall)
			// broad, soft bands (a few per wall) with a faint fine layering; no hard contour lines
			float sv = sin(hyw * 105.0 + vnoise(p * 3.0) * 2.0) * 0.5 + 0.5;
			float sv2 = sin(hyw * 44.0 + 0.7 + vnoise(p * 2.0 + 5.0) * 1.5) * 0.5 + 0.5;
			float sv3 = sin(hyw * 29.0 + 2.1) * 0.5 + 0.5;
			vec3 sst = mix(vec3(0.68, 0.44, 0.35), vec3(0.81, 0.63, 0.45), smoothstep(0.15, 0.85, sv2));
			sst = mix(sst, vec3(0.85, 0.78, 0.67), smoothstep(0.7, 1.0, sv3) * 0.4);
			sst *= 0.95 + 0.08 * sv;
			vec3 cap = vec3(0.85, 0.76, 0.62) * (0.95 + 0.07 * sv);
			cap = mix(cap, vec3(0.70, 0.60, 0.50), smoothstep(0.75, 0.98, sin(hyw * 47.0 + 1.3) * 0.5 + 0.5) * 0.3);
			vec3 wc = mix(sst, cap, smoothstep(0.55, 0.78, wt));
			vec3 talus = mix(vec3(0.62, 0.44, 0.35), vec3(0.74, 0.60, 0.46), vnoise(p * 21.0));
			wc = mix(talus, wc, smoothstep(0.02, 0.16, wt));
			wc *= 0.9 + 0.16 * vnoise(vec2(dot(p, crater_a[ci].zw) * 9.0, csd * 2.0));   // faint gullies down the wall
			col = mix(col, wc, wz * 0.92);
			cwall = max(cwall, wz);
		}
	}

	// beaches near the waterline; wet sand just below
	float beach = (1.0 - smoothstep(0.008, 0.026 + 0.02 * n2, h)) * smoothstep(-0.12, -0.02, h);
	vec3 sand = use_textures > 0.5 ? tx(t_beach, p * tex_scale * 1.5) : vec3(0.90, 0.80, 0.60);
	col = mix(col, sand, beach * (1.0 - urban * 0.7));
	// seabed darkens with depth
	col = mix(col, col * vec3(0.55, 0.65, 0.7), smoothstep(-0.05, -0.5, h));
	if (hd) {
		// HD coast: dark reef rocks on the shallow seabed (seen through the turquoise water), wet sand at the
		// waterline and rocky outcrops on the shore
		float rk = hd_rocks(p);
		float sb = smoothstep(0.004, -0.008, h) * (1.0 - smoothstep(-0.14, -0.4, h));   // below the waterline only
		vec3 rcol = tx(t_rock, p * 3.1) * vec3(0.42, 0.40, 0.32) * (0.5 + 0.7 * vnoise(p * 34.0));
		// sand under the water: darker and greener so the shallows read turquoise rather than milky
		col *= mix(vec3(1.0), vec3(0.62, 0.74, 0.70), smoothstep(-0.002, -0.03, h));
		col *= mix(1.0, 0.82, smoothstep(0.012, -0.002, h) * smoothstep(-0.05, -0.01, h));   // wet sand
		col = mix(col, rcol, smoothstep(0.25, 0.55, rk) * sb * 0.92);
		float shore = (1.0 - smoothstep(0.012, 0.045, h)) * smoothstep(-0.004, 0.008, h);
		// kurkar (coastal sandstone) outcrops: pale warm stone with dark crevices, not mud-dark stains
		vec3 kurkar = vec3(0.80, 0.68, 0.50) * (0.8 + 0.3 * vnoise(p * 26.0));
		kurkar *= mix(1.0, 0.6, smoothstep(0.7, 0.85, vnoise(p * 48.0 + 3.0)));
		col = mix(col, kurkar, shore * smoothstep(0.55, 0.72, fbm(p * 5.0 + 1.0)) * 0.6 * (1.0 - urban));
	}
	float wetb = 0.0;
	if (hd && hdp_decals > 0.5) {
		// HD decals: wet sand along the shoreline, its swash line moving with the surf, dark and glossy
		float surge = 0.004 * sin(TIME * 0.7 + p.x * 3.0 + p.y * 2.0 + n2 * 6.0);
		wetb = (1.0 - smoothstep(0.009 + surge + 0.006 * vnoise(p * 30.0), 0.019 + surge, h)) * smoothstep(-0.012, 0.0, h);
		wetb *= beach * (1.0 - urban);
		col *= mix(vec3(1.0), vec3(0.84, 0.84, 0.86), wetb);   // gentle: the bright beach line still reads as the coast
	}
	if (hd && hdp_caustics > 0.0 && h < 0.0) {
		// HD caustics: two drifting layers of a refracted-light pattern; min() makes the filaments dance.
		// Strongest in the shallows, gone by about 0.3 (the deep shelf), faded out at far zoom (no shimmer).
		float dep = -h;
		float cf = smoothstep(0.0, 0.012, dep) * (1.0 - smoothstep(0.05, 0.28, dep));
		cf *= 1.0 - smoothstep(8.0, 15.0, length(wpos - CAMERA_POSITION_WORLD));
		if (cf > 0.0) {
			vec2 cu = p * 1.15;
			float c1 = texture(hdp_caustic_tex, cu + vec2(0.021, 0.013) * TIME).r;
			float c2 = texture(hdp_caustic_tex, cu * 0.83 + vec2(-0.017, 0.024) * TIME + 0.41).r;
			float cs = min(c1, c2) * 2.0 + c1 * c2 * 2.0;
			col *= 1.0 + hdp_caustics * cs * cf * 2.2;
		}
	}
	// reef: coral patches
	col = mix(col, vec3(0.75, 0.55, 0.45), reef * smoothstep(0.55, 0.7, n2));

	// river water
	col = mix(col, vec3(0.16, 0.38, 0.52), river * 0.9);

	// v5 night grade (daynight.gdshaderinc): pale ground (desert, stone, towns) no brighter than the green land at
	// night, desaturated grey-blue; before the grid, borders and highlights, so those keep their colours. The street
	// lamps light the day albedo (they stay as bright as before)
	vec3 col_day = col;
	float dnk = dn_k();
	if (dnk > 0.0) col = pow(dn_land(pow(max(col, vec3(0.0)), vec3(2.2)), dnk), vec3(0.4545));
	float cloud = hd ? hdp_cloud(wpos) : 1.0;   // HD cloud shadows (1 = sun); before the grid, borders, highlights
	col *= pow(cloud, 0.4545);
	col_day *= pow(cloud, 0.4545);
	// hex grid lines (on unwarped hexes)
	ivec2 cell; int edir;
	float ed = hex_edge_dist(p, cell, edir);
	float px = fwidth(ed);
	float grid = 1.0 - smoothstep(0.0, max(0.012, px * 1.2), ed);
	col = mix(col, col * 0.55, grid * grid_alpha * 2.0);

	// borders
	ivec2 off = axial_to_offset(cell);
	int own = hex_info(off).b;
	vec3 emis = vec3(0.0);
	if (own > 0) {
		ivec4 ninf = hex_info(axial_to_offset(cell + AX_DIRS[edir]));
		int nown = ninf.b;
		if (!in_map(axial_to_offset(cell + AX_DIRS[edir])) || ninf.r <= 1) nown = own;
		// along-edge coordinate for dashes
		vec2 en = normalize(axial_center(cell + AX_DIRS[edir]) - axial_center(cell));
		float along = dot(p, vec2(-en.y, en.x));
		float dash = step(0.45, fract(along * 4.0));
		if (nown != own) {
			// toned down: thin, low alpha; a bit stronger only when far (px large) so it stays readable
			float bfar = smoothstep(0.02, 0.12, px);
			float line = 1.0 - smoothstep(0.006, 0.014 + px * 0.7, abs(ed - 0.04));
			float core = 1.0 - smoothstep(0.0015, 0.004 + px * 0.5, abs(ed - 0.04));
			float glow = (1.0 - smoothstep(0.0, 0.22, ed));
			if (own == 2 || nown == 2) {
				// edge of territory held only militarily: amber, dashed, no glow
				// subtle: thin dashed edge (narrower line, lower alpha), no emission
				float k = (nown != 0 && own != 0) ? 0.6 : 0.8;
				float thin = 1.0 - smoothstep(0.005, 0.012 + px, abs(ed - 0.04));
				thin *= dash * k;
				col = mix(col, vec3(0.80, 0.50, 0.22), thin * 0.55);
				col = mix(col, vec3(0.98, 0.90, 0.74), thin * thin * 0.35);
			} else {
				// sovereign / armistice line: gold band with a white core and a soft warm glow (Civ style)
				float ba = mix(0.45, 0.8, bfar);
				col = mix(col, col * vec3(1.15, 1.05, 0.85) + vec3(0.06, 0.04, 0.0), glow * 0.12);
				col = mix(col, border_color, line * ba);
				col = mix(col, vec3(1.0, 0.98, 0.92), core * ba * 0.5);
				emis += border_color * line * 0.06;
			}
		}
		if (own == 2) {
			// diagonal hatching over territory held only militarily
			// fine, uniform diagonal hatch (screen-independent) over territory held only militarily
			float hp = fract((p.x - p.y) * 6.0);
			float hw = max(fwidth((p.x - p.y) * 6.0), 1e-4);
			float hatch = smoothstep(0.42 - hw, 0.42 + hw, abs(hp - 0.5));   // thin stripes (~16 % of the period)
			hatch = mix(hatch, 0.16, smoothstep(0.1, 0.3, hw));   // far away: average, no moire
			float far = smoothstep(14.0, 34.0, length(wpos - CAMERA_POSITION_WORLD));
			col = mix(col, vec3(0.80, 0.34, 0.20), (0.05 + hatch * 0.12) * (1.0 - 0.5 * far));
		}
	}
	{
		int a2b = int(round(texelFetch(hex_data2, clamp_off(off), 0).a * 255.0));
		if ((a2b & 2) != 0) {
			// held by Jordan 1948-67: red-ochre wash with a fine hatch so the divided city reads at a glance
			float jh = 1.0 - smoothstep(0.0, 0.06, abs(fract((p.x + p.y) * 7.0) - 0.5) - 0.4);
			col = mix(col, col * vec3(1.25, 0.72, 0.6), 0.65 + jh * 0.3);
		}
	}
	// gameplay highlights: tinted fill + bright rim
	vec4 hl = texelFetch(hl_tex, clamp(off, ivec2(0), map_size - ivec2(1)), 0);
	if (hl.a > 0.0 && in_map(off)) {
		float rim = 1.0 - smoothstep(0.0, 0.07, ed);
		col = mix(col, hl.rgb, hl.a * 0.35);
		col = mix(col, hl.rgb, rim * 0.85);
		emis += hl.rgb * rim * 0.35;
	}
	// hover / selection
	if (off == hover_off) {
		float rim = 1.0 - smoothstep(0.0, 0.06, ed);
		col = mix(col, vec3(1.0), rim * 0.75);
		col *= 1.12;
		emis += vec3(1.0, 0.95, 0.8) * rim * 0.25;
	}
	if (off == select_off) {
		float rim = 1.0 - smoothstep(0.0, 0.08, ed);
		col = mix(col, vec3(1.0, 0.85, 0.35), rim * 0.9);
		emis += vec3(1.0, 0.8, 0.3) * rim * 0.45;
	}

	ALBEDO = pow(max(col, vec3(0.0)), vec3(2.2));
	EMISSION = emis;
	if (dn_lights > 0.001) {
		vec3 alb_day = pow(max(col_day, vec3(0.0)), vec3(2.2));
		EMISSION += dn_lights * (alb_day * vec3(1.0, 0.70, 0.40) * (lamp_pool * 2.6 + town_glow) + vec3(1.0, 0.78, 0.48) * lamp_head * 1.6);
	}
	ROUGHNESS = mix(0.92, 0.35, river) - beach * 0.1;
	SPECULAR = 0.3;
	vec2 duv = p * 0.9;
	NORMAL_MAP = texture(detail_normal, duv).rgb;
	NORMAL_MAP_DEPTH = 0.6 + smoothstep(0.1, 0.4, slope) * 0.8;
	if (hd) {
		// generated texture normals + the broad detail normal; paving normals in towns; cavity AO; roughness map
		vec2 nxy = (nrm.rg * 2.0 - 1.0) * 0.55 + (NORMAL_MAP.rg * 2.0 - 1.0) * 0.5;
		vec2 pn = texture(n_paving, p * 2.2).rg * 2.0 - 1.0;
		nxy = mix(nxy, pn * 0.8, urban * 0.85);
		nxy *= 1.0 - smoothstep(-0.02, -0.15, h) * 0.6;   // calmer under water
		NORMAL_MAP = vec3(nxy * 0.5 + 0.5, 1.0);
		NORMAL_MAP_DEPTH = 0.9 + smoothstep(0.1, 0.4, slope) * 0.6;
		ROUGHNESS = mix(mix(nrm.a, 0.8, urban), 0.35, river) - beach * 0.12;
		AO = mix(1.0, nrm.b, 0.85 * (1.0 - urban * 0.5));
		AO_LIGHT_AFFECT = 0.3;
		if (hdp_terrain > 0.25) {
			// HD terrain (HD and HD+): triplanar rock normals and cavity on steep faces. The planar ground normals and cavity
			// stretched down cliffs into dark streaks and stipple (Makhtesh Ramon walls, critic v3 B3), so from a
			// moderate slope on, a broader, gentler triplanar rock detail replaces them, the cliff gets less
			// cavity darkening and a little warm bounce light from the sunlit ground below it
			float tk = max(smoothstep(0.16, 0.42, slope), cwall * smoothstep(0.04, 0.12, slope));
			if (tk > 0.0) {
				// per-pixel height for the vertical axes: the mesh's height is faceted and stretched the
				// side projections along the triangles (streaks)
				vec4 tx_ = texture(n_rock, vec2(wpos.z, hpix) * tex_scale * 0.9);
				vec4 tz_ = texture(n_rock, vec2(wpos.x, hpix) * tex_scale * 0.9);
				vec4 ty_ = texture(n_rock, p * tex_scale * 0.8);
				vec4 tri = (tx_ * an.x + tz_ * an.z + ty_ * an.y) / max(an.x + an.y + an.z, 1e-3);
				// makhtesh walls stand almost edge-on to the low HD sun: fine rock normals flipped single pixels
				// across the light terminator (grey-blue speckle), so the walls get only a faint normal detail
				vec2 txy = (tri.rg * 2.0 - 1.0) * mix(0.55, 0.2, cwall);
				NORMAL_MAP = mix(NORMAL_MAP, vec3(txy * 0.5 + 0.5, 1.0), max(tk, cwall));
				NORMAL_MAP_DEPTH = mix(NORMAL_MAP_DEPTH, mix(0.8, 0.3, cwall), max(tk, cwall));
				AO = mix(AO, mix(1.0, tri.b, mix(0.45, 0.25, cwall)), tk);
				// matte dry rock: a glossy texel reflected the blue sky in grey-blue streaks on the walls
				ROUGHNESS = mix(ROUGHNESS, max(tri.a, 0.85), tk);
				SPECULAR = mix(SPECULAR, 0.2, tk);
				EMISSION += ALBEDO * vec3(0.20, 0.15, 0.10) * smoothstep(0.25, 0.6, slope) * (1.0 - urban) * (1.0 - dn_night);
			}
		}
		ROUGHNESS = mix(ROUGHNESS, 0.2, wetb * 0.85);
	}
	SPECULAR *= cloud;
}
