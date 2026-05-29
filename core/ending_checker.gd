# core/ending_checker.gd
class_name EndingChecker

enum Ending { NONE, SELFHOOD, CONFORMIST, REBEL }

# Приоритет: Selfhood > Conformist > Rebel (scenario_v1.md)
static func evaluate(stats: PlayerStats) -> Ending:
	if stats.selfhood_unlocked():
		return Ending.SELFHOOD
	if stats.compliance >= PlayerStats.CONFORMIST_THRESHOLD:
		return Ending.CONFORMIST
	if stats.suspicion >= PlayerStats.REBEL_THRESHOLD:
		return Ending.REBEL
	return Ending.NONE


static func get_text(ending: Ending) -> String:
	match ending:
		Ending.SELFHOOD:
			return "Бланк остался незаполненным.\n\n" \
				+ "Они внесут данные сами — так проще.\n\n" \
				+ "Но вы уже знаете своё имя.\n\n" \
				+ "Это единственное, что они не могут занести в реестр.\n\n" \
				+ "Пока."
		Ending.CONFORMIST:
			return "Вы поставили подпись. Система приняла. Новый номер присвоен.\n\n" \
				+ "Где-то в архиве осталась карточка с другим именем.\n\n" \
				+ "Завтра её уничтожат.\n\n" \
				+ "Вы этого не почувствуете."
		Ending.REBEL:
			return "Они пришли той же ночью.\n\n" \
				+ "Без объяснений — только номер дела на папке.\n\n" \
				+ "Вы успели подумать: хорошо, что я не подписал.\n\n" \
				+ "Или это было вслух?"
		_:
			return ""
