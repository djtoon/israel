class_name SimHex
extends RefCounted
## Hex math for the simulation (pointy-top, odd-r offset, same layout as map.json).
## Kept separate from scripts/map/ so the sim has no rendering dependency.

const DIRS_EVEN := [Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
const DIRS_ODD := [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 1)]


static func neighbors(q: int, r: int) -> Array:
	var out := []
	var dirs: Array = DIRS_ODD if (r & 1) == 1 else DIRS_EVEN
	for d in dirs:
		out.append(Vector2i(q + d.x, r + d.y))
	return out


static func to_cube(q: int, r: int) -> Vector3i:
	var x := q - (r - (r & 1)) / 2
	return Vector3i(x, -x - r, r)


static func distance(a: Vector2i, b: Vector2i) -> int:
	var ca := to_cube(a.x, a.y)
	var cb := to_cube(b.x, b.y)
	return maxi(maxi(absi(ca.x - cb.x), absi(ca.y - cb.y)), absi(ca.z - cb.z))


## All offset coords within `radius` of (q, r), including the centre.
static func within(q: int, r: int, radius: int) -> Array:
	var out := []
	for dr in range(-radius, radius + 1):
		for dq in range(-radius - 1, radius + 2):
			var p := Vector2i(q + dq, r + dr)
			if distance(Vector2i(q, r), p) <= radius:
				out.append(p)
	return out


static func ring(q: int, r: int, radius: int) -> Array:
	var out := []
	for p in within(q, r, radius):
		if distance(Vector2i(q, r), p) == radius:
			out.append(p)
	return out


static func key(q: int, r: int) -> int:
	return r * 4096 + q


static func from_key(k: int) -> Vector2i:
	return Vector2i(k % 4096, k / 4096)
