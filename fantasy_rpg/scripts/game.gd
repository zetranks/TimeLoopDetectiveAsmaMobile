extends Control

const SAVE_PATH := "user://realms_save.json"
const SPELLS := {"Ember": 10, "Frost": 10, "Gale": 8, "Mend": 12, "Shadow": 15}
var level := 1
var xp := 0
var gold := 50
var mana := 40
var hp := 100
var chapter := 1
var selected_magic := "Ember"
var mounted := false
var companions := ["Asma, the Timewalker"]
var log_lines := ["Welcome to Aetheria. Your second life begins."]
var quest_done := false
var status_label: Label
var xp_bar: ProgressBar
var log_label: Label
var quest_label: Label
var spell_button: Button

func _ready() -> void:
	_load_game()
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#101a27")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	root.add_theme_constant_override("margin_left", 18)
	root.add_theme_constant_override("margin_right", 18)
	root.add_theme_constant_override("margin_top", 18)
	root.add_theme_constant_override("margin_bottom", 24)
	scroll.add_child(root)

	var title := Label.new()
	title.text = "✦ AETHERIA: REBORN ✦"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#f1d58b"))
	root.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "A new soul. A living world. A thousand destinies."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("#a9c6d4"))
	root.add_child(subtitle)

	var hero := PanelContainer.new()
	_style_panel(hero, Color("#203447"))
	root.add_child(hero)
	var hero_col := VBoxContainer.new()
	hero_col.add_theme_constant_override("separation", 5)
	hero.add_child(hero_col)
	var hero_name := Label.new()
	hero_name.text = "ASMA • THE TIMEWALKER"
	hero_name.add_theme_font_size_override("font_size", 19)
	hero_name.add_theme_color_override("font_color", Color("#f1d58b"))
	hero_col.add_child(hero_name)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 14)
	hero_col.add_child(status_label)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size.y = 16
	xp_bar.show_percentage = false
	hero_col.add_child(xp_bar)

	_add_section(root, "THE LIVING REALMS")
	var lore := Label.new()
	lore.text = "Explore the enchanted continent of Aetheria, where humans, moon elves, beastkin and demons compete for ancient relics. Meet rulers, villagers and wandering heroes."
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore.add_theme_color_override("font_color", Color("#d1dce7"))
	root.add_child(lore)
	_add_section(root, "STORY & QUEST")
	quest_label = Label.new()
	quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(quest_label)
	_add_button(root, "Explore the Whispering Forest", _explore)
	_add_button(root, "Battle the Ashfang Marauder", _battle)

	_add_section(root, "ARCANE ARTS")
	var spell_row := HBoxContainer.new()
	spell_row.add_theme_constant_override("separation", 4)
	root.add_child(spell_row)
	for spell in ["Ember", "Frost", "Gale", "Mend", "Shadow"]:
		var b := Button.new()
		b.text = spell
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 42
		b.pressed.connect(_choose_magic.bind(spell))
		spell_row.add_child(b)
	spell_button = Button.new()
	spell_button.custom_minimum_size.y = 48
	spell_button.add_theme_color_override("font_color", Color("#f1d58b"))
	spell_button.pressed.connect(_cast_magic)
	root.add_child(spell_button)

	_add_section(root, "COURT & COMPANIONS")
	_add_button(root, "Recruit Moon Elf Ranger • 30 gold", _recruit)
	_add_button(root, "Summon Royal Moonsteed • 20 gold", _mount)
	_add_button(root, "Attend the village council • +15 gold", _council)
	_add_section(root, "PEOPLE OF AETHERIA")
	var people := Label.new()
	people.text = "Queen Elyndra • Moon Elf sovereign\nKing Rowan • Human ruler of Hearthvale\nLord Varkesh • Demon antagonist\nMira • Beastkin healer\nTovin • Village blacksmith\nNessa • Traveling merchant"
	people.add_theme_color_override("font_color", Color("#d1dce7"))
	people.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(people)
	_add_section(root, "CHRONICLE")
	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(log_label)
	_add_button(root, "Save Adventure", _save_game)
	_add_button(root, "Start a New Adventure", _reset_game)

func _style_panel(panel: PanelContainer, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#b99856")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

func _add_section(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = "✧ " + text
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("#e8c879"))
	parent.add_child(label)

func _add_button(parent: VBoxContainer, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 46
	button.pressed.connect(action)
	parent.add_child(button)

func _refresh() -> void:
	if status_label == null:
		return
	status_label.text = "Level %d   •   HP %d/100   •   Mana %d/100   •   Gold %d\nMount: %s   •   Party: %s" % [level, hp, mana, gold, "Moonsteed" if mounted else "None", ", ".join(companions)]
	xp_bar.max_value = level * 100
	xp_bar.value = xp
	quest_label.text = "Chapter %d • %s" % [chapter, "The sigil is recovered. The Moon Court awaits." if quest_done else "Recover the lost sigil from the Whispering Forest."]
	spell_button.text = "Cast %s • %d mana" % [selected_magic, SPELLS[selected_magic]]
	log_label.text = "\n".join(log_lines.slice(maxi(0, log_lines.size() - 6), log_lines.size()))

func _say(message: String) -> void:
	log_lines.append(message)
	_refresh()
	_save_game()

func _gain_xp(amount: int) -> void:
	xp += amount
	while xp >= level * 100:
		xp -= level * 100
		level += 1
		hp = 100
		mana = mini(100, mana + 20)
		log_lines.append("LEVEL UP! You reached level %d." % level)

func _explore() -> void:
	if quest_done:
		gold += 10
		_gain_xp(20)
		_say("A hidden cache yields 10 gold and 20 XP.")
		return
	quest_done = true
	chapter = 2
	gold += 25
	_gain_xp(60)
	_say("You claim the lost sigil. Queen Elyndra summons you to the Moonlit Court. +25 gold, +60 XP.")

func _battle() -> void:
	var damage := 12 + level * 3
	hp -= maxi(1, 18 - level * 2)
	gold += 12
	_gain_xp(35)
	if hp <= 0:
		hp = 50
		gold = maxi(0, gold - 10)
		_say("The shrine revives you. You lose 10 gold.")
	else:
		_say("You strike for %d damage and defeat the Ashfang Marauder. +12 gold, +35 XP." % damage)

func _choose_magic(spell: String) -> void:
	selected_magic = spell
	_refresh()
	_say("You attune to %s magic." % spell)

func _cast_magic() -> void:
	var cost: int = SPELLS[selected_magic]
	if mana < cost:
		_say("Your mana is too low. Visit the village council.")
		return
	mana -= cost
	if selected_magic == "Mend":
		hp = mini(100, hp + 35)
		_say("Mend restores up to 35 health.")
	else:
		_gain_xp(10)
		_say("%s magic erupts with ancient power. +10 XP." % selected_magic)

func _recruit() -> void:
	if "Moon Elf Ranger" in companions:
		_say("The Moon Elf Ranger is already in your party.")
	elif gold >= 30:
		gold -= 30
		companions.append("Moon Elf Ranger")
		_say("A Moon Elf Ranger joins your party.")
	else:
		_say("You need 30 gold to recruit the ranger.")

func _mount() -> void:
	if mounted:
		_say("Your Royal Moonsteed is already summoned.")
	elif gold >= 20:
		gold -= 20
		mounted = true
		_say("A Royal Moonsteed answers your call.")
	else:
		_say("You need 20 gold to summon a Moonsteed.")

func _council() -> void:
	gold += 15
	mana = mini(100, mana + 20)
	_say("The village council thanks you. +15 gold and +20 mana.")

func _save_game() -> void:
	var data := {"level": level, "xp": xp, "gold": gold, "mana": mana, "hp": hp, "chapter": chapter, "quest_done": quest_done, "mounted": mounted, "companions": companions, "log_lines": log_lines}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	gold = int(data.get("gold", 50))
	mana = int(data.get("mana", 40))
	hp = int(data.get("hp", 100))
	chapter = int(data.get("chapter", 1))
	quest_done = bool(data.get("quest_done", false))
	mounted = bool(data.get("mounted", false))
	companions = data.get("companions", ["Asma, the Timewalker"])
	log_lines = data.get("log_lines", log_lines)

func _reset_game() -> void:
	level = 1
	xp = 0
	gold = 50
	mana = 40
	hp = 100
	chapter = 1
	quest_done = false
	mounted = false
	companions = ["Asma, the Timewalker"]
	log_lines = ["A new soul awakens in Aetheria."]
	_save_game()
	_refresh()
