extends Node

@export var mob_scene: PackedScene
var winner

func _ready():
	var scene_a = get_node("Chug")
	if scene_a:
		print("SceneB attend le signal de SceneA...")
	else:
		print("Erreur : Impossible de trouver SceneA")
	
func game_over():
	$Music.stop()
	$DeathSound.play()
	
func gen_start_position():
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	return mob_spawn_location.position 

func _on_chug_player_chars_are(players: Variant) -> void:
	for i in range(0, 4):
		if players[i] is String:
			var player = get_node("Player" + str(i + 1))
			match i:
				0:
					player.controller_name = 'wasd'
				1:
					player.controller_name = 'arrows'
				_:
					player.controller_name = 'controller_' + str(i - 1)
			print(player.controller_name)
			player.sprite_name = players[i]
			player.ethanol_bar_ref = $HUD_main.find_child('ProgressBar' + str(i + 1))
			player.ethanol_bar_ref.visible = true
			player.start(gen_start_position())

func _on_chug_winner_is(id: Variant) -> void:
	winner = id # TODO: implémenter le cochon


func _on_player_3_thrown_cochon(controller_type: String, pos: Vector2, dir: Vector2, pow: float) -> void:
	pass # Replace with function body.
