extends Control

const SAVE_PATH := "user://realms_save.json"
const SPELLS := {"Ember": 10, "Frost": 10, "Gale": 8, "Mend": 12, "Shadow": 15}
const MAX_LEVEL := 1500
const DEMON_LORD_LEVEL := 1200
var level := 1
var skill_points := 0
var herbs := 0
var potions := 0
var dungeon_clears := 0
var bosses_defeated := 0
var daily_claim_date := ""
var village_level := 1
var horse_type := "Royal Moonsteed"
var horse_level := 1
var destiny_choice := "Undecided"
var bgm_player: AudioStreamPlayer
var team_name := ""
var team_members := ["Asma"]
var chat_history := ["System: Online chat is a local demo; server connection is not configured."]
var chat_input: LineEdit
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
	_update_music()

func _build_ui() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.volume_db = -18.0
	add_child(bgm_player)
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
	_add_button(root, "Enter the Crystal Dungeon (Level 5+)", _dungeon)
	_add_button(root, "Gather herbs", _gather_herbs)
	_add_button(root, "Craft a healing potion • 3 herbs", _craft_potion)
	_add_button(root, "Use a healing potion", _use_potion)
	_add_button(root, "Claim daily reward", _daily_reward)
	_add_button(root, "View achievements", _achievements)
	_add_section(root, "ONLINE SOCIAL (LOCAL DEMO)")
	_add_button(root, "Create / join an adventure team", _create_team)
	_add_button(root, "Invite demo teammate", _invite_team)
	chat_input = LineEdit.new()
	chat_input.placeholder_text = "Type a message..."
	root.add_child(chat_input)
	_add_button(root, "Send chat message", _send_chat)
	_add_button(root, "View team chat", _show_chat)
	_add_section(root, "VILLAGE & MOUNTS")
	_add_button(root, "Upgrade Hearthvale village • 100 gold", _upgrade_village)
	_add_button(root, "Choose / level up horse", _cycle_horse)
	_add_section(root, "CHOOSE YOUR DESTINY • LEVEL 1000+")
	_add_button(root, "Choose Demon Lord destiny", _choose_demon_destiny)
	_add_button(root, "Choose Horse Guardian destiny", _choose_horse_destiny)
	_add_section(root, "DEMON THREATS & TOURNAMENTS")
	_add_button(root, "Animated battle demo • Move, talk & fight", _open_battle_demo)
	_add_button(root, "PLAYABLE ADVENTURE DEMO • Move & explore", _open_playable_demo)
	_add_button(root, "Fight a weak demon • Level 1+", _weak_demon)
	_add_button(root, "Challenge Demon Lord Varkesh • Level 30+", _demon_lord)
	_add_button(root, "Enter the arena tournament", _tournament)

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
	status_label.text = "Level %d/%d   •   XP %d/%d   •   Skill points %d\nHP %d/100   •   Mana %d/100   •   Gold %d\nHerbs %d   •   Potions %d   •   Mount: %s\nParty: %s\nDestiny: %s" % [level, MAX_LEVEL, xp, _xp_required(), skill_points, hp, mana, gold, herbs, potions, "Moonsteed" if mounted else "None", ", ".join(companions), destiny_choice]
	xp_bar.max_value = _xp_required()
	xp_bar.value = xp
	quest_label.text = "Chapter %d • %s" % [chapter, "The sigil is recovered. The Moon Court awaits." if quest_done else "Recover the lost sigil from the Whispering Forest."]
	spell_button.text = "Cast %s • %d mana" % [selected_magic, SPELLS[selected_magic]]
	log_label.text = "\n".join(log_lines.slice(maxi(0, log_lines.size() - 6), log_lines.size()))

func _say(message: String) -> void:
	log_lines.append(message)
	_refresh()
	_save_game()

func _choose_demon_destiny() -> void:
	if level < 1000:
		_say("Destiny choices unlock at level 1000. Keep training.")
		return
	destiny_choice = "Demon Lord"
	_update_music()
	_say("You choose the Demon Lord destiny. A dark, powerful theme now follows you.")

func _choose_horse_destiny() -> void:
	if level < 1000:
		_say("Destiny choices unlock at level 1000. Keep training.")
		return
	destiny_choice = "Horse Guardian"
	_update_music()
	_say("You choose the Horse Guardian destiny. A bright, adventurous theme now follows you.")

func _update_music() -> void:
	if bgm_player == null:
		return
	if destiny_choice == "Demon Lord":
		bgm_player.stream = _make_theme([110.0, 130.81, 146.83, 98.0, 110.0, 164.81, 146.83, 98.0], true)
	elif destiny_choice == "Horse Guardian":
		bgm_player.stream = _make_theme([261.63, 329.63, 392.0, 329.63, 293.66, 369.99, 440.0, 369.99], false)
	else:
		bgm_player.stream = _make_theme([196.0, 220.0, 261.63, 293.66, 261.63, 220.0, 196.0, 174.61], false)
	bgm_player.play()

func _make_theme(notes: Array, dark: bool) -> AudioStreamWAV:
	# Procedural, loopable background music; no external audio files are required.
	var sample_rate := 22050
	var seconds_per_note := 0.5
	var samples_per_note := int(sample_rate * seconds_per_note)
	var total_samples := samples_per_note * notes.size()
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)
	for i in range(total_samples):
		var note_index := int(i / samples_per_note)
		var local_t := float(i % samples_per_note) / sample_rate
		var frequency: float = notes[note_index]
		var fade_in := minf(1.0, local_t * 12.0)
		var fade_out := minf(1.0, (seconds_per_note - local_t) * 8.0)
		var envelope := minf(fade_in, fade_out)
		var fundamental := sin(TAU * frequency * local_t)
		var overtone := sin(TAU * frequency * 2.0 * local_t) * (0.28 if dark else 0.16)
		var undertone := sin(TAU * frequency * 0.5 * local_t) * (0.30 if dark else 0.12)
		var sample_value := (fundamental + overtone + undertone) * envelope * (0.22 if dark else 0.18)
		pcm.encode_s16(i * 2, int(clampf(sample_value, -1.0, 1.0) * 16000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = pcm
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total_samples
	return stream

func _xp_required() -> int:
	return 100 + level * 10

func _gain_xp(amount: int) -> void:
	xp += amount
	while xp >= _xp_required() and level < MAX_LEVEL:
		xp -= _xp_required()
		level += 1
		skill_points += 1
		hp = 100
		mana = mini(100, mana + 20)
		log_lines.append("LEVEL UP! Level %d. +1 skill point; HP restored." % level)
	if level == MAX_LEVEL:
		xp = 0

func _explore() -> void:
	if quest_done:
		gold += 10
		_gain_xp(20)
		_say("A hidden cache yields 10 gold and 20 XP.")
		return
	quest_done = true
	chapter = 2
	gold += 25
	herbs += 2
	_gain_xp(60)
	_say("You claim the lost sigil. Queen Elyndra summons you to the Moonlit Court. +25 gold, +60 XP.")

func _battle() -> void:
	var enemy_level := maxi(1, level + 2)
	var damage := 12 + level * 3
	hp -= maxi(1, 18 + enemy_level / 20 - level / 10)
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


func _dungeon() -> void:
	if level < 5:
		_say("The Crystal Dungeon opens at level 5.")
		return
	var damage := 22 + level * 2
	hp -= maxi(5, 28 - level)
	if hp <= 0:
		hp = 50
		gold = maxi(0, gold - 15)
		_say("The dungeon guardian defeats you. The shrine revives you; you lose 15 gold.")
		return
	dungeon_clears += 1
	bosses_defeated += 1
	gold += 35 + level
	herbs += 2
	_gain_xp(80 + level * 10)
	_say("You defeat the Crystal Guardian for %d damage! +%d gold, herbs and XP." % [damage, 35 + level])

func _gather_herbs() -> void:
	herbs += 2
	_gain_xp(5)
	_say("You gather 2 moon herbs. +5 XP.")

func _craft_potion() -> void:
	if herbs < 3:
		_say("You need 3 moon herbs to craft a healing potion.")
		return
	herbs -= 3
	potions += 1
	_say("You craft a healing potion. Potions: %d." % potions)

func _use_potion() -> void:
	if potions <= 0:
		_say("You have no healing potions. Craft one with 3 herbs.")
		return
	if hp >= 100:
		_say("Your health is already full.")
		return
	potions -= 1
	hp = mini(100, hp + 50)
	_say("The potion restores up to 50 HP.")

func _daily_reward() -> void:
	var today := Time.get_date_string_from_system()
	if daily_claim_date == today:
		_say("Today's daily reward has already been claimed. Come back tomorrow.")
		return
	daily_claim_date = today
	gold += 50
	herbs += 3
	_gain_xp(25)
	_say("Daily reward claimed: +50 gold, +3 herbs and +25 XP.")

func _achievements() -> void:
	var unlocked: Array[String] = []
	if level >= 10:
		unlocked.append("Rising Hero (Level 10)")
	if dungeon_clears >= 1:
		unlocked.append("Crystal Conqueror")
	if bosses_defeated >= 5:
		unlocked.append("Bane of Bosses")
	if chapter >= 2:
		unlocked.append("Sigil Seeker")
	if unlocked.is_empty():
		_say("Achievements: keep exploring, level up and defeat dungeon bosses.")
	else:
		_say("Achievements unlocked: " + ", ".join(unlocked))

func _create_team() -> void:
	if team_name == "":
		team_name = "Aetheria Adventurers"
		team_members = ["Asma"]
		_say("Team created: %s. Invite friends when online services are connected." % team_name)
	else:
		_say("You are already in team %s." % team_name)

func _invite_team() -> void:
	if team_name == "":
		_create_team()
	team_members.append("Guest %d" % team_members.size())
	_say("A demo teammate joined %s. This is local only, not a real online invite." % team_name)

func _send_chat() -> void:
	if chat_input == null or chat_input.text.strip_edges().is_empty():
		_say("Enter a message before sending.")
		return
	chat_history.append("Asma: " + chat_input.text.strip_edges())
	chat_input.clear()
	_say("Message added to local demo chat. Online delivery needs a server.")

func _show_chat() -> void:
	_say("Team chat: " + " | ".join(chat_history.slice(maxi(0, chat_history.size() - 4), chat_history.size())))

func _upgrade_village() -> void:
	if village_level >= 10:
		_say("Hearthvale has reached the current village level cap (10).")
	elif gold < 100:
		_say("You need 100 gold to upgrade Hearthvale.")
	else:
		gold -= 100
		village_level += 1
		_gain_xp(20)
		_say("Hearthvale upgraded to village level %d. +20 XP." % village_level)

func _cycle_horse() -> void:
	var horses := ["Royal Moonsteed", "Dune Runner", "Frostmane", "Emberhoof", "Stormwing"]
	var index := horses.find(horse_type)
	if index < 0:
		index = 0
	if not mounted:
		horse_type = horses[(index + 1) % horses.size()]
		mounted = true
		horse_level = maxi(1, level / 10)
		_say("You summon a %s at mount level %d." % [horse_type, horse_level])
	elif horse_level < mini(20, maxi(1, level / 2)):
		horse_level += 1
		_say("%s reaches mount level %d." % [horse_type, horse_level])
	else:
		horse_type = horses[(index + 1) % horses.size()]
		horse_level = 1
		_say("You switch to %s, level 1." % horse_type)

func _weak_demon() -> void:
	var demon_level := maxi(1, int(level * 0.8) + randi_range(1, 5))
	var damage := 8 + int(demon_level * 0.15)
	hp -= maxi(1, damage - level)
	if hp <= 0:
		hp = 50
		gold = maxi(0, gold - 5)
		_say("A weak demon defeats you. The shrine revives you; you lose 5 gold.")
	else:
		gold += 8 + demon_level
		_gain_xp(20 + demon_level * 5)
		_say("You defeat a level %d weak demon. +%d gold and XP." % [demon_level, 8 + demon_level])

func _demon_lord() -> void:
	if level < 1000:
		_say("Demon Lord Varkesh is level %d. Reach level 1000 and prepare your gear before challenging him." % DEMON_LORD_LEVEL)
		return
	var damage := DEMON_LORD_LEVEL * 2
	var player_power := level * 2 + skill_points * 3 + horse_level * 10
	if player_power < DEMON_LORD_LEVEL:
		hp -= 100
		_say("Varkesh overwhelms you. His level %d power exceeds yours (%d). Train and return." % [DEMON_LORD_LEVEL, player_power])
		return
	hp -= maxi(10, 45 - level / 20)
	if hp <= 0:
		hp = 50
		gold = maxi(0, gold - 25)
		_say("Varkesh overwhelms you. The shrine revives you; you lose 25 gold.")
	else:
		gold += 1500
		_gain_xp(5000)
		bosses_defeated += 1
		_say("You defeat level %d Demon Lord Varkesh! +1500 gold and +5000 XP." % DEMON_LORD_LEVEL)

func _tournament() -> void:
	if level < 5:
		_say("The village tournament opens at level 5.")
		return
	gold += 25 + level
	_gain_xp(45)
	_say("You complete an arena tournament round. +%d gold and +45 XP." % (25 + level))

func _save_game() -> void:
	var data := {"level": level, "xp": xp, "gold": gold, "mana": mana, "hp": hp, "chapter": chapter, "quest_done": quest_done, "mounted": mounted, "companions": companions, "log_lines": log_lines, "skill_points": skill_points, "herbs": herbs, "potions": potions, "dungeon_clears": dungeon_clears, "bosses_defeated": bosses_defeated, "daily_claim_date": daily_claim_date, "village_level": village_level, "horse_type": horse_type, "horse_level": horse_level, "destiny_choice": destiny_choice, "team_name": team_name, "team_members": team_members, "chat_history": chat_history}
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
	level = clampi(int(data.get("level", 1)), 1, MAX_LEVEL)
	xp = int(data.get("xp", 0))
	gold = int(data.get("gold", 50))
	mana = int(data.get("mana", 40))
	hp = int(data.get("hp", 100))
	chapter = int(data.get("chapter", 1))
	quest_done = bool(data.get("quest_done", false))
	mounted = bool(data.get("mounted", false))
	companions = data.get("companions", ["Asma, the Timewalker"])
	log_lines = data.get("log_lines", log_lines)
	skill_points = int(data.get("skill_points", 0))
	herbs = int(data.get("herbs", 0))
	potions = int(data.get("potions", 0))
	dungeon_clears = int(data.get("dungeon_clears", 0))
	bosses_defeated = int(data.get("bosses_defeated", 0))
	daily_claim_date = str(data.get("daily_claim_date", ""))
	village_level = clampi(int(data.get("village_level", 1)), 1, 10)
	horse_type = str(data.get("horse_type", "Royal Moonsteed"))
	horse_level = clampi(int(data.get("horse_level", 1)), 1, 20)
	destiny_choice = str(data.get("destiny_choice", "Undecided"))
	team_name = str(data.get("team_name", ""))
	team_members = data.get("team_members", ["Asma"])
	chat_history = data.get("chat_history", ["System: Local demo chat."])

func _reset_game() -> void:
	level = 1
	skill_points = 0
	herbs = 0
	potions = 0
	dungeon_clears = 0
	bosses_defeated = 0
	daily_claim_date = ""
	village_level = 1
	horse_type = "Royal Moonsteed"
	horse_level = 1
	destiny_choice = "Undecided"
	team_name = ""
	team_members = ["Asma"]
	chat_history = ["System: Online chat is a local demo; server connection is not configured."]
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
	_update_music()


# Separate animated battle prototype; existing game content is untouched.
var battle_overlay: Control
var battle_asma: Label
var battle_demon: Label
var battle_dialogue: Label
var battle_enemy_hp := 100
var battle_turn := 0

func _open_battle_demo() -> void:
\tif battle_overlay != null and is_instance_valid(battle_overlay):
\t\tbattle_overlay.queue_free()
\tbattle_enemy_hp = 100
\tbattle_turn = 0
\tbattle_overlay = Control.new()
\tbattle_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
\tbattle_overlay.z_index = 20
\tadd_child(battle_overlay)
\tvar shade := ColorRect.new()
\tshade.color = Color(0.025, 0.035, 0.07, 0.97)
\tshade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
\tbattle_overlay.add_child(shade)
\tvar panel := PanelContainer.new()
\tpanel.set_anchors_preset(Control.PRESET_CENTER)
\tpanel.position = Vector2(-360, -250)
\tpanel.size = Vector2(720, 500)
\t_style_panel(panel, Color("#17283b"))
\tbattle_overlay.add_child(panel)
\tvar col := VBoxContainer.new()
\tcol.add_theme_constant_override("separation", 14)
\tpanel.add_child(col)
\tvar heading := Label.new()
\theading.text = "BATTLE • WHISPERING FOREST"
\theading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\theading.add_theme_font_size_override("font_size", 20)
\theading.add_theme_color_override("font_color", Color("#f1d58b"))
\tcol.add_child(heading)
\tvar stage := Control.new()
\tstage.custom_minimum_size = Vector2(680, 210)
\tcol.add_child(stage)
\tvar ground := ColorRect.new()
\tground.color = Color("#263d3d")
\tground.position = Vector2(0, 160)
\tground.size = Vector2(680, 50)
\tstage.add_child(ground)
\tbattle_asma = Label.new()
\tbattle_asma.text = "⚔\
ASMA"
\tbattle_asma.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tbattle_asma.add_theme_font_size_override("font_size", 28)
\tbattle_asma.add_theme_color_override("font_color", Color("#9bd9ff"))
\tbattle_asma.position = Vector2(90, 75)
\tbattle_asma.size = Vector2(110, 90)
\tstage.add_child(battle_asma)
\tbattle_demon = Label.new()
\tbattle_demon.text = "👹\
ASHFANG"
\tbattle_demon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tbattle_demon.add_theme_font_size_override("font_size", 28)
\tbattle_demon.add_theme_color_override("font_color", Color("#ff9b83"))
\tbattle_demon.position = Vector2(480, 75)
\tbattle_demon.size = Vector2(130, 90)
\tstage.add_child(battle_demon)
\tbattle_dialogue = Label.new()
\tbattle_dialogue.text = "Ashfang: You do not belong in this forest!"
\tbattle_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
\tbattle_dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tbattle_dialogue.add_theme_color_override("font_color", Color("#e8d8b4"))
\tcol.add_child(battle_dialogue)
\tvar actions := HBoxContainer.new()
\tactions.add_theme_constant_override("separation", 8)
\tcol.add_child(actions)
\tvar attack := Button.new()
\tattack.text = "Move & Attack"
\tattack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
\tattack.pressed.connect(_battle_demo_attack)
\tactions.add_child(attack)
\tvar talk := Button.new()
\ttalk.text = "Talk"
\ttalk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
\ttalk.pressed.connect(_battle_demo_talk)
\tactions.add_child(talk)
\tvar close := Button.new()
\tclose.text = "Leave Battle"
\tclose.size_flags_horizontal = Control.SIZE_EXPAND_FILL
\tclose.pressed.connect(_close_battle_demo)
\tactions.add_child(close)
\tvar note := Label.new()
\tnote.text = "Prototype animation uses temporary character symbols; it does not replace your original art."
\tnote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
\tnote.add_theme_font_size_override("font_size", 11)
\tnote.add_theme_color_override("font_color", Color("#a9c6d4"))
\tcol.add_child(note)

func _battle_demo_attack() -> void:
\tif battle_overlay == null or not is_instance_valid(battle_overlay):
\t\treturn
\tvar start := battle_asma.position
\tvar lunge := start + Vector2(260, 0)
\tvar tween := create_tween()
\ttween.tween_property(battle_asma, "position", lunge, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\ttween.tween_property(battle_demon, "position", battle_demon.position + Vector2(24, 0), 0.12)
\ttween.tween_property(battle_asma, "position", start, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
\tbattle_enemy_hp = maxi(0, battle_enemy_hp - 25)
\tif battle_enemy_hp == 0:
\t\tbattle_dialogue.text = "Ashfang: No... the forest is yours! Demo battle won."
\telse:
\t\tbattle_dialogue.text = "Asma: Take this! Ashfang HP: %d%%" % battle_enemy_hp
\t\tvar enemy_start := battle_demon.position
\t\tvar enemy_tween := create_tween()
\t\tenemy_tween.tween_property(battle_demon, "position", enemy_start + Vector2(-45, 0), 0.18)
\t\tenemy_tween.tween_property(battle_demon, "position", enemy_start, 0.18)

func _battle_demo_talk() -> void:
\tif battle_overlay == null or not is_instance_valid(battle_overlay):
\t\treturn
\tvar lines := ["Asma: Tell me why you guard this forest.", "Ashfang: The old sigil must not leave these woods.", "Asma: Then I will take it and end this threat."]
\tbattle_dialogue.text = lines[battle_turn % lines.size()]
\tbattle_turn += 1

func _close_battle_demo() -> void:
\tif battle_overlay != null and is_instance_valid(battle_overlay):
\t\tbattle_overlay.queue_free()
\tbattle_overlay = null


# Playable top-down demo; all existing story, characters and progression remain intact.
var playable_demo: Control
var demo_stage: Control
var demo_player: Label
var demo_npc: Label
var demo_enemy: Label
var demo_message: Label
var demo_enemy_hp := 100

func _open_playable_demo() -> void:
	if playable_demo != null and is_instance_valid(playable_demo):
		playable_demo.queue_free()
	playable_demo = Control.new()
	playable_demo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	playable_demo.z_index = 30
	add_child(playable_demo)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.07, 0.98)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	playable_demo.add_child(shade)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-360, -310)
	panel.size = Vector2(720, 620)
	_style_panel(panel, Color("#17283b"))
	playable_demo.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	var heading := Label.new()
	heading.text = "AETHERIA • PLAYABLE ADVENTURE"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 21)
	heading.add_theme_color_override("font_color", Color("#f1d58b"))
	col.add_child(heading)
	var help := Label.new()
	help.text = "Move with WASD / arrow keys or the direction buttons. Walk near characters to interact."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.add_theme_font_size_override("font_size", 12)
	col.add_child(help)
	demo_stage = Control.new()
	demo_stage.custom_minimum_size = Vector2(680, 280)
	demo_stage.clip_contents = true
	col.add_child(demo_stage)
	var sky := ColorRect.new()
	sky.color = Color("#24394b")
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	demo_stage.add_child(sky)
	var ground := ColorRect.new()
	ground.color = Color("#29483d")
	ground.position = Vector2(0, 205)
	ground.size = Vector2(680, 75)
	demo_stage.add_child(ground)
	for i in range(8):
		var tree := Label.new()
		tree.text = "♣"
		tree.add_theme_font_size_override("font_size", 35)
		tree.add_theme_color_override("font_color", Color("#56805a"))
		tree.position = Vector2(20 + i * 88, 5 + (i % 2) * 18)
		demo_stage.add_child(tree)
	demo_npc = Label.new()
	demo_npc.text = "♙\nMIRA"
	demo_npc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo_npc.add_theme_font_size_override("font_size", 22)
	demo_npc.add_theme_color_override("font_color", Color("#f1d58b"))
	demo_npc.position = Vector2(300, 75)
	demo_npc.size = Vector2(90, 85)
	demo_stage.add_child(demo_npc)
	demo_enemy = Label.new()
	demo_enemy.text = "👹\nASHFANG"
	demo_enemy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo_enemy.add_theme_font_size_override("font_size", 22)
	demo_enemy.add_theme_color_override("font_color", Color("#ff9b83"))
	demo_enemy.position = Vector2(520, 160)
	demo_enemy.size = Vector2(130, 85)
	demo_stage.add_child(demo_enemy)
	demo_player = Label.new()
	demo_player.text = "⚔\nASMA"
	demo_player.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo_player.add_theme_font_size_override("font_size", 22)
	demo_player.add_theme_color_override("font_color", Color("#9bd9ff"))
	demo_player.position = Vector2(65, 155)
	demo_player.size = Vector2(90, 85)
	demo_stage.add_child(demo_player)
	demo_enemy_hp = 100
	demo_message = Label.new()
	demo_message.text = "Mira: Welcome, Timewalker. Explore the forest!"
	demo_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	demo_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(demo_message)
	var controls := GridContainer.new()
	controls.columns = 3
	controls.add_theme_constant_override("h_separation", 6)
	controls.add_theme_constant_override("v_separation", 4)
	col.add_child(controls)
	_demo_button(controls, "↑", _move_demo.bind(Vector2(0, -35)))
	_demo_button(controls, "Interact", _interact_demo)
	_demo_button(controls, "Attack", _attack_demo)
	_demo_button(controls, "←", _move_demo.bind(Vector2(-35, 0)))
	_demo_button(controls, "↓", _move_demo.bind(Vector2(0, 35)))
	_demo_button(controls, "→", _move_demo.bind(Vector2(35, 0)))
	_demo_button(controls, "Cast " + selected_magic, _cast_demo_magic)
	_demo_button(controls, "Collect herbs", _collect_demo)
	_demo_button(controls, "Complete quest", _demo_quest)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	col.add_child(footer)
	var save := Button.new()
	save.text = "Save Adventure"
	save.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save.pressed.connect(_save_game)
	footer.add_child(save)
	var leave := Button.new()
	leave.text = "Exit Demo"
	leave.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leave.pressed.connect(_close_playable_demo)
	footer.add_child(leave)

func _demo_button(parent: GridContainer, label_text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(100, 38)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(action)
	parent.add_child(button)

func _move_demo(offset: Vector2) -> void:
	if demo_player == null or not is_instance_valid(demo_player):
		return
	var destination := demo_player.position + offset
	destination.x = clampf(destination.x, 0.0, 570.0)
	destination.y = clampf(destination.y, 0.0, 190.0)
	var tween := create_tween()
	tween.tween_property(demo_player, "position", destination, 0.12)

func _unhandled_input(event: InputEvent) -> void:
	if playable_demo == null or not is_instance_valid(playable_demo):
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_W, KEY_UP:
				_move_demo(Vector2(0, -35))
			KEY_S, KEY_DOWN:
				_move_demo(Vector2(0, 35))
			KEY_A, KEY_LEFT:
				_move_demo(Vector2(-35, 0))
			KEY_D, KEY_RIGHT:
				_move_demo(Vector2(35, 0))

func _interact_demo() -> void:
	if demo_player == null or demo_npc == null:
		return
	if demo_player.position.distance_to(demo_npc.position) < 125.0:
		demo_message.text = "Mira: The forest sigil is lost. Speak with the queen after finding it."
	elif demo_player.position.distance_to(demo_enemy.position) < 145.0:
		demo_message.text = "Ashfang: The sigil belongs to these woods. Prepare to fight!"
	else:
		demo_message.text = "Move closer to Mira or Ashfang to interact."

func _attack_demo() -> void:
	if demo_player == null or demo_enemy == null:
		return
	if demo_player.position.distance_to(demo_enemy.position) > 150.0:
		demo_message.text = "Move closer to Ashfang before attacking."
		return
	if demo_enemy_hp <= 0:
		demo_message.text = "Ashfang has already been defeated. Explore or complete the quest."
		return
	demo_enemy_hp = maxi(0, demo_enemy_hp - 25)
	var start := demo_player.position
	var tween := create_tween()
	tween.tween_property(demo_player, "position", start + Vector2(24, 0), 0.12)
	tween.tween_property(demo_player, "position", start, 0.16)
	if demo_enemy_hp == 0:
		demo_enemy.text = "✦\nDEFEATED"
		gold += 12
		_gain_xp(35)
		demo_message.text = "Ashfang defeated! +12 gold, +35 XP."
		_refresh()
	else:
		demo_message.text = "Asma strikes! Ashfang HP: %d%%" % demo_enemy_hp

func _cast_demo_magic() -> void:
	if selected_magic == "Mend":
		_cast_magic()
		if demo_message != null:
			demo_message.text = "Mend restores health. HP: %d" % hp
		return
	var cost: int = SPELLS[selected_magic]
	if mana < cost:
		demo_message.text = "Not enough mana. Visit the village council."
		return
	if demo_player.position.distance_to(demo_enemy.position) > 170.0:
		demo_message.text = "Move closer to Ashfang to cast offensive magic."
		return
	mana -= cost
	demo_enemy_hp = maxi(0, demo_enemy_hp - 35)
	if demo_enemy_hp == 0:
		demo_enemy.text = "✦\nDEFEATED"
		gold += 12
		_gain_xp(35)
		demo_message.text = "%s magic defeats Ashfang! +12 gold, +35 XP." % selected_magic
	else:
		demo_message.text = "%s magic hits! Ashfang HP: %d%%" % [selected_magic, demo_enemy_hp]
	_refresh()

func _collect_demo() -> void:
	herbs += 1
	_gain_xp(2)
	demo_message.text = "You collected a moon herb. Herbs: %d." % herbs
	_refresh()

func _demo_quest() -> void:
	_explore()
	if demo_message != null:
		demo_message.text = "Quest updated: " + ("The sigil is recovered. The Moon Court awaits." if quest_done else "Explore the Whispering Forest.")

func _close_playable_demo() -> void:
	if playable_demo != null and is_instance_valid(playable_demo):
		playable_demo.queue_free()
	playable_demo = null
