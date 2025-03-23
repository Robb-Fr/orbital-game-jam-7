class_name arena extends Area2D

@export var boule_scene: PackedScene

var boules: Array[Array] = [[], [], [], []]

func _on_thrown_ball(player_nb: int, pos: Vector2, dir: Vector2, pow: float) -> void:
	var boule = boule_scene.instantiate() 
	boule.player_nb = player_nb
	boule.initial_position = to_local(pos)
	boule.direction = dir
	boule.power = pow
	$".".add_child(boule)
	boules[player_nb].append(boule)

func _on_player_1_thrown_ball(pos: Vector2, dir: Vector2, pow: float) -> void:
	_on_thrown_ball(0, pos, dir, pow)

func _on_player_2_thrown_ball(pos: Vector2, dir: Vector2, pow: float) -> void:
	_on_thrown_ball(1, pos, dir, pow)
