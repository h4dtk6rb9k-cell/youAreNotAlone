# tests/unit/test_iso_input.gd
# IsoInput зависит от Viewport/Physics — тестируем логику ветвления
# через прямую проверку сигнальных деклараций и вспомогательных функций
extends GutTest


func test_iso_input_has_on_world_tap_signal() -> void:
	# Проверяем что класс декларирует нужные сигналы
	var iso := IsoInput.new()
	assert_true(iso.has_signal("on_world_tap"))
	iso.free()


func test_iso_input_has_on_object_tap_signal() -> void:
	var iso := IsoInput.new()
	assert_true(iso.has_signal("on_object_tap"))
	iso.free()


func test_iso_grid_sort_order_from_world_matches_manual() -> void:
	# sort_order_from_world(tile_to_world(2,3)) == sort_order(2,3)
	var world := IsoGrid.tile_to_world(2, 3)
	assert_eq(IsoGrid.sort_order_from_world(world), IsoGrid.sort_order(2, 3))


func test_move_speed_constant() -> void:
	# MoveSpeed из GDD: 3.5 * TILE_WIDTH
	assert_eq(IsoCharacter.MOVE_SPEED, 3.5 * IsoGrid.TILE_WIDTH)
