# tests/unit/test_iso_grid.gd
extends GutTest

# Тестируем формулы ADR-003 без SceneTree


# ── AC: tile_to_world совпадает с формулой GDD ────────────────────────────

func test_tile_to_world_origin() -> void:
	var w := IsoGrid.tile_to_world(0, 0)
	assert_eq(w, Vector2(0.0, 0.0))


func test_tile_to_world_tx1_ty0() -> void:
	# tx=1, ty=0 → x=(1−0)*64*0.5=32, y=(1+0)*32*0.5=16
	var w := IsoGrid.tile_to_world(1, 0)
	assert_eq(w, Vector2(32.0, 16.0))


func test_tile_to_world_tx0_ty1() -> void:
	# tx=0, ty=1 → x=(0−1)*64*0.5=−32, y=(0+1)*32*0.5=16
	var w := IsoGrid.tile_to_world(0, 1)
	assert_eq(w, Vector2(-32.0, 16.0))


func test_tile_to_world_tx2_ty3() -> void:
	# x=(2−3)*32=−32, y=(2+3)*16=80
	var w := IsoGrid.tile_to_world(2, 3)
	assert_eq(w, Vector2(-32.0, 80.0))


func test_tile_to_world_negative_coords() -> void:
	# tx=−1, ty=−1 → x=0, y=−32
	var w := IsoGrid.tile_to_world(-1, -1)
	assert_eq(w, Vector2(0.0, -32.0))


# ── world_to_tile: обратное к tile_to_world ───────────────────────────────

func test_world_to_tile_roundtrip_origin() -> void:
	var tile := IsoGrid.world_to_tile(Vector2(0.0, 0.0))
	assert_eq(tile, Vector2i(0, 0))


func test_world_to_tile_roundtrip_1_0() -> void:
	var world := IsoGrid.tile_to_world(1, 0)
	var tile  := IsoGrid.world_to_tile(world)
	assert_eq(tile, Vector2i(1, 0))


func test_world_to_tile_roundtrip_3_5() -> void:
	var world := IsoGrid.tile_to_world(3, 5)
	var tile  := IsoGrid.world_to_tile(world)
	assert_eq(tile, Vector2i(3, 5))


func test_world_to_tile_roundtrip_negative() -> void:
	var world := IsoGrid.tile_to_world(-2, 4)
	var tile  := IsoGrid.world_to_tile(world)
	assert_eq(tile, Vector2i(-2, 4))


# ── sort_order: формула (tx+ty)*16 ────────────────────────────────────────

func test_sort_order_origin() -> void:
	assert_eq(IsoGrid.sort_order(0, 0), 0)


func test_sort_order_1_1() -> void:
	assert_eq(IsoGrid.sort_order(1, 1), 32)


func test_sort_order_farther_tile_higher_z() -> void:
	var near := IsoGrid.sort_order(0, 0)
	var far  := IsoGrid.sort_order(1, 1)
	assert_gt(far, near)


func test_sort_order_same_diagonal_equal() -> void:
	# (2,0) и (1,1) и (0,2) — одна диагональ → одинаковый z
	assert_eq(IsoGrid.sort_order(2, 0), IsoGrid.sort_order(1, 1))
	assert_eq(IsoGrid.sort_order(1, 1), IsoGrid.sort_order(0, 2))


# ── AC: дальний объект перекрывается ближним (z_index) ────────────────────

func test_closer_tile_has_higher_sort_order_than_farther() -> void:
	# В изометрии «ближний» = бо́льший tx+ty
	var distant := IsoGrid.sort_order(0, 0)
	var closer  := IsoGrid.sort_order(3, 3)
	assert_gt(closer, distant)


# ── IsoCharacter: направление по вектору ─────────────────────────────────

func test_vector_to_dir_east() -> void:
	assert_eq(IsoCharacter._vector_to_dir(Vector2(1.0, 0.0)), "e")


func test_vector_to_dir_south() -> void:
	assert_eq(IsoCharacter._vector_to_dir(Vector2(0.0, 1.0)), "s")


func test_vector_to_dir_west() -> void:
	assert_eq(IsoCharacter._vector_to_dir(Vector2(-1.0, 0.0)), "w")


func test_vector_to_dir_north() -> void:
	assert_eq(IsoCharacter._vector_to_dir(Vector2(0.0, -1.0)), "n")


func test_vector_to_dir_southeast() -> void:
	assert_eq(IsoCharacter._vector_to_dir(Vector2(1.0, 1.0).normalized()), "se")


func test_vector_to_dir_northwest() -> void:
	assert_eq(IsoCharacter._vector_to_dir(Vector2(-1.0, -1.0).normalized()), "nw")


# ── AC: NW/W/SW — зеркало NE/E/SE ────────────────────────────────────────

func test_mirror_directions_covered() -> void:
	assert_true("nw" in IsoCharacter.MIRROR_MAP)
	assert_true("w"  in IsoCharacter.MIRROR_MAP)
	assert_true("sw" in IsoCharacter.MIRROR_MAP)


func test_nw_maps_to_ne() -> void:
	assert_eq(IsoCharacter.MIRROR_MAP["nw"], "ne")


func test_w_maps_to_e() -> void:
	assert_eq(IsoCharacter.MIRROR_MAP["w"], "e")


func test_sw_maps_to_se() -> void:
	assert_eq(IsoCharacter.MIRROR_MAP["sw"], "se")
