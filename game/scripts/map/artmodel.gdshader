shader_type spatial;
// Generated (image-to-3D) building models. Their vertex normals are unreliable (inward-facing on some
// shells), so shade with geometric normals from screen-space derivatives instead.
render_mode cull_disabled, diffuse_burley;

#include "res://scripts/map/hdplus.gdshaderinc"
#include "res://scripts/map/daynight.gdshaderinc"

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 albedo_col : source_color = vec4(1.0);
uniform float brighten = 1.08;
uniform vec3 tint = vec3(1.0);
// per-instance fade (unit death): ordered-dither discard, so no transparent pipeline is needed
instance uniform float fade = 1.0;
// per-instance hit flash (0..1 adds a red-white glow)
instance uniform float flash = 0.0;
// model-space height (mesh units, metres for metre-scale models) above which the mesh is cut away: removes a
// stray generator spike above the roof of some models (CityBuilder.CLIP_TOP, e.g. the Shalom Meir Tower)
uniform float clip_top = 1e9;
varying float vly;
// HD mode (HDRender): cavity AO from the texture and a contact shadow at the ground
global uniform float hd_mode;
global uniform float dn_lights;   // v5 day / night (daynight.gd): lit windows at night
uniform float is_bldg = 0.0;      // set by CityBuilder._art for buildings and landmarks (units never light up)
varying float vgh;
varying vec3 vwp;
varying float bseed;   // v5: a per-building hash (the lit share of its windows)

void vertex() {
	vly = VERTEX.y;
	bseed = fract(sin(dot(MODEL_MATRIX[3].xz, vec2(12.9898, 78.233))) * 43758.5453);
	vwp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vgh = vwp.y - MODEL_MATRIX[3].y;
}

void fragment() {
	// GLBs now carry proper normals (assets/_pipeline/add_normals.py); Godot already flips back faces
	if (vly > clip_top) discard;
	if (fade < 0.999) {
		vec2 p = floor(mod(FRAGCOORD.xy, 4.0));
		float b = mod(p.x * 0.25 + p.y * 0.5 + mod(p.x + p.y * 2.0, 3.0) * 0.1667, 1.0);
		if (b > fade) discard;
	}
	vec4 a = texture(albedo_tex, UV) * albedo_col;
	ALBEDO = a.rgb * brighten * tint;
	EMISSION = vec3(1.0, 0.55, 0.4) * flash;
	ROUGHNESS = 0.85;
	SPECULAR = 0.3;
	if (hd_mode > 0.5) {
		float lum = dot(pow(a.rgb, vec3(1.0 / 2.2)), vec3(0.3, 0.55, 0.15));
		AO = mix(0.6, 1.0, smoothstep(0.0, 0.04, vgh)) * mix(0.72, 1.0, smoothstep(0.08, 0.35, lum));
		AO_LIGHT_AFFECT = 0.3;
		float cloud = hdp_cloud(vwp);   // HD cloud shadows
		ALBEDO *= cloud;
		SPECULAR *= cloud;
	}
	float dnk = dn_k();
	if (is_bldg > 0.5 && (dnk > 0.0 || dn_lights > 0.001)) {
		vec3 wnrm = normalize(cross(dFdx(vwp), dFdy(vwp)));
		float wall = step(abs(wnrm.y), 0.55);
		// v5 night grade (daynight.gdshaderinc): walls about 55 % darker and moonlit blue, roofs darker still
		if (dnk > 0.0) ALBEDO = wall > 0.5 ? dn_wall(ALBEDO, dnk) : dn_roof(ALBEDO, dnk);
		if (dn_lights > 0.001 && vgh > 0.012) {
			// v5 lit windows on the generated building and landmark models: dark, cool texels on walls, 30-60 % of
			// a building's windows on (fixed per building), warm home light (#ffb860); tower glass lights whole floors
			float wl = dot(pow(a.rgb, vec3(1.0 / 2.2)), vec3(0.3, 0.55, 0.15));
			float glass = step(a.r * 1.08 + 0.025, a.b) * (1.0 - smoothstep(0.55, 0.7, wl));   // blue glass of towers
			float mask = max((1.0 - smoothstep(0.22, 0.38, wl)) * step(a.r, a.b * 1.5 + 0.06), glass);
			vec3 cell = floor(vwp * vec3(mix(48.0, 18.0, glass), 27.0, mix(48.0, 18.0, glass)));
			float hw = fract(sin(dot(cell, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
			float on = step(hw, dn_lit_share(bseed, dn_lights));
			vec3 lc = mix(dn_window(fract(hw * 7.13)), vec3(1.0, 0.32, 0.06), glass * 0.35);
			EMISSION += (lc * mask * on * mix(1.7, 1.4, glass) + DN_BOUNCE) * wall * dn_lights * fade;
		}
	}
}
