extends Node

@export var mob_scene: PackedScene
var nb_players = 2

func _ready():
	new_game()
	
func game_over():
	$Music.stop()
	$DeathSound.play()
	
func gen_start_position():
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf() # clamp to screen - margin
	return mob_spawn_location.position 

func init_player_controller():
	$Player1.controller_type = 'arrows'
	$Player1.ethanol_bar_ref = $HUD_main.find_child('ProgressBar1')
	$Player2.controller_type = 'wasd'
	$Player2.ethanol_bar_ref = $HUD_main.find_child('ProgressBar2')
	$Player3.controller_type = 'controller_1'
	$Player3.ethanol_bar_ref = $HUD_main.find_child('ProgressBar3')
	$Player4.controller_type = 'controller_2'
	$Player4.ethanol_bar_ref = $HUD_main.find_child('ProgressBar4')

	
func new_game():
	init_player_controller()
	$Player1.start(gen_start_position())
	$Player2.start(gen_start_position())
	#$Player3.start(gen_start_position())
	#$Player4.start(gen_start_position())
	#$Player1.not_instanciated()
	#$Music.play()
