class_name TerrainMath
extends RefCounted
## CPU mirror of hexcommon.gdshaderinc (hex math, noise, terrain height).
## Hex layout: pointy-top, odd-r offset, size (center->corner) 1.0. Row r -> z = 1.5 r (north = -z).

const SQ3 := 1.7320508
const M32 := 0xFFFFFFFF
const TERRAINS := ["ocean", "coast", "lake", "grassland", "plains", "hills", "mountains", "desert", "desert_hills", "marsh"]
const FEATURES := ["none", "forest", "orchard", "wadi", "oasis", "reef"]
const AX_DIRS := [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
const WARP_AMP := 0.28
const CLIFF_W := 0.1

var cols := 1
var rows := 1
var terr := PackedByteArray()   # cols*rows terrain ids
var base := PackedFloat32Array() # cols*rows base heights
var cliff := PackedByteArray()   # cols*rows cliff edge bits (map.json cliff_edges)
var craters: Array = []   # [{c: Vector2, ax: Vector2, L, W, rim, floor}] makhteshim
var urb := PackedByteArray()     # cols*rows 1 = urban (hill bumps damped)
var web_lite := GfxTier.web()    # web build: no small surface detail (as hexcommon.gdshaderinc's WEB_LOOK)


static func hash2u(x: int, y: int) -> int:
	var h := (((x & M32) * 1597334673) & M32) ^ (((y & M32) * 3812015801) & M32)
	h ^= h >> 16
	h = (h * 0x7feb352d) & M32
	h ^= h >> 15
	h = (h * 0x846ca68b) & M32
	h ^= h >> 16
	return h


static func hash2(x: int, y: int) -> float:
	return float(hash2u(x, y)) / 4294967295.0


static func vnoise(p: Vector2) -> float:
	var ix := int(floorf(p.x)); var iy := int(floorf(p.y))
	var fx := p.x - floorf(p.x); var fy := p.y - floorf(p.y)
	var a := hash2(ix, iy); var b := hash2(ix + 1, iy); var c := hash2(ix, iy + 1); var d := hash2(ix + 1, iy + 1)
	var ux := fx * fx * (3.0 - 2.0 * fx); var uy := fy * fy * (3.0 - 2.0 * fy)
	return lerpf(lerpf(a, b, ux), lerpf(c, d, ux), uy)


static func fbm(p: Vector2) -> float:
	var s := 0.0; var a := 0.5
	for i in 4:
		s += a * vnoise(p)
		p = p * 2.03 + Vector2(17.1, 9.3)
		a *= 0.5
	return s


static func warp(p: Vector2) -> Vector2:
	return p + (Vector2(vnoise(p * 0.55), vnoise(p * 0.55 + Vector2(31.7, 11.3))) - Vector2(0.5, 0.5)) * 2.0 * WARP_AMP


static func axial_round(p: Vector2) -> Vector2i:
	var q := SQ3 / 3.0 * p.x - 1.0 / 3.0 * p.y
	var r := 2.0 / 3.0 * p.y
	var s := -q - r
	var rq := roundf(q); var rr := roundf(r); var rs := roundf(s)
	var dq := absf(rq - q); var dr := absf(rr - r); var ds := absf(rs - s)
	if dq > dr and dq > ds:
		rq = -rr - rs
	elif dr > ds:
		rr = -rq - rs
	return Vector2i(int(rq), int(rr))


static func axial_center(a: Vector2i) -> Vector2:
	return Vector2(SQ3 * (a.x + a.y * 0.5), 1.5 * a.y)


static func axial_to_offset(a: Vector2i) -> Vector2i:
	return Vector2i(a.x + (a.y - (a.y & 1)) / 2, a.y)


static func offset_to_axial(o: Vector2i) -> Vector2i:
	return Vector2i(o.x - (o.y - (o.y & 1)) / 2, o.y)


static func offset_center(q: int, r: int) -> Vector2:
	return Vector2(SQ3 * (q + 0.5 * (r & 1)), 1.5 * r)


static func world_to_offset(p: Vector2) -> Vector2i:
	return axial_to_offset(axial_round(p))


static func offset_neighbors(o: Vector2i) -> Array:
	var a := offset_to_axial(o)
	var out := []
	for d in AX_DIRS:
		out.append(axial_to_offset(a + d))
	return out


func _idx(off: Vector2i) -> int:
	var q := clampi(off.x, 0, cols - 1); var r := clampi(off.y, 0, rows - 1)
	return r * cols + q


func hex_peak(t: int, off: Vector2i, c: Vector2, p: Vector2) -> float:
	var j1 := hash2(off.x * 7 + 3, off.y * 13 + 5); var j2 := hash2(off.x * 11 + 1, off.y * 3 + 9)
	if t == 6:
		var pc := c + (Vector2(j1, j2) - Vector2(0.5, 0.5)) * 0.35
		var pk := (1.0 - smoothstep(0.0, 1.05, p.distance_to(pc))) * (0.55 + 0.3 * j1)
		var pc2 := c + Vector2(j2 - 0.5, 0.45 * (j1 - 0.5)) * 1.1
		pk += (1.0 - smoothstep(0.0, 0.65, p.distance_to(pc2))) * 0.3
		return pk
	if t == 5 or t == 8:
		var pc := c + (Vector2(j1, j2) - Vector2(0.5, 0.5)) * 0.6
		var pk := (1.0 - smoothstep(0.0, 0.9, p.distance_to(pc))) * 0.30
		var pc2 := c + (Vector2(j2, j1) - Vector2(0.5, 0.5)) * 1.1
		pk += (1.0 - smoothstep(0.0, 0.6, p.distance_to(pc2))) * 0.16
		return pk
	return 0.0


func height(p: Vector2) -> float:
	var pw := warp(p)
	var a0 := axial_round(pw)
	var H := 0.0; var W := 0.0; var P := 0.0
	var c0 := axial_center(a0)
	var cb := cliff[_idx(axial_to_offset(a0))] if cliff.size() > 0 else 0
	for i in 7:
		var a: Vector2i = a0 if i == 0 else a0 + AX_DIRS[i - 1]
		var off := axial_to_offset(a)
		var c := axial_center(a)
		var d := pw.distance_to(c)
		var w := 1.0 - smoothstep(0.35, 1.9, d)
		if i > 0 and (cb >> (i - 1)) & 1 == 1:
			# cliff edge: the neighbour only blends in right at the shared edge -> a steep face
			var ed := SQ3 * 0.5 - (pw - c0).dot((c - c0).normalized())
			w *= 1.0 - smoothstep(0.0, CLIFF_W, ed)
		var k := _idx(off)
		H += w * base[k]; W += w
		P += hex_peak(terr[k], off, c, pw) * (0.0 if urb.size() > k and urb[k] == 1 else 1.0)
	var h := H / maxf(W, 1e-4) + P
	if not web_lite:
		var land := smoothstep(-0.02, 0.06, h)
		h += (fbm(p * 1.7) - 0.5) * 0.05 * land
	return crater_carve(p, h)


func crater_sd(p: Vector2, cr: Dictionary, i: int) -> float:
	var d: Vector2 = p - cr["c"]
	var ax: Vector2 = cr["ax"]
	var u := d.dot(ax); var v := d.dot(Vector2(-ax.y, ax.x))
	var L: float = cr["L"]; var W: float = cr["W"]
	# capsule (stadium): rounded, symmetric ends, ~4:1 overall (mirrors hexcommon.gdshaderinc)
	var au := maxf(absf(u) - maxf(L - W, 0.0), 0.0)
	return Vector2(au, v).length() - W + (fbm(p * 0.9 + Vector2.ONE * float(i) * 7.0) - 0.5) * 0.4

func crater_carve(p: Vector2, h: float) -> float:
	for i in craters.size():
		var cr: Dictionary = craters[i]
		# perf60: the capsule distance without its noise first: the noise term of crater_sd lies within [-0.2, 0.175],
		# so a point whose plain distance is over 3.2 is past 3.0 for sure (the same result, without 16 noise lookups)
		var d: Vector2 = p - cr["c"]
		var ax: Vector2 = cr["ax"]
		var au := maxf(absf(d.dot(ax)) - maxf(float(cr["L"]) - float(cr["W"]), 0.0), 0.0)
		if Vector2(au, d.dot(Vector2(-ax.y, ax.x))).length() - float(cr["W"]) > 3.2:
			continue
		var sd := crater_sd(p, cr, i)
		if sd > 3.0:
			continue
		var wall := smoothstep(-0.04, 0.3, sd)
		var lift := 1.0 - smoothstep(0.3, 1.9, sd)
		var hr := lerpf(h, maxf(h, cr["rim"]), lift)
		var hf: float = cr["floor"] + (fbm(p * 2.3) - 0.5) * 0.03
		h = lerpf(hf, hr, wall)
	return h
