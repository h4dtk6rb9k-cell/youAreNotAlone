# data/dialogues/all_dialogues.gd
# Все 7 узлов диалога из scenario_v1.md
# Статический реестр — без зависимости от SceneTree
class_name AllDialogues


static func build() -> Dictionary:
	var nodes: Dictionary = {}
	for node in [
		_neighbor(),
		_neighbor_b(),
		_janitor(),
		_janitor_b(),
		_activist(),
		_activist_c(),
		_girl(),
		_girl_c(),
		_terminal_official(),
		_terminal_hidden(),
		_specialist(),
		_specialist_b(),
		_specialist_book(),
	]:
		nodes[node.node_id] = node
	return nodes


# ── neighbor ────────────────────────────────────────────────────────────────

static func _neighbor() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "neighbor"
	n.opening_text = "[Имя]? Ты слышал? Завтра всем меняют профильный номер. " \
	                 + "Говорят — плановая безопасность. Я уже подписала согласие. " \
	                 + "Лучше не тянуть."
	n.choices = [
		DialogueChoice.make("A",  "«Хорошо. Раз надо — значит надо.»",      0,  10,  0),
		DialogueChoice.make("B",  "«Ты подписала? Они забирают имя навсегда.»", 10, 0, 5, "neighbor_b"),
		DialogueChoice.make("C",  "«Я слышал. Спасибо.»",                   0,   0,  0),
	]
	n.item_branch_id              = "item_photo"
	n.item_branch_text            = "Соседка смотрит на фото. «Это твои? Красивая семья. " \
	                                + "Береги их. Сейчас важно — не высовываться.»"
	n.item_branch_identity_delta  = 5
	return n


static func _neighbor_b() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "neighbor_b"
	n.opening_text = "Соседка оглядывается на дверь. " \
	                 + "«Тише. У Громовых на третьем — муж так говорил. " \
	                 + "Его увезли на прошлой неделе. Профилактика, сказали.»"
	n.choices = [
		DialogueChoice.make("B1", "«Я понял. Спасибо.»",      5,  0,  0),
		DialogueChoice.make("B2", "«Они не имеют права.»",    15, -5, 10),
	]
	return n


# ── janitor ─────────────────────────────────────────────────────────────────

static func _janitor() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "janitor"
	n.opening_text = "«Хорошее утро, гражданин. Бумаги взял? В Центр сегодня не опаздывают.»"
	n.choices = [
		DialogueChoice.make("A", "«Взял. Всё по порядку.»",                  0, 5, 0),
		DialogueChoice.make("B", "«А ты сам уже перерегистрировался?»",      5, 0, 0, "janitor_b"),
		DialogueChoice.make("C", "*(молчать, пройти мимо)*",                 3, 0, 5),
	]
	n.badge_branch_text       = "Дворник смотрит на значок. Замолкает. " \
	                            + "«Хорошее место работы. Правильное.»"
	n.badge_blocks_choice_ids = ["B", "C"]
	return n


static func _janitor_b() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "janitor_b"
	n.opening_text = "Дворник останавливается. Смотрит на метлу. " \
	                 + "«Я — в сорок втором году. Тогда тоже говорили — для порядка. " \
	                 + "Потом ввели карточки. Потом — номера. Каждый раз для порядка.» " \
	                 + "*(Пауза)* «Ты молодой ещё. Иди.»"
	n.choices = [
		DialogueChoice.make("B1", "«Что было с теми, кто не подписал?»", 15, 0, 10),
		DialogueChoice.make("B2", "«Спасибо, отец.»",                    8,  0, 0),
	]
	return n


# ── activist ────────────────────────────────────────────────────────────────

static func _activist() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "activist"
	n.opening_text = "«Стой. Ты в Центр? Не подписывай согласие на смену номера. " \
	                 + "Читал мелкий шрифт? Пункт 7-Б — они получают право присваивать " \
	                 + "новое имя без уведомления. Имя. Понимаешь?»"
	n.choices = [
		DialogueChoice.make("A", "«Я знаю. Я читал.»",                  20,  0,  5),
		DialogueChoice.make("B", "«Я обязан подчиниться. У меня нет выбора.»", 0, 15, 0),
		DialogueChoice.make("C", "«Откуда ты знаешь про пункт 7-Б?»",   10,  0,  8, "activist_c"),
	]
	n.badge_silences_npc           = true
	n.badge_branch_text            = "Активист резко замолкает. Делает шаг назад. " \
	                                 + "«Простите. Я перепутал.» *(Уходит. Диалог недоступен.)*"
	n.badge_silence_suspicion_delta = -5
	return n


static func _activist_c() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "activist_c"
	n.opening_text = "«Моя сестра работала в архиве. Работала. " \
	                 + "Три месяца назад её перевели. Куда — не говорят.» " \
	                 + "«Нас трое в этом районе. Пока трое. " \
	                 + "Если надумаешь — терминал у фонтана. Там инструкция.»"
	n.choices = [
		DialogueChoice.make("C1", "«Я найду терминал.»",    15,  0, 15),
		DialogueChoice.make("C2", "«Это не моё дело.»",      0, 10,  0),
	]
	return n


# ── girl ────────────────────────────────────────────────────────────────────

static func _girl() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "girl"
	n.opening_text = "«Дядя, ты идёшь в Центр? Мама тоже пошла. " \
	                 + "Она сказала, что после этого всё будет по-новому. Это хорошо?»"
	n.choices = [
		DialogueChoice.make("A", "«Да, всё будет хорошо.» *(соврать)*", -5, 5, 0),
		DialogueChoice.make("B", "«Не знаю, малая.»",                    5, 0, 0),
		DialogueChoice.make("C", "«Нарисуй, какой ты хочешь видеть свою улицу.»", 10, 0, 0, "girl_c"),
	]
	n.item_branch_id             = "item_photo"
	n.item_branch_text           = "«У тебя тоже есть? Мама убрала наши фотографии. " \
	                               + "Говорит, лучше не хранить лишнего.»"
	n.item_branch_identity_delta  = 5
	n.item_branch_suspicion_delta = 3
	return n


static func _girl_c() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "girl_c"
	n.opening_text = "Девочка рисует. Показывает. «Вот тут дерево. И кот. И дом без камер.» " \
	                 + "*(Внутренний голос: «Она уже знает. Дети всегда знают.»)*"
	n.choices = []   # без выбора — автоматическая дельта
	# +8 Identity применяется в DialogueRunner автоматически при пустых choices
	# используем специальный флаг: identity_delta через первый choice-заглушку
	var auto := DialogueChoice.make("auto", "", 8, 0, 0)
	n.choices = [auto]
	return n


# ── terminal ────────────────────────────────────────────────────────────────

static func _terminal_official() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "terminal_official"
	n.opening_text = "«ГРАЖДАНИН, ВВЕДИТЕ ПРОФИЛЬНЫЙ НОМЕР " \
	                 + "ДЛЯ ПОДАЧИ ЗАЯВЛЕНИЯ НА ПЕРЕРЕГИСТРАЦИЮ»"
	n.choices = [
		DialogueChoice.make("A", "Подать заявление", -10, 20, 0),
		DialogueChoice.make("B", "Отмена",             0,  0, 5),
	]
	return n


static func _terminal_hidden() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "terminal_hidden"
	n.opening_text = "«СВОБОДНЫЙ КАНАЛ // ЗАШИФРОВАНО» " \
	                 + "«Сеть работает. Точки сбора: [ДАННЫЕ УДАЛЕНЫ]. " \
	                 + "Если читаешь это — ты уже сделал выбор.»"
	n.choices = [
		DialogueChoice.make("X1", "Запомнить информацию", 20, -10, 20),
		DialogueChoice.make("X2", "Закрыть. Не моё дело.",  0,   0,  5),
	]
	return n


# ── specialist ──────────────────────────────────────────────────────────────

static func _specialist() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "specialist"
	n.opening_text = "«Гражданин. Профильный номер.»"
	n.choices = [
		DialogueChoice.make("A", "Назвать номер",        -10, 20,  0),
		DialogueChoice.make("B", "«Меня зовут [Имя].»",  25, -10, 20, "specialist_b"),
		DialogueChoice.make("C", "*(Молчать)*",           10,   0, 15),
	]
	n.item_branch_id   = "item_book_unnamed"
	n.item_branch_text = "Специалист замечает книгу. Пауза. " \
	                     + "«Это издание изъято из обращения. Положите на стойку.»"
	n.badge_branch_text = "Специалист чуть выпрямляется. «Коллега. " \
	                      + "Процедура стандартная — для всех. Но я могу ускорить.»"
	return n


static func _specialist_b() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "specialist_b"
	n.opening_text = "Специалист впервые смотрит на игрока. " \
	                 + "«Гражданин, система не оперирует именами. " \
	                 + "Только номерами. Повторите.»"
	n.choices = [
		DialogueChoice.make("B1", "«[Номер]. Но имя — [Имя].»",    15,  5, 15),
		DialogueChoice.make("B2", "*(Назвать только номер)*",       -5, 15,  0),
	]
	return n


static func _specialist_book() -> DialogueNodeData:
	var n := DialogueNodeData.new()
	n.node_id      = "specialist_form"
	n.opening_text = "Специалист замечает книгу. Пауза. " \
	                 + "«Это издание изъято из обращения. Положите на стойку.»"
	n.choices = [
		DialogueChoice.make("book1", "Положить книгу", -15,  15,  0),
		DialogueChoice.make("book2", "«Нет.»",          20, -15, 25),
	]
	return n
