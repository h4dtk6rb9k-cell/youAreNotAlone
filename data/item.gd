# data/item.gd
class_name Item
extends Resource

const ID_PHOTO        := "item_photo"
const ID_BOOK_ATLAS   := "item_book_atlas"
const ID_BOOK_UNNAMED := "item_book_unnamed"
const ID_BADGE        := "item_badge"
const ID_BADGE_MVD    := "item_badge_mvd"
const ID_GUIDE        := "item_guide"

@export var id:                      String = ""
@export var display_name:            String = ""
@export var is_droppable:            bool   = true
@export var is_equippable:           bool   = false
@export var is_readable:             bool   = false
@export var identity_delta_on_equip: int    = 0
@export var identity_delta_on_pickup:int    = 0


static func make(item_id: String) -> Item:
	var item := Item.new()
	item.id = item_id
	match item_id:
		ID_PHOTO:
			item.display_name             = "Фотография семьи"
			item.identity_delta_on_pickup = 8
			item.is_droppable             = true
		ID_BOOK_ATLAS:
			item.display_name             = "Атлас"
			item.identity_delta_on_pickup = 5
			item.is_readable              = true
			item.is_droppable             = true
		ID_BOOK_UNNAMED:
			item.display_name             = "Книга без названия"
			item.identity_delta_on_pickup = 5
			item.is_readable              = true
			item.is_droppable             = true
		ID_BADGE:
			item.display_name             = "Профильный значок"
			item.is_equippable            = true
			item.identity_delta_on_equip  = -5
			item.is_droppable             = true
		ID_BADGE_MVD:
			item.display_name             = "Удостоверение МВД"
			item.is_equippable            = true
			item.identity_delta_on_equip  = -10
			item.is_droppable             = true
		ID_GUIDE:
			item.display_name             = "Руководство гражданина"
			item.identity_delta_on_pickup = -5
			item.is_readable              = true
			item.is_droppable             = false   # нельзя выбросить
	return item
