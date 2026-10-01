extends Control

const SAVE_PATH := "user://realms_save.json"
var level := 1
var xp := 0
var gold := 50
var mana := 40
var hp := 100
var chapter := 1
var selected_magic := "Ember"
var mounted := false
var companions := ["Asma, the Timewalker"]
var log_lines := ["Welcome, Timewalker. The fractured kingdoms await."]
var quest_done := false

var status_label: Label
var log_label: Label
var quest_label: Label

func _ready() -> void:
	_load_game()
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#101827")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_bottom = 0
	add_child(scroll)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("margin_left", 18)
	root.add_theme_constant_override("margin_right", 18)
	scroll.add_child(root)
	var title := Label.new()
	title.text = "REBORN: REALMS OF ETERNITY"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("#e8c879"))
	root.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "A fantasy kingdom RPG • Mobile prototype"
	subtitle.add_theme_color_override("font_color", Color("#b7c4d8"))
	root.add_child(subtitle)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)
	_add_section(root, "STORY & QUEST")
	quest_label = Label.new()
	quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(quest_label)
	_add_button(root, "Explore the Whispering Forest", _explore)
	_add_button(root, "Challenge the Bandit Captain", _battle)
	_add_section(root, "MAGIC")
	var magic_row := HBoxContainer.new()
	root.add_child(magic_row)
	for spell in ["Ember", "Frost", "Gale", "Mend", "Shadow"]:
		var b := Button.new()
		b.text = spell
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_choose_magic.bind(spell))
		magic_row.add_child(b)
	_add_button(root, "Cast " + selected_magic, _cast_magic)
	_add_section(root, "REALMS & COMPANIONS")
	_add_button(root, "Recruit an Elf Ranger (30 gold)", _recruit)
	_add_button(root, "Summon a Royal Horse (20 gold)", _mount)
	_add_button(root, "Visit the Council: gain 15 gold", _council)
	_add_section(root, "ADVENTURE LOG")
	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(log_label)
	_add_button(root, "Save Progress", _save_game)
	_add_button(root, "Reset Adventure", _reset_game)

func _add_section(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#e8c879"))
	parent.add_child(label)

func _add_button(parent: VBoxContainer, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.pressed.connect(action)
	parent.add_child(button)

func _refresh() -> void:
	if not is_node_ready() or status_label == null:
		return
	status_label.text = "Level %d  •  XP %d/%d  •  HP %d  •  Mana %d  •  Gold %d\nMount: %s  •  Allies: %s" % [level, xp, level * 100, hp, mana, gold, "Royal horse" if mounted else "None", ", ".join(companions)]
	quest_label.text = "Chapter %d: Find the lost sigil in the Whispering Forest. %s" % [chapter, "Completed!" if quest_done else "In progress"]
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
		log_lines.append("Level up! You are now level %d." % level)

func _explore() -> void:
	if quest_done:
		gold += 10
		_gain_xp(20)
		_say("You discover a hidden cache: +10 gold and +20 XP.")
		return
	quest_done = true
	chapter = 2
	gold += 25
	_gain_xp(60)
	_say("You recover the lost sigil. The Elf Queen invites you to the Moonlit Court. +25 gold, +60 XP.")

func _battle() -> void:
	var damage := 12 + level * 3
	hp -= maxi(1, 18 - level * 2)
	gold += 12
	_gain_xp(35)
	if hp <= 0:
		hp = 50
		gold = maxi(0, gold - 10)
		_say("You were defeated and revived at the village shrine. 10 gold lost.")
	else:
		_say("You deal %d damage and defeat the bandit captain. +12 gold, +35 XP." % damage)

func _choose_magic(spell: String) -> void:
	selected_magic = spell
	_say("Selected %s magic." % spell)

func _cast_magic() -> void:
	var costs := {"Ember": 10, "Frost": 10, "Gale": 8, "Mend": 12, "Shadow": 15}
	var cost: int = costs.get(selected_magic, 10)
	if mana < cost:
		_say("Not enough mana. Rest at the village council.")
		return
	mana -= cost
	if selected_magic == "Mend":
		hp = mini(100, hp + 35)
		_say("Mend restores your health by 35.")
	else:
		_gain_xp(10)
		_say("%s magic surges through the battlefield. +10 XP." % selected_magic)

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
		_say("Your royal horse is already with you.")
	elif gold >= 20:
		gold -= 20
		mounted = true
		_say("You summon a royal horse for faster travel.")
	else:
		_say("You need 20 gold to summon a horse.")

func _council() -> void:
	gold += 15
	mana = mini(100, mana + 20)
	_say("The village council rewards your help. +15 gold and +20 mana.")

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
	log_lines = ["A new journey begins."]
	_save_game()
	_refresh()
