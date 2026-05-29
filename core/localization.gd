# core/localization.gd
class_name Localization


static func localize(raw: String) -> String:
	return raw \
		.replace("[Имя]",   GameState.profile.first_name) \
		.replace("[Номер]", GameState.profile_number)
