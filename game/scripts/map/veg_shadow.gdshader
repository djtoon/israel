shader_type spatial;
// v5 trees (fix): the ground shadow of one tree (TreeKit.shadow: a grid with UV.x 0..1 along the shadow, UV.y -1..1
// across). Trees cast no shadow-map shadows (small casters came out as a dithered screen-door under the soft-shadow
// filter); instead each tree multiplies the ground with a soft contact patch at its foot, a trunk stripe and its
// crown's shadow, an ellipse cast along the light (light_dir: the sun by day, the moon by night; TreeKit.sync_light).
// The grid is draped on the terrain on the GPU (hexcommon.gdshaderinc terrain_height, the terrain mesh's own
// height), so it follows hills. Weaker by moonlight (light_k, DayNight's light factor), none under HD+ cloud
// shadows, weaker in dense woods (INSTANCE_CUSTOM.a = the hex's tree density) so overlapping shadows do not pile up.
#ifdef WEB_LOOK
// web build (WEB_LOOK): the Compatibility renderer tonemaps an unshaded material's colour before blending, so a
// multiply turned the whole patch around every tree dark; a dark patch blended by alpha gives the same shadow there
render_mode blend_mix, unshaded, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled, world_vertex_coords;
#else
render_mode blend_mul, unshaded, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled, world_vertex_coords;
#endif

#include "res://scripts/map/hexcommon.gdshaderinc"
#include "res://scripts/map/hdplus.gdshaderinc"

uniform vec4 shape = vec4(0.08, 0.06, 0.03, 0.005);   // hex units: crown centre height, crown radius, crown half-height, trunk half-width
uniform vec3 light_dir = vec3(-0.4, 0.75, 0.5);        // world direction toward the light
uniform float light_k = 1.0;                            // light strength (1 sun, about 0.27 moon, 0 at the switch)
uniform float strength = 0.86;                          // crown shadow at full sun (linear: the ground at about 0.3)
uniform float contact = 0.5;                            // the patch at the foot (also at night: occlusion, not light)
uniform float max_cot = 3.0;                            // shadow length cap (a sun lower than about 18 degrees)
uniform vec3 shade : source_color = vec3(0.36, 0.40, 0.50);
global uniform float hd_mode;
global uniform float dn_night;   // DayNight: 0 day .. 1 night

varying vec2 vab;      // along / across the shadow (world units, from the trunk foot)
varying vec4 vsh;      // crown shadow centre along, half-length, half-width, trunk half-width
varying float vdens;
varying vec3 vwp;

void vertex() {
	vec3 o = MODEL_MATRIX[3].xyz;
	float sc = length(MODEL_MATRIX[0].xyz);
	vec3 d = normalize(light_dir);
	vec2 hz = -d.xz;
	float hl = length(hz);
	vec2 ax = hl > 1e-4 ? hz / hl : vec2(1.0, 0.0);
	vec2 px = vec2(-ax.y, ax.x);
	float cot = min(hl / max(d.y, 0.05), max_cot);
	float hc = shape.x * sc;
	float rh = shape.y * sc;
	float lc = hc * cot;
	float ra = rh + shape.z * sc * cot;
	float a = mix(-rh * 0.85, lc + ra, UV.x);
	float b = UV.y * rh * 1.05;
	vec2 xz = o.xz + ax * a + px * b;
	VERTEX = vec3(xz.x, terrain_height(xz) + 0.005, xz.y);
	vab = vec2(a, b);
	vsh = vec4(lc, ra, rh, shape.w * sc);
	// overlap: in a wood every spot of ground lies in about 1 + density x (shadow length) shadows; multiplied shadows
	// would pile up into a black floor (a real shadow is one layer), so each tree's share shrinks with the overlap
	vdens = 1.0 / (1.0 + clamp(INSTANCE_CUSTOM.a, 0.0, 1.0) * (0.8 + 0.7 * cot));
	vwp = VERTEX;
}

void fragment() {
	vec2 ab = vab;
	float rh = vsh.z;
	// the patch at the foot (the old contact disc)
	float foot = 1.0 - smoothstep(0.15, 1.0, length(ab) / (rh * 0.85));
	// the crown's shadow
	vec2 q = vec2((ab.x - vsh.x) / vsh.y, ab.y / rh);
	float crown = 1.0 - smoothstep(0.55, 1.0, length(q));
	// the trunk's stripe, from the foot to the crown's shadow
	float tw = vsh.w;
	float trunk = 0.0;
	if (tw > 0.0) {
		trunk = (1.0 - smoothstep(tw * 0.5, tw * 1.6, abs(ab.y))) * smoothstep(-tw, tw, ab.x)
			* (1.0 - smoothstep(vsh.x - vsh.y * 0.75, vsh.x - vsh.y * 0.35, ab.x));
	}
	float k = light_k;
	if (hd_mode > 0.5 && hdp_clouds > 0.0) {
		float cf = (1.0 - hdp_cloud(vwp)) / hdp_clouds;   // 0 sun .. 1 inside a cloud's shadow
		k *= 1.0 - 0.85 * cf;
	}
	float dens = vdens;
	float f = max(foot * contact * mix(0.1, 1.0, k), max(crown * strength * dens, trunk * 0.6) * k);
	// by moonlight a neutral grey (a blue multiply on the dark blue night ground went purple through the tonemap)
#ifdef WEB_LOOK
	vec3 sh = mix(shade, vec3(0.5), dn_night);   // multiply by mix(1, sh, f) = blend toward black by f x (1 - sh)
	ALBEDO = vec3(0.0);
	ALPHA = clamp(f, 0.0, 1.0) * (1.0 - dot(sh, vec3(0.3, 0.55, 0.15)));
#else
	ALBEDO = mix(vec3(1.0), mix(shade, vec3(0.5), dn_night), clamp(f, 0.0, 1.0));
#endif
}
