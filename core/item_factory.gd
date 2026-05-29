# core/item_factory.gd
class_name ItemFactory

const ITEM_PHOTO      := "item_photo"
const ITEM_BOOK       := "item_book"
const ITEM_BADGE_MVD  := "item_badge_mvd"
const ITEM_BADGE      := "item_badge"
const ITEM_GUIDE      := "item_guide"


static func generate_start_items(profile: PlayerProfile) -> Array[String]:
	var items: Array[String] = []

	# Слот 1 — Воспоминание
	if profile.has_children:
		items.append(ITEM_PHOTO)
	else:
		items.append(ITEM_BOOK)

	# Слот 2 — Документ
	if profile.profession == PlayerProfile.PROFESSION_LAW:
		items.append(ITEM_BADGE_MVD)
	else:
		items.append(ITEM_BADGE)

	# Слот 3 — Руководство гражданина (нельзя выбросить)
	items.append(ITEM_GUIDE)

	return items
