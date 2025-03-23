extends CanvasLayer

var nb_players = 2

@export var select_player_scene: PackedScene
# Notifies `Main` node that the button has been pressed
signal all_players_selected(players: Array[Array])

signal start_minigame

signal all_players_selected_bis(characters: Array)

var selected_characters = [-1, -1, -1, -1]

var mae_char= [-1,-1,-1,-1]
func _ready():
	$HeaderMessage.hide()
	$PlayerSelects.hide()
	$ScoreLabel.hide()
	$NbPlayersBox.hide()
	$EnterNbPlayers.hide()
	$Musique_festive.play()

func on_selected_character(char_name: String, texture: Texture2D, player_index: int):
	selected_characters[player_index] = [char_name, texture]
	#print_debug("Set player {0} to use character {1}".format([player_index, char_name]))
	if selected_characters.count(-1) <= (4 - nb_players):
		print_debug("Selected characters array: " + str(selected_characters))
		all_players_selected.emit(selected_characters)

func show_message(text: String):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	await get_tree().create_timer(1.0).timeout
	
func change_header_message(text: String):
	$HeaderMessage.text = text
	$HeaderMessage.show()

func update_score(score: int):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	$NbPlayersBox.show()
	$EnterNbPlayers.show()
	change_header_message("Select number of players")

func _on_message_timer_timeout():
	$Message.hide()

func _on_all_players_selected(players):
	var i=0
	for item in players:
		if item is int:
			pass
		else:
			mae_char[i]=item[0]
		i=i+1
	all_players_selected_bis.emit(mae_char)
	$HeaderMessage.hide()
	$PlayerSelects.queue_free()
	$BG2.hide()
	$Musique_festive.stop()
	show_message("Press fast to DRINK")
	start_minigame.emit()

func _on_enter_nb_players_pressed():
	$NbPlayersBox.hide()
	$EnterNbPlayers.hide()
	$Background.hide()
	nb_players = $NbPlayersBox.value
	for i in range(nb_players):
		var player_i = select_player_scene.instantiate()
		player_i.current_char = i
		player_i.controller_type = i
		player_i.connect("selected_character", on_selected_character.bind(i))
		$PlayerSelects.add_child(player_i)
	$PlayerSelects.show()
