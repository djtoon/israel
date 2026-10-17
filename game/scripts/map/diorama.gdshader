shader_type spatial;
// Art-builder dioramas (generated GLBs on a slab). The slab is cut away at the terrain surface and the
// diorama's own ground layer dissolves into the terrain toward its rim, so the model sits in the map.
render_mode cull_back, diffuse_burley;

#include "res://scripts/map/hexcommon.gdshaderinc"
#include "res://scripts/map/hdplus.gdshaderinc"
global uniform float hd_mode;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 albedo_col : source_color = vec4(1.0);
uniform float plinth_top = 0.0;   // world y of the diorama ground after placement
uniform vec2 center = vec2(0.0);
uniform float radius = 0.8;
uniform float dark_lift = 0.0;   // v3r: brightens very dark albedo (the dark-wood kibbutz read as black from far out)

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// slab sides / anything below the slab top
	if (wpos.y < plinth_top - 0.006) discard;
	// below the actual terrain surface
	float th = terrain_height(wpos.xz);
	if (wpos.y < th - 0.006) discard;
	// ground layer: dissolve toward the rim (noisy edge) so the terrain shows through
	float ground = 1.0 - smoothstep(plinth_top + 0.006, plinth_top + 0.03, wpos.y);
	float r = length(wpos.xz - center) / radius;
	float n = vnoise(wpos.xz * 8.0) * 0.6 + vnoise(wpos.xz * 23.0) * 0.4;
	if (ground > 0.5 && r + (n - 0.5) * 0.5 > 0.62) discard;
	vec4 a = texture(albedo_tex, UV) * albedo_col;
	ALBEDO = mix(a.rgb, pow(a.rgb, vec3(0.62)) * 1.12, dark_lift);
	if (hd_mode > 0.5) ALBEDO *= hdp_cloud(wpos);   // HD cloud shadows
	ROUGHNESS = 0.82;
	SPECULAR = 0.3;
}
