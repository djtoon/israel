// Shared hex math / noise / height for terrain + water shaders.
// MUST stay in sync with scripts/map/terrain_math.gd (CPU mirror used for placement + picking).
// Hex layout: pointy-top, odd-r offset, size (center->corner) = 1.0, row 0 at z = 0.

uniform sampler2D hex_data : filter_nearest, repeat_disable;   // R terrain, G feature, B owner, A flags (bytes)
uniform sampler2D hex_height : filter_nearest, repeat_disable; // R base height (world units)
uniform sampler2D hex_data2 : filter_nearest, repeat_disable;  // R cliff bits | wonder, G stream links, B base terrain+1
uniform ivec2 map_size = ivec2(1, 1);
uniform float warp_amp = 0.28;

const float SQ3 = 1.7320508;

#ifdef WEB_LOOK
// web build (WEB_LOOK): the loop counts come from uniforms the compiler cannot see through, so ANGLE's Direct3D
// shader compiler (Chrome and Edge on Windows) keeps real loops instead of unrolling every one of them (each first
// draw took tens of seconds, the terrain minutes). Same counts as the desktop constants below.
uniform int hc_n3 = 3;
uniform int hc_n4 = 4;
uniform int hc_n6 = 6;
uniform int hc_n7 = 7;
#define HC_N3 hc_n3
#define HC_N4 hc_n4
#define HC_N6 hc_n6
#define HC_N7 hc_n7
#else
#define HC_N3 3
#define HC_N4 4
#define HC_N6 6
#define HC_N7 7
#endif

uint hash2u(int x, int y) {
	uint h = (uint(x) * 1597334673u) ^ (uint(y) * 3812015801u);
	h ^= h >> 16u; h *= 0x7feb352du; h ^= h >> 15u; h *= 0x846ca68bu; h ^= h >> 16u;
	return h;
}
float hash2(int x, int y) { return float(hash2u(x, y)) / 4294967295.0; }

float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = p - i;
	int ix = int(i.x); int iy = int(i.y);
	float a = hash2(ix, iy), b = hash2(ix + 1, iy), c = hash2(ix, iy + 1), d = hash2(ix + 1, iy + 1);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float s = 0.0, a = 0.5;
	for (int i = 0; i < HC_N4; i++) { s += a * vnoise(p); p = p * 2.03 + vec2(17.1, 9.3); a *= 0.5; }
	return s;
}

vec2 warp(vec2 p) {
	return p + (vec2(vnoise(p * 0.55), vnoise(p * 0.55 + vec2(31.7, 11.3))) - 0.5) * 2.0 * warp_amp;
}

// world xz -> axial (rounded)
ivec2 axial_round(vec2 p) {
	float q = (SQ3 / 3.0 * p.x - 1.0 / 3.0 * p.y);
	float r = (2.0 / 3.0 * p.y);
	float s = -q - r;
	float rq = round(q), rr = round(r), rs = round(s);
	float dq = abs(rq - q), dr = abs(rr - r), ds = abs(rs - s);
	if (dq > dr && dq > ds) { rq = -rr - rs; } else if (dr > ds) { rr = -rq - rs; }
	return ivec2(int(rq), int(rr));
}
vec2 axial_center(ivec2 a) { return vec2(SQ3 * (float(a.x) + float(a.y) * 0.5), 1.5 * float(a.y)); }
ivec2 axial_to_offset(ivec2 a) { return ivec2(a.x + (a.y - (a.y & 1)) / 2, a.y); }
ivec2 clamp_off(ivec2 o) { return clamp(o, ivec2(0), map_size - ivec2(1)); }

const ivec2 AX_DIRS[6] = ivec2[6](ivec2(1, 0), ivec2(1, -1), ivec2(0, -1), ivec2(-1, 0), ivec2(-1, 1), ivec2(0, 1));

ivec4 hex_info(ivec2 off) {
	vec4 v = texelFetch(hex_data, clamp_off(off), 0);
	return ivec4(round(v * 255.0));
}
float hex_base(ivec2 off) { return texelFetch(hex_height, clamp_off(off), 0).r; }
bool in_map(ivec2 off) { return off.x >= 0 && off.y >= 0 && off.x < map_size.x && off.y < map_size.y; }

// terrain ids (see terrain_math.gd TERRAINS)
// 0 ocean 1 coast 2 lake 3 grassland 4 plains 5 hills 6 mountains 7 desert 8 desert_hills 9 marsh

float hex_peak(int terrain, ivec2 off, vec2 c, vec2 p) {
	float j1 = hash2(off.x * 7 + 3, off.y * 13 + 5), j2 = hash2(off.x * 11 + 1, off.y * 3 + 9);
	if (terrain == 6) {
		vec2 pc = c + (vec2(j1, j2) - 0.5) * 0.35;
		float d = length(p - pc);
		float pk = (1.0 - smoothstep(0.0, 1.05, d)) * (0.55 + 0.3 * j1);
		vec2 pc2 = c + vec2(j2 - 0.5, 0.45 * (j1 - 0.5)) * 1.1;
		pk += (1.0 - smoothstep(0.0, 0.65, length(p - pc2))) * 0.3;
		return pk;
	}
	if (terrain == 5 || terrain == 8) {
		vec2 pc = c + (vec2(j1, j2) - 0.5) * 0.6;
		float pk = (1.0 - smoothstep(0.0, 0.9, length(p - pc))) * 0.30;
		vec2 pc2 = c + (vec2(j2, j1) - 0.5) * 1.1;
		pk += (1.0 - smoothstep(0.0, 0.6, length(p - pc2))) * 0.16;
		return pk;
	}
	return 0.0;
}

// makhteshim: analytic erosion craters (oval, steep walls, flat floor). a = centre.xy, axis.zw; b = half length, half width, rim h, floor h
uniform vec4 crater_a[3];
uniform vec4 crater_b[3];
// approx. signed Euclidean distance (world units) to the crater outline, negative inside
float crater_sd(vec2 p, int i) {
	vec4 a = crater_a[i]; vec4 b = crater_b[i];
	vec2 d = p - a.xy;
	float u = dot(d, a.zw), v = dot(d, vec2(-a.w, a.z));
	// capsule (stadium): rounded, symmetric ends; overall length:width = b.x:b.y*... (b.y = b.x/4 -> 4:1)
	float au = max(abs(u) - max(b.x - b.y, 0.0), 0.0);
	return length(vec2(au, v)) - b.y + (fbm(p * 0.9 + float(i) * 7.0) - 0.5) * 0.4;
}
float crater_carve(vec2 p, float h) {
	for (int i = 0; i < HC_N3; i++) {
		if (crater_b[i].x <= 0.0) continue;
#ifdef WEB_LOOK
		// web: the capsule distance without its noise first (the noise lies in [-0.2, 0.175]): far from a crater its
		// 4-octave noise is never needed, the same result (TerrainMath.crater_carve does the same on the CPU)
		vec2 dq = p - crater_a[i].xy;
		float aq = max(abs(dot(dq, crater_a[i].zw)) - max(crater_b[i].x - crater_b[i].y, 0.0), 0.0);
		if (length(vec2(aq, dot(dq, vec2(-crater_a[i].w, crater_a[i].z)))) - crater_b[i].y > 3.2) continue;
#endif
		float sd = crater_sd(p, i);
		if (sd > 3.0) continue;
		float wall = smoothstep(-0.04, 0.3, sd);
		float lift = 1.0 - smoothstep(0.3, 1.9, sd);
		float hr = mix(h, max(h, crater_b[i].z), lift);
		float hf = crater_b[i].w + (fbm(p * 2.3) - 0.5) * 0.03;
		h = mix(hf, hr, wall);
	}
	return h;
}

// full terrain height at world xz; cliffs false skips the per-hex cliff-edge steps (HD: the makhtesh walls' shading,
// where those old steps cut the analytic crater walls into hex-long blocks; the geometry keeps them)
float terrain_height_k(vec2 p, bool cliffs) {
	vec2 pw = warp(p);
	ivec2 a0 = axial_round(pw);
	float H = 0.0, W = 0.0, P = 0.0;
	vec2 c0 = axial_center(a0);
	int cb = int(round(texelFetch(hex_data2, clamp_off(axial_to_offset(a0)), 0).r * 255.0)) & 63;
	for (int i = 0; i < HC_N7; i++) {
		ivec2 a = i == 0 ? a0 : a0 + AX_DIRS[i - 1];
		ivec2 off = axial_to_offset(a);
		vec2 c = axial_center(a);
		float d = length(pw - c);
		float w = 1.0 - smoothstep(0.35, 1.9, d);
		if (cliffs && i > 0 && ((cb >> (i - 1)) & 1) == 1) {
			float ed = SQ3 * 0.5 - dot(pw - c0, normalize(c - c0));
			w *= 1.0 - smoothstep(0.0, 0.1, ed);
		}
		float hb = hex_base(off);
		H += w * hb; W += w;
		ivec4 inf = hex_info(off);
		P += hex_peak(inf.r, off, c, pw) * ((inf.a & 4) != 0 ? 0.0 : 1.0);
	}
	float h = H / max(W, 1e-4) + P;
#ifndef WEB_LOOK
	// small surface detail on land (the web build leaves it out: 4 noise octaves per height sample; TerrainMath too)
	float land = smoothstep(-0.02, 0.06, h);
	h += (fbm(p * 1.7) - 0.5) * 0.05 * land;
#endif
	return crater_carve(p, h);
}
float terrain_height(vec2 p) { return terrain_height_k(p, true); }

// distance (in world units) from p to the nearest edge of its hex, plus the axial cell and edge direction
float hex_edge_dist(vec2 p, out ivec2 cell, out int edge_dir) {
	cell = axial_round(p);
	vec2 l = p - axial_center(cell);
	// pointy-top: edge normals at 0,60,120... degrees (pointing to neighbor centers)
	float best = -1e9; edge_dir = 0;
	for (int i = 0; i < HC_N6; i++) {
		vec2 nc = axial_center(cell + AX_DIRS[i]) - axial_center(cell);
		float k = dot(l, normalize(nc));
		if (k > best) { best = k; edge_dir = i; }
	}
	return SQ3 * 0.5 - best;
}

// HD mode: shallow reef / shore rocks. terrain.gdshader paints them on the seabed and the shore,
// water_hd.gdshader breaks foam around them (same function, so the foam hugs the rocks).
float hd_rocks(vec2 p) {
	// clusters of small boulders: a broad cluster mask times small blobs, plus a few lone rocks
	float cl = smoothstep(0.38, 0.5, fbm(p * 1.7 + vec2(3.1, 7.7)));
	float blobs = smoothstep(0.45, 0.65, vnoise(p * 16.0 + vec2(1.3, 5.2)));
	float lone = smoothstep(0.8, 0.88, vnoise(p * 9.0 + vec2(8.1, 2.2)));
	return max(cl * blobs, lone * 0.8);
}
