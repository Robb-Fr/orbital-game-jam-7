extends CanvasLayer

const NB_PLAYERS = 4

@export var select_player_scene: PackedScene
# Notifies `Main` node that the button has been pressed
signal all_players_selected(players: Array[Array])

var selected_characters = [-1, -1, -1, -1]

func _ready():
	$HeaderMessage.hide()
	$PlayerSelects.hide()
	$ScoreLabel.hide()
	for i in range(NB_PLAYERS):
		var player_i = select_player_scene.instantiate()
		player_i.current_char = i
		player_i.connect("selected_character", on_selected_character.bind(i))
		$PlayerSelects.add_child(player_i)

func on_selected_character(char_name: String, texture_url: String, player_index: int):
	selected_characters[player_index] = [char_name, texture_url]
	#print_debug("Set player {0} to use character {1}".format([player_index, char_name]))
	if not selected_characters.has(-1):
		# all_player_selected.emit(selected_characters)
		print_debug("Selected characters array: " + str(selected_characters))
		all_players_selected.emit(selected_characters)

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	await get_tree().create_timer(1.0).timeout
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	$Message.hide()
	$PlayerSelects.show()
	$HeaderMessage.show()

func _on_message_timer_timeout():
	$Message.hide()

func _on_all_players_selected(players):
	$HeaderMessage.hide()
	$PlayerSelects.queue_free()
	$Background.hide()
	show_message("Press <?> to DRINK")
