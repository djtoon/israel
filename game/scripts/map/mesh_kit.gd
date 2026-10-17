class_name MeshKit
extends RefCounted
## Procedural low-poly meshes for vegetation, buildings and boats (stand-ins until art models land).


static func _ring(st: SurfaceTool, y: float, r: float, n: int, col: Color, cx := 0.0, cz := 0.0) -> Array:
	var pts := []
	for i in n:
		var a := TAU * i / n
		pts.append(Vector3(cx + cos(a) * r, y, cz + sin(a) * r))
	return pts


static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	var n := (b - a).cross(c - a).normalized()
	for v in [a, b, c]:
		st.set_color(col); st.set_normal(n); st.add_vertex(v)


static func _tri_smooth(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color, center: Vector3) -> void:
	for v in [a, b, c]:
		st.set_color(col); st.set_normal((v - center).normalized()); st.add_vertex(v)


static func _cone(st: SurfaceTool, base_y: float, top_y: float, r: float, n: int, col: Color, col_top: Color, off := Vector3.ZERO) -> void:
	var top := Vector3(0, top_y, 0) + off
	var pts := _ring(st, base_y, r, n, col)
	for i in n:
		var a: Vector3 = pts[i] + off; var b: Vector3 = pts[(i + 1) % n] + off
		var mid := (a + b) * 0.5
		var nrm := Vector3(mid.x - off.x, r * r / maxf(top_y - base_y, 0.01) * 0.6, mid.z - off.z).normalized()
		st.set_color(col); st.set_normal(nrm); st.add_vertex(a)
		st.set_color(col_top); st.set_normal(nrm); st.add_vertex(top)
		st.set_color(col); st.set_normal(nrm); st.add_vertex(b)
	var c := Vector3(0, base_y, 0) + off
	for i in n:
		_tri(st, c, pts[(i + 1) % n] + off, pts[i] + off, col.darkened(0.3))


static func _cyl(st: SurfaceTool, y0: float, y1: float, r0: float, r1: float, n: int, col: Color, off0 := Vector3.ZERO, off1 := Vector3.ZERO) -> void:
	for i in n:
		var a0 := TAU * i / n; var a1 := TAU * (i + 1) / n
		var p00 := Vector3(cos(a0) * r0, y0, sin(a0) * r0) + off0
		var p01 := Vector3(cos(a1) * r0, y0, sin(a1) * r0) + off0
		var p10 := Vector3(cos(a0) * r1, y1, sin(a0) * r1) + off1
		var p11 := Vector3(cos(a1) * r1, y1, sin(a1) * r1) + off1
		var n0 := Vector3(cos(a0), 0, sin(a0)); var n1 := Vector3(cos(a1), 0, sin(a1))
		for pv in [[p00, n0], [p10, n0], [p11, n1], [p00, n0], [p11, n1], [p01, n1]]:
			st.set_color(col); st.set_normal(pv[1]); st.add_vertex(pv[0])


static func _blob(st: SurfaceTool, c: Vector3, r: Vector3, col: Color, col2: Color, seg := 7, rings := 5) -> void:
	# squashed UV sphere with smooth normals; colour darker underneath
	for j in rings:
		var t0 := PI * j / rings; var t1 := PI * (j + 1) / rings
		for i in seg:
			var p0 := TAU * i / seg; var p1 := TAU * (i + 1) / seg
			var quad := []
			for tp in [[t0, p0], [t1, p0], [t1, p1], [t0, p1]]:
				var u := Vector3(sin(tp[0]) * cos(tp[1]), cos(tp[0]), sin(tp[0]) * sin(tp[1]))
				quad.append(u)
			for idx in [0, 1, 2, 0, 2, 3]:
				var u: Vector3 = quad[idx]
				# clumpy foliage: deterministic radial jitter
				var jit := 1.0 + 0.16 * sin(u.x * 11.0 + u.z * 7.0) * cos(u.y * 9.0 + u.x * 5.0)
				var cc := col2.lerp(col, clampf(u.y * 0.5 + 0.6, 0.0, 1.0))
				st.set_color(cc); st.set_normal(u); st.add_vertex(c + u * r * jit)


static func _finish(st: SurfaceTool) -> ArrayMesh:
	st.index()
	return st.commit()


# v5 trees: the vegetation meshes are TreeKit species (trunks, branches and painted leaf cards, with LODs);
# TerrainRenderer.mm() recognises them (meta "tree_kind") and gives them their own material and contact shadows.
static func cypress() -> ArrayMesh:
	return TreeKit.mesh("cypress")


static func pine() -> ArrayMesh:
	return TreeKit.mesh("pine")   # Aleppo pine


static func broadleaf() -> ArrayMesh:
	return TreeKit.mesh("broad")


static func olive() -> ArrayMesh:
	return TreeKit.mesh("olive")


static func citrus() -> ArrayMesh:
	return TreeKit.mesh("citrus")


static func palm() -> ArrayMesh:
	return TreeKit.mesh("palm")   # date palm


static func fanpalm() -> ArrayMesh:
	return TreeKit.mesh("fanpalm")   # Washingtonia


static func rock() -> ArrayMesh:
	# irregular boulder: jittered squashed sphere, flat-ish shading
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new(); rng.seed = 77
	var seg := 7; var rings := 5
	var pts := {}
	for j in rings + 1:
		for i in seg:
			var t := PI * j / rings; var ph := TAU * i / seg
			var r := 0.5 * rng.randf_range(0.75, 1.15) if j > 0 and j < rings else 0.5
			pts[Vector2i(i, j)] = Vector3(sin(t) * cos(ph) * r, cos(t) * r * 0.8 + 0.2, sin(t) * sin(ph) * r)
	for j in rings:
		for i in seg:
			var a: Vector3 = pts[Vector2i(i, j)]; var b: Vector3 = pts[Vector2i(i, j + 1)]
			var c: Vector3 = pts[Vector2i((i + 1) % seg, j + 1)]; var d: Vector3 = pts[Vector2i((i + 1) % seg, j)]
			var col := Color(1, 1, 1).darkened(0.25 * float(j) / rings)
			_tri(st, a, b, c, col); _tri(st, a, c, d, col)
	return st.commit()


static func box(col := Color.WHITE) -> ArrayMesh:
	# unit box, base at y=0, spans x,z in [-0.5,0.5]
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var faces := [
		[Vector3(0, 1, 0), [Vector3(-.5, 1, -.5), Vector3(.5, 1, -.5), Vector3(.5, 1, .5), Vector3(-.5, 1, .5)]],
		[Vector3(0, 0, 1), [Vector3(-.5, 0, .5), Vector3(-.5, 1, .5), Vector3(.5, 1, .5), Vector3(.5, 0, .5)]],
		[Vector3(0, 0, -1), [Vector3(.5, 0, -.5), Vector3(.5, 1, -.5), Vector3(-.5, 1, -.5), Vector3(-.5, 0, -.5)]],
		[Vector3(1, 0, 0), [Vector3(.5, 0, .5), Vector3(.5, 1, .5), Vector3(.5, 1, -.5), Vector3(.5, 0, -.5)]],
		[Vector3(-1, 0, 0), [Vector3(-.5, 0, -.5), Vector3(-.5, 1, -.5), Vector3(-.5, 1, .5), Vector3(-.5, 0, .5)]],
	]
	for f in faces:
		var n: Vector3 = f[0]; var q: Array = f[1]
		for idx in [0, 2, 1, 0, 3, 2]:
			var v: Vector3 = q[idx]
			var uv := Vector2(v.x if absf(n.x) < 0.5 else v.z, 1.0 - v.y) if absf(n.y) < 0.5 else Vector2(v.x, v.z)
			st.set_color(col); st.set_normal(n); st.set_uv(uv); st.add_vertex(v)
	st.generate_tangents()
	return st.commit()


static func cone() -> ArrayMesh:
	## unit cone/spire, base radius 0.5 at y=0, apex y=1
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_cone(st, 0.0, 1.0, 0.5, 10, Color.WHITE, Color.WHITE)
	return st.commit()


static func fountain() -> ArrayMesh:
	## basin (unit radius 0.5, height 0.3) + central column
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_cyl(st, 0.0, 0.3, 0.5, 0.5, 16, Color.WHITE)
	_cyl(st, 0.0, 1.0, 0.08, 0.06, 8, Color.WHITE)
	var top := Vector3(0, 0.3, 0)
	for i in 16:
		var a0 := TAU * i / 16.0; var a1 := TAU * (i + 1) / 16.0
		for v in [top, Vector3(cos(a0) * 0.5, 0.3, sin(a0) * 0.5), Vector3(cos(a1) * 0.5, 0.3, sin(a1) * 0.5)]:
			st.set_color(Color(0.5, 0.75, 0.85)); st.set_normal(Vector3.UP); st.add_vertex(v)
	return st.commit()


static func cylinder() -> ArrayMesh:
	# unit cylinder, base y=0, height 1, radius 0.5, with a cap
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_cyl(st, 0.0, 1.0, 0.5, 0.5, 14, Color.WHITE)
	var top := Vector3(0, 1, 0)
	for i in 14:
		var a0 := TAU * i / 14.0; var a1 := TAU * (i + 1) / 14.0
		for v in [top, Vector3(cos(a0) * 0.5, 1, sin(a0) * 0.5), Vector3(cos(a1) * 0.5, 1, sin(a1) * 0.5)]:
			st.set_color(Color.WHITE); st.set_normal(Vector3.UP); st.add_vertex(v)
	return st.commit()


static func roof() -> ArrayMesh:
	# hip roof, base 1x1 at y=0, ridge height 1
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := Vector3(-.5, 0, -.5); var b := Vector3(.5, 0, -.5); var c := Vector3(.5, 0, .5); var d := Vector3(-.5, 0, .5)
	var r0 := Vector3(-.2, 1, 0); var r1 := Vector3(.2, 1, 0)
	var col := Color(1, 1, 1)
	_tri(st, d, c, r1, col); _tri(st, d, r1, r0, col)
	_tri(st, b, a, r0, col); _tri(st, b, r0, r1, col)
	_tri(st, c, b, r1, col); _tri(st, a, d, r0, col)
	return st.commit()


static func dome() -> ArrayMesh:
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_blob(st, Vector3(0, 0, 0), Vector3(0.5, 0.6, 0.5), Color(1, 1, 1), Color(0.9, 0.9, 0.9), 12, 8)
	return st.commit()


static func boat() -> ArrayMesh:
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hull := Color(0.45, 0.28, 0.16); var deck := Color(0.75, 0.62, 0.45)
	var L := 0.06; var W := 0.018; var H := 0.012
	var p := [Vector3(-L, H, 0), Vector3(-L * 0.4, H, W), Vector3(L * 0.7, H, W), Vector3(L, H, 0), Vector3(L * 0.7, H, -W), Vector3(-L * 0.4, H, -W)]
	var k := Vector3(0, -0.004, 0)
	var keel := [Vector3(-L * 0.8, -0.004, 0), Vector3(L * 0.8, -0.004, 0)]
	for i in 6:
		var a: Vector3 = p[i]; var b: Vector3 = p[(i + 1) % 6]
		var kk: Vector3 = keel[0] if (a.x + b.x) < 0 else keel[1]
		_tri(st, a, b, kk, hull)
	_tri(st, p[0], p[2], p[1], deck); _tri(st, p[0], p[3], p[2], deck); _tri(st, p[0], p[4], p[3], deck); _tri(st, p[0], p[5], p[4], deck)
	_cyl(st, H, 0.11, 0.002, 0.0015, 4, Color(0.35, 0.25, 0.15))
	var sail := Color(0.97, 0.96, 0.92)
	var s0 := Vector3(0.002, 0.105, 0); var s1 := Vector3(0.002, 0.02, 0); var s2 := Vector3(-0.05, 0.02, 0.004)
	_tri(st, s0, s1, s2, sail); _tri(st, s0, s2, s1, sail)
	var j0 := Vector3(0.004, 0.10, 0); var j1 := Vector3(0.055, 0.016, 0.0); var j2 := Vector3(0.004, 0.02, 0.0)
	_tri(st, j0, j1, j2, sail); _tri(st, j0, j2, j1, sail)
	return st.commit()


static func _boxv(st: SurfaceTool, c: Vector3, size: Vector3, col: Color, basis := Basis.IDENTITY) -> void:
	var h := size * 0.5
	var faces := [[Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)], [Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(1, 0, 0)],
		[Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0)], [Vector3(-1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)],
		[Vector3(0, 0, 1), Vector3(0, 1, 0), Vector3(1, 0, 0)], [Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, 1, 0)]]
	for f in faces:
		var n: Vector3 = f[0]; var u: Vector3 = f[1]; var v: Vector3 = f[2]
		var o := n * h
		var uu := u * h; var vv := v * h
		var q := [o - uu - vv, o + uu - vv, o + uu + vv, o - uu + vv]
		for idx in [0, 1, 2, 0, 2, 3]:
			st.set_color(col); st.set_normal(basis * n); st.add_vertex(c + basis * q[idx])


static func crane_gantry() -> ArrayMesh:
	## ship-to-shore container crane (red/white), legs straddling the quay, boom along +z over the water
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var red := Color(0.78, 0.18, 0.14); var white := Color(0.95, 0.95, 0.93)
	for x in [-0.028, 0.028]:
		for z in [-0.022, 0.022]:
			_boxv(st, Vector3(x, 0.07, z), Vector3(0.008, 0.14, 0.008), red if z > 0 else white)
	_boxv(st, Vector3(0, 0.14, 0), Vector3(0.068, 0.012, 0.055), white)
	_boxv(st, Vector3(0, 0.152, 0.04), Vector3(0.016, 0.01, 0.2), red)          # boom
	_boxv(st, Vector3(0, 0.185, -0.01), Vector3(0.012, 0.06, 0.012), white)      # A-frame
	_boxv(st, Vector3(0, 0.145, 0.0), Vector3(0.02, 0.018, 0.02), white)          # cab
	return st.commit()


static func crane_jib() -> ArrayMesh:
	## older level-luffing quay crane: slim tower with a slanted jib along +z
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var col := Color(0.25, 0.32, 0.38); var cab := Color(0.85, 0.7, 0.25)
	_boxv(st, Vector3(0, 0.045, 0), Vector3(0.016, 0.09, 0.016), col)
	_boxv(st, Vector3(0, 0.095, 0), Vector3(0.026, 0.02, 0.03), cab)
	_boxv(st, Vector3(0, 0.12, 0.05), Vector3(0.006, 0.006, 0.12), col, Basis(Vector3.RIGHT, -0.45))
	return st.commit()



static func bougainvillea() -> ArrayMesh:
	## magenta-flowering shrub against a wall or in a courtyard
	return TreeKit.mesh("bougainvillea")
