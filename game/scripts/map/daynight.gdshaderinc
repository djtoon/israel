// v5 day / night (v5-daynight-fix): the night grade of surfaces, shared by terrain / building / artinst / artmodel.
// daynight.gd drives dn_night (0 by day, 0.15-0.2 at the golden hour and sunrise, 1 at night). The grade only starts
// above 0.2, so noon, sunrise and the golden hour are untouched.
// At night the eye sees luminance, not colour: pale ground and walls (desert, limestone, white plaster) were lit by the
// same moon as the dark green land and stayed twice as bright, a day-coloured seam (critic v5 D1 / D2), and the blue
// ambient on straw-yellow albedo turned it olive-green (D3). So, in linear albedo:
//   - luminance above `tgt` is compressed with the power `g` (contrast inside the desert survives, its level drops),
//   - colour is desaturated toward a cool moonlit grey-blue (never a green multiply).
global uniform float dn_night;

float dn_k() {
	return smoothstep(0.2, 1.0, dn_night);
}

// c: linear albedo; k: night weight (dn_k()); tgt: luminance kept as is; g: compression power above tgt (1 = none);
// sat: saturation kept (1 = all); cool: moonlit tint of the desaturated colour
vec3 dn_grade(vec3 c, float k, float tgt, float g, float sat, vec3 cool) {
	float L = dot(c, vec3(0.2126, 0.7152, 0.0722));
	float Ln = L > tgt ? tgt * pow(L / tgt, g) : L;
	vec3 d = mix(vec3(L) * cool, c, sat) * (Ln / max(L, 1e-5));
	return mix(c, d, k);
}

// the land: everything at about the brightness of the green coastal plain, grey-blue rather than green
vec3 dn_land(vec3 c, float k) {
	return dn_grade(c, k, 0.095, 0.14, 0.42, vec3(1.03, 1.0, 0.95));   // (the moonlight itself is blue)
}

// walls (about -55 % on pale stone and plaster, moonlit blue) and roofs (darker still): the city reads as a warm-lit
// grid of windows on a dark mass
vec3 dn_wall(vec3 c, float k) {
	return dn_grade(c, k, 0.08, 0.25, 0.4, vec3(0.92, 0.97, 1.08)) * mix(1.0, 0.72, k);
}

vec3 dn_roof(vec3 c, float k) {
	return dn_grade(c, k, 0.06, 0.25, 0.35, vec3(0.92, 0.97, 1.08)) * mix(1.0, 0.56, k);
}

// lit windows: warm home light (about 2700 K, #ffb860 on screen) in linear, two shades, deeper than the target
// because AgX and the night grade pull bright colours toward white (the old 4.2 x pale orange showed as white)
vec3 dn_window(float h) {
	return mix(vec3(1.0, 0.17, 0.008), vec3(1.0, 0.24, 0.02), h);
}

// a faint warm bounce of the town's light on every lit wall (soft amber, so the moonlit blue walls do not go plum)
const vec3 DN_BOUNCE = vec3(0.010, 0.0065, 0.0035);

// the share of a building's windows that are lit: 30-60 %, fixed per building (s: a per-building hash), ramped in
// with the lights at dusk
float dn_lit_share(float s, float lights) {
	return mix(0.3, 0.6, s) * (0.75 * smoothstep(0.0, 0.5, lights) + 0.25 * smoothstep(0.6, 1.0, lights));
}
