extends CanvasLayer

signal start_game
signal all_player_selected(player: Array[int])
signal new_player_selected(player_index: int, character_index: int)

var selected_characters = [-1, -1, -1, -1]

func _ready():
	$PlayerSelects.hide()
	$ScoreLabel.hide()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	
	$StartButton.hide()
	$Message.hide()
	$PlayerSelects.show()

func _on_message_timer_timeout():
	$Message.hide()

func _on_all_player_selected():
	$CharacterSelectionList.hide()
	all_player_selected.emit()

func _on_select_player_1_selected_character(index):
	new_player_selected.emit(0, index)

func _on_select_player_2_selected_character(index):
	new_player_selected.emit(1, index)

func _on_select_player_3_selected_character(index):
	new_player_selected.emit(2, index)

func _on_select_player_4_selected_character(index):
	new_player_selected.emit(3, index)

func _on_new_player_selected(player_index, character_index):
	selected_characters[player_index] = character_index
	if not selected_characters.has(-1):
		all_player_selected.emit(selected_characters)
		print_debug("Selected characters array: " + str(selected_characters))
		$PlayerSelects.queue_free()
