extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()
