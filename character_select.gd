extends Control

var characters = [
	["Gégé", "res://art/atomic_petanque/players/gégé_moustache_de_feu.png"],
	["Oliv", "res://art/atomic_petanque/players/oliv_chaussettes_deparaillees.png"],
	["Patoche", "res://art/atomic_petanque/players/patoche_au_bob.png"],
	["Nico", "res://art/atomic_petanque/players/nico_la_gaypride.png"]
]

signal selected_character(name: String, texture_url: String)

@export var current_char = 0

func _ready():
	$HBoxContainer/CharacterName.text = characters[current_char][0]
	var texture: Texture2D = load(characters[current_char][1])
	$HBoxContainer/CharacterIcon.set_texture(texture)

func _on_change_character_pressed():
	var next_char_index = (current_char + 1) % len(characters)
	var next_char = characters[(current_char + 1) % len(characters)]
	$HBoxContainer/CharacterName.text = next_char[0]
	var next_texture: Texture2D = load(next_char[1])
	$HBoxContainer/CharacterIcon.set_texture(next_texture)
	current_char = next_char_index

func _on_select_character_pressed():
	$HBoxContainer/SelectCharacter.disabled = true
	$HBoxContainer/ChangeCharacter.disabled = true
	#print_debug("Emitting {0} and {1}".format([characters[current_char][0], characters[current_char][1]]))
	selected_character.emit(characters[current_char][0], characters[current_char][1])
