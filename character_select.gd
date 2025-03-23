extends Control

var characters = [
	["Gégé", preload("res://art/atomic_petanque/players/gégé_moustache_de_feu.png")],
	["Oliv", preload("res://art/atomic_petanque/players/oliv_chaussettes_deparaillees.png")],
	["Patoche", preload("res://art/atomic_petanque/players/patoche_au_bob.png")],
	["Nico", preload("res://art/atomic_petanque/players/nico_la_gaypride.png")],
]

var controllers = [
	["wasd", preload("res://art/atomic_petanque/controller_icons/wasd.png")],
	["arrows", preload("res://art/atomic_petanque/controller_icons/arrows.png")],
	["controller_1", preload("res://art/atomic_petanque/controller_icons/joypad_1.png")],
	["controller_2", preload("res://art/atomic_petanque/controller_icons/joypad_2.png")],
]

signal selected_character(name: String, texture_url: Texture2D)

@export var current_char = 0
@export var controller_type = 0

var selection_events: Array[String]
var action_events: Array[String]

func _ready():
	$HBoxContainer/CharacterName.text = characters[current_char][0]
	$HBoxContainer/CharacterIcon.set_texture(characters[current_char][1])
	$HBoxContainer/ControllerIcon.set_texture(controllers[controller_type][1])
	for dir in ["up", "down", "left", "right"]:
		var action_name = dir + "_" + controllers[controller_type][0]
		selection_events.append(action_name)
	action_events = ["action_" + controllers[controller_type][0]]

func _process(delta):
	for e in selection_events:
		if Input.is_action_just_pressed(e):
			$HBoxContainer/ChangeCharacter.pressed.emit()
	for e in action_events:
		if Input.is_action_just_pressed(e):
			$HBoxContainer/SelectCharacter.pressed.emit()

func _on_change_character_pressed():
	var next_char_index = (current_char + 1) % len(characters)
	var next_char = characters[(current_char + 1) % len(characters)]
	$HBoxContainer/CharacterName.text = next_char[0]
	$HBoxContainer/CharacterIcon.set_texture(next_char[1])
	current_char = next_char_index

func _on_select_character_pressed():
	$HBoxContainer/SelectCharacter.disabled = true
	$HBoxContainer/ChangeCharacter.disabled = true
	#print_debug("Emitting {0} and {1}".format([characters[current_char][0], characters[current_char][1]]))
	selected_character.emit(characters[current_char][0], characters[current_char][1])
