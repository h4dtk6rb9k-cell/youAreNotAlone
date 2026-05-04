extends SceneTree

const OUT_DIR := "res://assets/levels/level_01_apartment/hybrid_overlays"
const SIZE := Vector2i(720, 1280)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_make_window_light()
	_make_floor_atmosphere()
	_make_contact_shadows()
	print("Hybrid overlays generated.")
	quit(0)


func _make_window_light() -> void:
	var image := _blank()
	_fill_polygon(image, PackedVector2Array([
		Vector2(430, 500), Vector2(640, 608), Vector2(610, 674), Vector2(430, 582)
	]), Color(1.0, 0.58, 0.22, 0.10))
	_fill_polygon(image, PackedVector2Array([
		Vector2(456, 514), Vector2(600, 588), Vector2(588, 628), Vector2(452, 558)
	]), Color(1.0, 0.70, 0.34, 0.22))
	_fill_polygon(image, PackedVector2Array([
		Vector2(370, 594), Vector2(630, 728), Vector2(552, 782), Vector2(300, 652)
	]), Color(1.0, 0.64, 0.30, 0.16))
	_fill_polygon(image, PackedVector2Array([
		Vector2(436, 680), Vector2(592, 760), Vector2(538, 792), Vector2(384, 714)
	]), Color(1.0, 0.78, 0.44, 0.12))
	_add_soft_ellipse(image, Vector2(512, 520), Vector2(190, 120), Color(1.0, 0.62, 0.24, 0.10))
	_save(image, "window_light_overlay.png")


func _make_floor_atmosphere() -> void:
	var image := _blank()
	_fill_polygon(image, PackedVector2Array([
		Vector2(92, 678), Vector2(360, 530), Vector2(666, 690), Vector2(360, 1018)
	]), Color(0.09, 0.18, 0.18, 0.22))
	_fill_polygon(image, PackedVector2Array([
		Vector2(120, 706), Vector2(360, 574), Vector2(612, 704), Vector2(360, 968)
	]), Color(0.36, 0.42, 0.36, 0.08))
	_add_soft_ellipse(image, Vector2(406, 710), Vector2(270, 180), Color(0.88, 0.54, 0.24, 0.08))
	_add_soft_ellipse(image, Vector2(260, 820), Vector2(360, 240), Color(0.0, 0.0, 0.0, 0.10))
	_save(image, "floor_atmosphere_overlay.png")


func _make_contact_shadows() -> void:
	var image := _blank()
	_add_soft_ellipse(image, Vector2(296, 642), Vector2(135, 42), Color(0.0, 0.0, 0.0, 0.22))
	_add_soft_ellipse(image, Vector2(470, 764), Vector2(112, 44), Color(0.0, 0.0, 0.0, 0.20))
	_add_soft_ellipse(image, Vector2(522, 846), Vector2(86, 38), Color(0.0, 0.0, 0.0, 0.20))
	_add_soft_ellipse(image, Vector2(238, 704), Vector2(150, 48), Color(0.0, 0.0, 0.0, 0.18))
	_add_soft_ellipse(image, Vector2(586, 624), Vector2(92, 84), Color(0.0, 0.0, 0.0, 0.18))
	_save(image, "contact_shadows_overlay.png")


func _blank() -> Image:
	var image := Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


func _fill_polygon(image: Image, polygon: PackedVector2Array, color: Color) -> void:
	var bounds := _polygon_bounds(polygon)
	for y in range(max(0, int(bounds.position.y)), min(SIZE.y, int(ceil(bounds.end.y)))):
		for x in range(max(0, int(bounds.position.x)), min(SIZE.x, int(ceil(bounds.end.x)))):
			var point := Vector2(x + 0.5, y + 0.5)
			if Geometry2D.is_point_in_polygon(point, polygon):
				_blend_pixel(image, x, y, color)


func _add_soft_ellipse(image: Image, center: Vector2, radius: Vector2, color: Color) -> void:
	var left: int = max(0, int(center.x - radius.x))
	var right: int = min(SIZE.x - 1, int(center.x + radius.x))
	var top: int = max(0, int(center.y - radius.y))
	var bottom: int = min(SIZE.y - 1, int(center.y + radius.y))
	for y in range(top, bottom + 1):
		for x in range(left, right + 1):
			var normalized := Vector2((x - center.x) / radius.x, (y - center.y) / radius.y)
			var distance := normalized.length()
			if distance > 1.0:
				continue
			var local_color := color
			local_color.a *= pow(1.0 - distance, 1.8)
			_blend_pixel(image, x, y, local_color)


func _blend_pixel(image: Image, x: int, y: int, source: Color) -> void:
	var destination := image.get_pixel(x, y)
	var out_alpha := source.a + destination.a * (1.0 - source.a)
	if out_alpha <= 0.0:
		image.set_pixel(x, y, Color(0, 0, 0, 0))
		return
	var out_color := Color(
		(source.r * source.a + destination.r * destination.a * (1.0 - source.a)) / out_alpha,
		(source.g * source.a + destination.g * destination.a * (1.0 - source.a)) / out_alpha,
		(source.b * source.a + destination.b * destination.a * (1.0 - source.a)) / out_alpha,
		out_alpha
	)
	image.set_pixel(x, y, out_color)


func _polygon_bounds(polygon: PackedVector2Array) -> Rect2:
	var min_point := polygon[0]
	var max_point := polygon[0]
	for point in polygon:
		min_point.x = min(min_point.x, point.x)
		min_point.y = min(min_point.y, point.y)
		max_point.x = max(max_point.x, point.x)
		max_point.y = max(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)


func _save(image: Image, file_name: String) -> void:
	var path := "%s/%s" % [OUT_DIR, file_name]
	var error := image.save_png(path)
	if error != OK:
		push_error("Failed to save hybrid overlay: %s" % path)
