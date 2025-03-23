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
	$Player1.controller_nb = 0
	$Player2.controller_nb = 1
	$Player3.controller_nb = 2
	$Player4.controller_nb = 3
	
func new_game():
	init_player_controller()
	$Player1.start(gen_start_position())
	$Player2.start(gen_start_position())
	#$Player3.start(gen_start_position())
	#$Player4.start(gen_start_position())
	#$Music.play()
