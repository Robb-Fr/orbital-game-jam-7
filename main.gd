extends Node

@export var mob_scene: PackedScene
var nb_players = 2

func _ready():
	pass
	
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
	$Music.play()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
