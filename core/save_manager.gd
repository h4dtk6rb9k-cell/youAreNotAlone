# core/save_manager.gd
class_name SaveManager

const SAVE_PATH := "user://player_profile.cfg"
const SECTION   := "profile"


static func save_profile(profile: PlayerProfile) -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, "first_name",     profile.first_name)
	config.set_value(SECTION, "last_name",      profile.last_name)
	config.set_value(SECTION, "patronymic",     profile.patronymic)
	config.set_value(SECTION, "gender",         profile.gender)
	config.set_value(SECTION, "age",            profile.age)
	config.set_value(SECTION, "education",      profile.education)
	config.set_value(SECTION, "marital_status", profile.marital_status)
	config.set_value(SECTION, "has_children",   profile.has_children)
	config.set_value(SECTION, "profession",     profile.profession)
	config.set_value(SECTION, "workplace",      profile.workplace)
	config.set_value(SECTION, "favorite_book",  profile.favorite_book)
	config.save(SAVE_PATH)


static func load_profile() -> PlayerProfile:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return PlayerProfile.new()
	var p := PlayerProfile.new()
	p.first_name     = config.get_value(SECTION, "first_name",     "")
	p.last_name      = config.get_value(SECTION, "last_name",      "")
	p.patronymic     = config.get_value(SECTION, "patronymic",     "")
	p.gender         = config.get_value(SECTION, "gender",         0)
	p.age            = config.get_value(SECTION, "age",            30)
	p.education      = config.get_value(SECTION, "education",      0)
	p.marital_status = config.get_value(SECTION, "marital_status", 0)
	p.has_children   = config.get_value(SECTION, "has_children",   false)
	p.profession     = config.get_value(SECTION, "profession",     0)
	p.workplace      = config.get_value(SECTION, "workplace",      0)
	p.favorite_book  = config.get_value(SECTION, "favorite_book",  "")
	return p


static func has_saved_profile() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
