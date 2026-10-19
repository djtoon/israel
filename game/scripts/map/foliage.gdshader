shader_type spatial;
// v5 trees (TreeKit): painted leaf-cluster cards and bark from veg_atlas.png, alpha-tested; per-instance tint
// (INSTANCE_CUSTOM.rgb); wind. Vertex data: COLOR.rgb = colour * baked AO (sRGB), COLOR.a = leaf mask (0 bark,
// 1 leaves), UV = atlas, UV2.x = flutter weight. The HD / HD+ look follows props.gdshader (colour variety, darker
// bases, sunlit crowns, cloud shadows, back light, season); SD is the cheap path (no translucency, no rim).
render_mode cull_disabled;

#include "res://scripts/map/hdplus.gdshaderinc"

uniform sampler2D atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform float wind = 1.0;
uniform float mip_keep = 0.8;    // alpha boost per mip level: thin leaves would otherwise vanish at a distance
// v5 fix: leaves read lush at play zoom: a little more saturation and value near, more far (past the near LOD),
// where each tree also flattens toward one mid-tone (the painted texture's mean, less variety: no speckle)
uniform float sat_near = 1.1;
uniform float sat_far = 1.3;
uniform float val_near = 1.08;
uniform float val_far = 1.2;
uniform vec3 leaf_hue = vec3(0.93, 1.04, 0.9);   // a fresher green (the warm sun and the HD grade yellow the leaves)
uniform vec2 far_range = vec2(9.0, 20.0);
global uniform float hd_mode;
global uniform vec3 hd_sun_dir;   // world direction toward the sun (HDRender / DayNight)
global uniform float dn_night;    // DayNight: 0 day .. 1 night (no sun glow, rim or translucency by moonlight)

varying vec3 tint;
varying vec3 vn;
varying float vseed;
varying float vlh;
varying vec3 vwp;
varying float vleaf;     // leaf mask for light()
varying float vback;     // translucency strength for light() (0 in SD); written in fragment()

void vertex() {
	tint = INSTANCE_CUSTOM.rgb * 2.0;
	vec3 w = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float leaf = COLOR.a;
	if (hd_mode > 0.5 && hdp_foliage > 0.5 && wind > 0.0) {
		// HD+ wind: gusts roll in from the sea as a slow wave across the map; each plant bends with them (two axes,
		// quadratic with height, so trunks stay planted) and its leaves and frond tips flutter faster
		float gust = 0.55 + 0.45 * sin(TIME * 0.45 - w.x * 0.35 + w.z * 0.12) * sin(TIME * 0.21 - w.x * 0.13 + 1.7);
		float s1 = sin(TIME * 1.1 + w.x * 3.0 + w.z * 2.0) * (0.55 + 0.45 * gust) + 0.35 * gust;
		float s2 = sin(TIME * 0.83 + w.z * 2.6 + w.x * 0.7 + 1.3) * 0.4;
		float hh = VERTEX.y * VERTEX.y * 4.0;
		VERTEX.x += s1 * 0.075 * wind * hh;
		VERTEX.z += s2 * 0.075 * wind * hh;
		float fl = sin(TIME * 6.5 + dot(VERTEX, vec3(97.0, 61.0, 83.0))) * (0.4 + 0.6 * gust);
		VERTEX.y += fl * 0.003 * leaf * (0.35 + UV2.x) * clamp(VERTEX.y * 10.0, 0.0, 1.0) * wind;
	} else {
		float sway = sin(TIME * 1.3 + w.x * 3.0 + w.z * 2.0) * 0.06 * wind;
		VERTEX.x += sway * VERTEX.y * VERTEX.y * 4.0;
	}
	vn = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vseed = fract(sin(dot(w.xz, vec2(12.9898, 78.233))) * 43758.5453);
	vwp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vlh = vwp.y - w.y;   // world height above the plant's base
}

void fragment() {
	vec4 tx = texture(atlas, UV);
	tx.rgb = web_srgb(tx.rgb);   // (hdplus.gdshaderinc)
	// keep the cards' coverage in the small mips (mipmapped alpha shrinks thin leaves and fronds); the domed clumps
	// (UV2.y = 1) are solid whatever the painting's alpha
	vec2 px = UV * 2048.0;
	float mip = max(0.0, 0.5 * log2(max(dot(dFdx(px), dFdx(px)), dot(dFdy(px), dFdy(px)))));
	ALPHA = max(tx.a * (1.0 + mip * mip_keep), UV2.y);
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	float g = COLOR.a;   // leaves (not bark)
	vleaf = g;
	vback = 0.0;
	float far = smoothstep(far_range.x, far_range.y, length(vwp - CAMERA_POSITION_WORLD));
	// far: the painting flattens toward its local mean (one mid-tone per tree instead of light / dark leaf specks)
	tx.rgb = mix(tx.rgb, web_srgb(textureLod(atlas, UV, 6.0).rgb), far * 0.65 * step(0.75, g));
	// crown normals lean toward the sky (every mode), so the side of a crown away from the sun is never black
	vec3 vup = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	NORMAL = normalize(mix(normalize(vn + vec3(0.0, 1e-4, 0.0)), vup, 0.3 * g));
	float nk = smoothstep(0.2, 1.0, dn_night);   // the night weight (DayNight's grade: golden hour and sunrise untouched)
	vec3 c = pow(clamp(COLOR.rgb * tint, vec3(0.0), vec3(1.0)), vec3(2.2)) * tx.rgb * (1.0 + 0.15 * g);
	// lush leaves: saturation and value up (more past the near LOD)
	float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
	vec3 lush = mix(vec3(lum), c, mix(sat_near, sat_far, far)) * mix(val_near, val_far, far) * leaf_hue;
	c = mix(c, max(lush, vec3(0.0)), step(0.75, g) * (1.0 - nk));   // by moonlight the plain colour
	// by moonlight the leaves lose colour toward the moon's grey-blue (saturation x0.6), like the night land
	float lmoon = dot(c, vec3(0.2126, 0.7152, 0.0722));
	c = mix(c, lmoon * vec3(0.9, 0.98, 1.06), 0.4 * nk * g);
	ALBEDO = c;
	ROUGHNESS = 0.85;
	SPECULAR = 0.2;
	if (hd_mode > 0.5) {
		// colour variety: silvery, deep green and sun-yellowed plants, a little brightness jitter
		vec3 v1 = mix(vec3(0.88, 0.96, 0.84), vec3(1.1, 1.05, 0.74), vseed);
		vec3 v2 = mix(vec3(1.0), vec3(0.8, 0.88, 0.84), step(0.7, fract(vseed * 7.3)));
		vec3 cc = c * mix(vec3(1.0), v1 * v2 * (0.95 + 0.25 * fract(vseed * 13.1)) * vec3(1.06, 1.04, 0.9), g * (1.0 - 0.5 * far));
		cc *= mix(mix(0.8, 0.62, g), 1.0, max(smoothstep(0.0, 0.035, vlh), far * 0.6));   // darker foot and under the crown
		// HD season: deeper winter greens, dusty sun-yellowed summer foliage
		if (hdp_season.x < 0.0) cc = mix(cc, cc * vec3(0.88, 1.06, 0.86), g * -hdp_season.x * 0.5);
		else cc = mix(cc, cc * vec3(1.07, 1.0, 0.8), g * hdp_season.x * 0.5);
		NORMAL = normalize(mix(NORMAL, vup, 0.15 * g));   // HD: a little more sky
		// sunlit crowns: lighter where the crown faces the sun and toward the top
		vec3 wn = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
		float sunf = clamp(dot(wn, hd_sun_dir) * 0.5 + 0.5, 0.0, 1.0);
		float day = smoothstep(-0.05, 0.25, hd_sun_dir.y) * (1.0 - dn_night);
		cc *= mix(1.0, mix(0.86, 1.2, sunf) * mix(0.93, 1.08, smoothstep(0.02, 0.1, vlh)), g * day);
		float cloud = hdp_cloud(vwp);   // HD+ cloud shadows
		ALBEDO = cc * cloud;
		// back light (thin leaves glow against the light) and a faint warm rim, daylight only
		vback = (0.25 + 0.6 * g) * day;
		float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
		EMISSION = cc * vec3(1.0, 0.85, 0.55) * rim * 0.25 * g * cloud * day;
		if (hdp_foliage > 0.5) {
			// HD+ translucency: sunlight through the leaves and fronds, stronger at the thin outer crown; looking
			// toward the sun the leaves glow (forward scattering)
			vec3 vd = normalize(vwp - CAMERA_POSITION_WORLD);
			float fwd = pow(clamp(dot(vd, hd_sun_dir), 0.0, 1.0), 4.0);
			float thin = smoothstep(0.015, 0.08, vlh);
			vback = (0.3 + 0.75 * g * mix(0.75, 1.1, thin)) * cloud * day;
			EMISSION += cc * vec3(1.0, 0.88, 0.55) * g * thin * fwd * 0.7 * cloud * cloud * day;
		}
		ROUGHNESS = mix(0.85, 0.72, g);
		SPECULAR = 0.22 * cloud;
	}
}


void light() {
	// leaves: wrapped diffuse and softened self-shadowing (a crown's cards would shadow each other hard), so crowns
	// keep a soft, painterly volume even seen against the sun; bark is plain Lambert. Translucency (HD, HD+): light
	// through the leaves from behind, in HD's warm back-light colour.
	float ndl = dot(NORMAL, LIGHT);
	float d = mix(clamp(ndl, 0.0, 1.0), clamp((ndl + 0.55) / 1.55, 0.0, 1.0), vleaf);
	float att = mix(ATTENUATION, mix(0.45, 1.0, ATTENUATION), vleaf);
	DIFFUSE_LIGHT += LIGHT_COLOR * (d * att / PI);
	if (vback > 0.0) {
		float back = clamp(-ndl * 0.5 + 0.5, 0.0, 1.0);
		DIFFUSE_LIGHT += LIGHT_COLOR * vec3(1.0, 0.9, 0.58) * (back * back * vback * att / PI);
	}
}
