shader_type spatial;
// Vegetation + small props. Vertex colour * per-instance tint (INSTANCE_CUSTOM.rgb), gentle wind.
render_mode cull_disabled, diffuse_burley;

#include "res://scripts/map/hdplus.gdshaderinc"

uniform float wind = 1.0;
uniform float backlight = 0.35;
// HD mode (HDRender): per-plant colour variety, stronger warm back lighting, darker bases
global uniform float hd_mode;

varying vec3 tint;
varying vec3 vn;
varying float vseed;
varying float vlh;
varying float vwy;
varying vec3 vwp;
global uniform vec3 hd_sun_dir;   // world direction toward the sun (HDRender)

void vertex() {
	tint = INSTANCE_CUSTOM.rgb * 2.0;
	vec3 w = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	if (hd_mode > 0.5 && hdp_foliage > 0.5 && wind > 0.0) {
		// HD wind: gusts roll in from the sea as a slow wave across the map; each plant bends with them (two
		// axes, quadratic with height, so trunks stay planted) and its leaves flutter a little faster
		float gust = 0.55 + 0.45 * sin(TIME * 0.45 - w.x * 0.35 + w.z * 0.12) * sin(TIME * 0.21 - w.x * 0.13 + 1.7);
		float s1 = sin(TIME * 1.1 + w.x * 3.0 + w.z * 2.0) * (0.55 + 0.45 * gust) + 0.35 * gust;
		float s2 = sin(TIME * 0.83 + w.z * 2.6 + w.x * 0.7 + 1.3) * 0.4;
		float hh = VERTEX.y * VERTEX.y * 4.0;
		VERTEX.x += s1 * 0.075 * wind * hh;
		VERTEX.z += s2 * 0.075 * wind * hh;
		float leaf = clamp((COLOR.g - max(COLOR.r, COLOR.b)) * 8.0, 0.0, 1.0);
		float fl = sin(TIME * 6.5 + dot(VERTEX, vec3(97.0, 61.0, 83.0))) * (0.4 + 0.6 * gust);
		VERTEX.y += fl * 0.0035 * leaf * clamp(VERTEX.y * 10.0, 0.0, 1.0) * wind;
	} else {
		float sway = sin(TIME * 1.3 + w.x * 3.0 + w.z * 2.0) * 0.06 * wind;
		VERTEX.x += sway * VERTEX.y * VERTEX.y * 4.0;
	}
	vn = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vseed = fract(sin(dot(w.xz, vec2(12.9898, 78.233))) * 43758.5453);
	vwp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vwy = vwp.y;
	vlh = vwy - w.y;   // world height above the plant's base
}

void fragment() {
	NORMAL = normalize(vn + vec3(0.0, 1e-4, 0.0));
	vec3 c = pow(clamp(COLOR.rgb * tint, vec3(0.0), vec3(1.0)), vec3(2.2));
	ALBEDO = c;
	ROUGHNESS = 0.85;
	SPECULAR = 0.25;
	BACKLIGHT = c * backlight;
	if (hd_mode > 0.5) {
		// colour variety: silvery olive, deep green and sun-yellowed foliage, a little brightness jitter
		float g = clamp((c.g - max(c.r, c.b)) * 8.0, 0.0, 1.0);   // foliage only (not trunks, rocks, sails)
		vec3 v1 = mix(vec3(0.86, 0.95, 0.80), vec3(1.12, 1.06, 0.70), vseed);
		vec3 v2 = mix(vec3(1.0), vec3(0.78, 0.86, 0.82), step(0.7, fract(vseed * 7.3)));
		vec3 cc = c * mix(vec3(1.0), v1 * v2 * (0.95 + 0.3 * fract(vseed * 13.1)) * vec3(1.08, 1.05, 0.88), g);
		cc *= mix(mix(0.85, 0.6, g), 1.0, smoothstep(0.0, 0.035, vlh));   // darker base / under the canopy (rocks: a little)
		// HD season: deeper winter greens, dusty sun-yellowed summer foliage
		if (hdp_season.x < 0.0) cc = mix(cc, cc * vec3(0.88, 1.06, 0.86), g * -hdp_season.x * 0.5);
		else cc = mix(cc, cc * vec3(1.07, 1.0, 0.8), g * hdp_season.x * 0.5);
		// soften foliage normals toward the sky so fronds facing away from the sun are not black
		vec3 vup = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
		NORMAL = normalize(mix(NORMAL, vup, 0.45 * g));
		// sunlit crowns: lighter where the canopy faces the sun and toward the top
		vec3 wn = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
		float sunf = clamp(dot(wn, hd_sun_dir) * 0.5 + 0.5, 0.0, 1.0);
		cc *= mix(1.0, mix(0.85, 1.25, sunf) * mix(0.92, 1.1, smoothstep(0.02, 0.1, vlh)), g);
		// wet rocks and hulls at the waterline (darker, glossier)
		float wet = (1.0 - g) * (1.0 - smoothstep(-0.004, 0.01, vwy));
		cc *= mix(1.0, 0.6, wet);
		// sunlit rock tops: warm, light kurkar (wind 0 props: rocks and boats)
		cc *= mix(1.0, mix(0.9, 1.3, sunf), (1.0 - g) * (1.0 - wind));
		float cloud = hdp_cloud(vwp);   // HD cloud shadows
		ALBEDO = cc * cloud;
		// translucency (back light) and a warm rim so leaves glow against the light
		BACKLIGHT = cc * vec3(1.0, 0.9, 0.55) * (0.35 + 0.8 * g);
		float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
		EMISSION = cc * vec3(1.0, 0.85, 0.55) * rim * 0.35 * g * cloud;
		if (hdp_foliage > 0.5) {
			// HD foliage translucency: sunlight through thin fronds and leaves. The transmitted light keeps HD's warm
			// back-light colour (the lab's yellow-green tint turned palms lime with the sun behind the viewer) and
			// is a little stronger at the thin outer crown; looking toward the sun, leaves glow (forward scattering)
			vec3 vd = normalize(vwp - CAMERA_POSITION_WORLD);
			float fwd = pow(clamp(dot(vd, hd_sun_dir), 0.0, 1.0), 4.0);
			float thin = smoothstep(0.015, 0.08, vlh);
			BACKLIGHT = cc * vec3(1.0, 0.9, 0.58) * (0.35 + 0.8 * g * mix(0.75, 1.1, thin)) * cloud;
			EMISSION += cc * vec3(1.0, 0.88, 0.55) * g * thin * fwd * 0.8 * cloud * cloud;
		}
		ROUGHNESS = mix(mix(0.85, 0.7, g), 0.35, wet);
		SPECULAR = 0.25 * cloud;
	}
}
