// HD effects ported from the HD lab (scripts/map/hdplus.gd sets these globals when HD is on; every one is 0 in SD,
// so SD renders exactly as before, and `--fx=none` gives the plain HD of before the port).
global uniform float hdp_clouds;      // cloud-shadow strength (0 = off)
global uniform float hdp_caustics;    // seabed caustics strength
global uniform float hdp_terrain;     // height-blended / triplanar terrain, cliff and far-field fixes (0 or 1)
global uniform float hdp_foliage;     // foliage translucency + wind (0 or 1)
global uniform float hdp_decals;      // decal masks: worn roads, wet sand, field edges, city grime (0 or 1)
global uniform vec4 hdp_season;       // x: -1 winter (green) .. 0 spring (= HD) .. +1 summer (dry), y: cloud cover
global uniform sampler2D hdp_cloud_tex;   // assets/textures/hd/hdp_clouds.png (tileable, continuous field)

// tileable sample of a global texture (global uniforms take no repeat hint): fract + explicit gradients, no seam
float hdp_tile(vec2 uv) {
	return textureGrad(hdp_cloud_tex, fract(uv), dFdx(uv), dFdy(uv)).r;
}

// light multiplier under drifting cloud shadows at world position w (1 = full sun). Two layers at different
// scales and drift speeds so the 15-unit tile never repeats visibly. Height shifts the lookup along the
// fixed sun azimuth, so tall models and the ground below them agree.
float hdp_cloud(vec3 w) {
	if (hdp_clouds <= 0.0) return 1.0;
	vec2 p = w.xz + vec2(-0.81, 0.40) * w.y * 2.0;   // toward the HD sun (azimuth -64 deg, about 25 deg high)
	vec2 drift = vec2(0.055, 0.022) * TIME;          // slow sea breeze from the west
	vec2 u1 = (p - drift) / 15.0;
	vec2 u2 = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * (p - drift * 1.35) / 6.5 + 0.37;
	float a = hdp_tile(u1) * 0.65 + hdp_tile(u2) * 0.35;
	float cov = 0.53 - hdp_season.y * 0.04;
	float c = smoothstep(cov, cov + 0.11, a);
	return 1.0 - hdp_clouds * c;
}
