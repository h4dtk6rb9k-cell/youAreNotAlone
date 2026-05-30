# iso/iso_grid.gd — ADR-003
class_name IsoGrid

const TILE_WIDTH:  int = 64
const TILE_HEIGHT: int = 32


# TileToWorld: формула из GDD без изменений
static func tile_to_world(tx: int, ty: int) -> Vector2:
	return Vector2(
		(tx - ty) * TILE_WIDTH  * 0.5,
		(tx + ty) * TILE_HEIGHT * 0.5
	)


# WorldToTile: обратное преобразование
static func world_to_tile(world: Vector2) -> Vector2i:
	var fx: float = (world.x / (TILE_WIDTH * 0.5) + world.y / (TILE_HEIGHT * 0.5)) * 0.5
	var fy: float = (world.y / (TILE_HEIGHT * 0.5) - world.x / (TILE_WIDTH * 0.5)) * 0.5
	return Vector2i(int(round(fx)), int(round(fy)))


# SortOrder: z_index для алгоритма художника (ADR-003: (tx+ty)*16)
static func sort_order(tx: int, ty: int) -> int:
	return (tx + ty) * 16


static func sort_order_from_world(world: Vector2) -> int:
	var tile := world_to_tile(world)
	return sort_order(tile.x, tile.y)
