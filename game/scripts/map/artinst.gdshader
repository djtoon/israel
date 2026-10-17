shader_type spatial;
// Instanced art-builder buildings (ArtKit). Generated meshes have unreliable vertex normals, so shade with
// geometric normals; INSTANCE_CUSTOM.rgb * 2 tints each copy (colour jitter, stone vs white plaster).
render_mode cull_disabled, diffuse_burley;

#include "res://scripts/map/hdplus.gdshaderinc"
#include "res://scripts/map/daynight.gdshaderinc"
uniform float is_veg = 0.0;   // HD foliage: set by ArtKit for veg_* models (city palms and street trees)
uniform float is_shore = 0.0; // HD decals: shore rocks and ledges get no city grime (set by ArtKit)
global uniform vec3 hd_sun_dir;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 albedo_col : source_color = vec4(1.0);
// HD mode (HDRender): cavity AO from the texture, contact shadow at the ground, roughness variation
global uniform float hd_mode;
global uniform float dn_lights;   // v5 day / night (daynight.gd): lit windows at night
varying float vgh;
varying float vwy;

varying vec3 tint;
varying vec3 wn;
varying float whiten;
varying vec3 vwp;
varying float bseed;   // v5: a per-copy hash (the lit share of its windows)

void vertex() {
	bseed = fract(sin(dot(MODEL_MATRIX[3].xz, vec2(12.9898, 78.233))) * 43758.5453);
	tint = INSTANCE_CUSTOM.rgb * 2.0;
	wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	whiten = INSTANCE_CUSTOM.a;     // 0 = keep texture colour, 1 = whitewash plaster (White City)
	vwy = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
	vgh = vwy - MODEL_MATRIX[3].y;   // world height above the model base
	if (is_veg > 0.5 && hdp_foliage > 0.5 && hd_mode > 0.5) {
		// HD wind (same gust field as props.gdshader): bend in world units, quadratic with height
		vec3 w = MODEL_MATRIX[3].xyz;
		float gust = 0.55 + 0.45 * sin(TIME * 0.45 - w.x * 0.35 + w.z * 0.12) * sin(TIME * 0.21 - w.x * 0.13 + 1.7);
		float s1 = sin(TIME * 1.1 + w.x * 3.0 + w.z * 2.0) * (0.55 + 0.45 * gust) + 0.35 * gust;
		float s2 = sin(TIME * 0.83 + w.z * 2.6 + w.x * 0.7 + 1.3) * 0.4;
		float hh = vgh * vgh * 0.32;
		vec3 dw = vec3(s1, 0.0, s2) * hh;
		dw.y += sin(TIME * 6.5 + dot(VERTEX, vec3(9.7, 6.1, 8.3))) * 0.0006 * smoothstep(0.05, 0.15, vgh) * gust;
		VERTEX += inverse(mat3(MODEL_MATRIX)) * dw;
	}
	vwp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// GLBs now carry proper normals (assets/_pipeline/add_normals.py); Godot already flips back faces
	vec3 a = texture(albedo_tex, UV).rgb * albedo_col.rgb;
	// work in display (sRGB-ish) space so the window/shadow threshold matches what the eye sees
	float lum = dot(pow(a, vec3(1.0 / 2.2)), vec3(0.3, 0.55, 0.15));
	// round-5 look: keep the model's own colours (sandstone, brown mid-rises, orange roofs); only lift the
	// pale plaster of Bauhaus-type walls toward white, windows and shadows stay dark
	vec3 white = vec3(0.86, 0.85, 0.82);
	a = mix(a, white, whiten * smoothstep(0.22, 0.42, lum));
	ALBEDO = a * 1.06 * tint;
	ROUGHNESS = 0.85;
	SPECULAR = 0.3;
	if (hd_mode > 0.5) {
		AO = mix(0.55, 1.0, smoothstep(0.0, 0.05, vgh)) * mix(0.7, 1.0, smoothstep(0.08, 0.35, lum));
		AO_LIGHT_AFFECT = 0.35;
		// a touch brighter and warmer (sun-baked stone); wet, darker and glossier at the waterline (quays, shore rocks)
		float wet = 1.0 - smoothstep(-0.004, 0.012, vwy);
		ALBEDO *= vec3(1.07, 1.03, 0.96) * mix(1.0, 0.55, wet);
		ROUGHNESS = mix(clamp(0.92 - lum * 0.25, 0.6, 0.95), 0.35, wet);
		if (hdp_decals > 0.5 && is_veg < 0.5 && is_shore < 0.5) {
			// HD city grime: splash dirt at the foot of walls, faint rain streaks running down from the roof line
			float streak = smoothstep(0.55, 0.9, fract(sin(floor(vwp.x * 260.0 + vwp.z * 190.0) * 12.9898) * 43758.5));
			float topk = smoothstep(0.02, 0.12, vgh) * (0.6 + 0.4 * fract(vgh * 37.0));
			ALBEDO *= mix(1.0, 0.86, 1.0 - smoothstep(0.0, 0.012, vgh)) * mix(1.0, 0.9, streak * topk * (1.0 - wet));
		}
		float cloud = hdp_cloud(vwp);
		ALBEDO *= cloud;
		SPECULAR *= cloud;
		if (is_veg > 0.5 && hdp_foliage > 0.5) {
			// HD translucency for the art-kit trees: leaves (green texels) pass warm light from behind. Warm and
			// gentle (the lab's yellow-green tint made palms lime with the sun behind the viewer); the glow only
			// shows when looking toward the sun
			float g = clamp((ALBEDO.g - max(ALBEDO.r, ALBEDO.b)) * 10.0, 0.0, 1.0);
			BACKLIGHT = ALBEDO * vec3(1.0, 0.9, 0.62) * (0.15 + 0.5 * g);
			vec3 vd = normalize(vwp - CAMERA_POSITION_WORLD);
			EMISSION = ALBEDO * vec3(1.0, 0.88, 0.55) * g * pow(clamp(dot(vd, hd_sun_dir), 0.0, 1.0), 4.0) * 0.7 * cloud;
		}
	}
	// v5 night grade (daynight.gdshaderinc): building walls about 55 % darker and moonlit blue, roofs darker still;
	// street trees and shore rocks get the land's grade
	float dnk = dn_k();
	if (dnk > 0.0) {
		bool bwall = is_veg < 0.5 && is_shore < 0.5;
		ALBEDO = !bwall ? dn_land(ALBEDO, dnk) : (abs(wn.y) < 0.55 ? dn_wall(ALBEDO, dnk) : dn_roof(ALBEDO, dnk));
	}
	if (dn_lights > 0.001 && is_veg < 0.5 && is_shore < 0.5 && abs(wn.y) < 0.55 && vgh > 0.012) {
		// v5 lit windows on the art-kit buildings: the texture's dark, cool texels on walls, 30-60 % of a building's
		// windows on (fixed per building), warm home light (#ffb860); tower glass lights whole floors, warm too
		float wl = dot(pow(a, vec3(1.0 / 2.2)), vec3(0.3, 0.55, 0.15));
		float glass = step(a.r * 1.08 + 0.025, a.b) * (1.0 - smoothstep(0.55, 0.7, wl));   // blue glass of towers
		float mask = max((1.0 - smoothstep(0.22, 0.38, wl)) * step(a.r, a.b * 1.5 + 0.06), glass);
		vec3 wq = vwp * vec3(mix(48.0, 18.0, glass), 27.0, mix(48.0, 18.0, glass));
		vec3 cell = floor(wq);
		// stone houses with few dark window texels (old towns, villages): a small window in each storey x bay cell
		vec2 wf = abs(fract(vec2(abs(wn.x) > abs(wn.z) ? wq.z : wq.x, wq.y)) - 0.5);
		mask = max(mask, step(wf.x, 0.17) * step(wf.y, 0.2) * (1.0 - glass));
		float hw = fract(sin(dot(cell, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
		float on = step(hw, dn_lit_share(bseed, dn_lights));
		vec3 lc = mix(dn_window(fract(hw * 7.13)), vec3(1.0, 0.32, 0.06), glass * 0.35);
		EMISSION += (lc * mask * on * mix(1.7, 1.4, glass) + DN_BOUNCE) * dn_lights;
	}
}
