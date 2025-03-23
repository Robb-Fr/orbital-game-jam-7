class_name arena extends Area2D

@export var boule_scene: PackedScene
@export var cochon_scene: PackedScene

var cochon_

var CONTROLLER_TYPES = {"_wasd": 0, "_arrows": 1, "controller_1": 2, "controller_2": 3}

var boules: Array[Array] = [[], [], [], []]

func _on_thrown_ball(controller_type: String, pos: Vector2, dir: Vector2, pow: float) -> void:
	var boule_ = boule_scene.instantiate() 
	boule_.controller_type = controller_type
	boule_.initial_position = to_local(pos)
	boule_.direction = dir
	boule_.power = pow
	boule_.spin_center = cochon_.position

	$".".add_child(boule_)
	boules[CONTROLLER_TYPES[controller_type]].append(boule_)

func _on_player_1_thrown_ball(controller_type: String, pos: Vector2, dir: Vector2, pow: float) -> void:
	_on_thrown_ball(controller_type, pos, dir, pow)

func _on_player_2_thrown_ball(controller_type: String, pos: Vector2, dir: Vector2, pow: float) -> void:
	_on_thrown_ball(controller_type, pos, dir, pow)

func _on_player_1_thrown_cochon(controller_type: String, pos: Vector2, dir: Vector2, pow: float) -> void:
	if cochon_ == null:
		cochon_ = cochon_scene.instantiate() 
		cochon_.controller_type = controller_type
		cochon_.initial_position = to_local(pos)
		cochon_.direction = dir
		cochon_.power = pow
		$".".add_child(cochon_)


func _on_player_2_thrown_cochon(controller_type: String, pos: Vector2, dir: Vector2, pow: float) -> void:
	if cochon_ == null:
		cochon_ = cochon_scene.instantiate() 
		cochon_.controller_type = controller_type
		cochon_.initial_position = to_local(pos)
		cochon_.direction = dir
		cochon_.power = pow
		$".".add_child(cochon_)
#
#func _on_body_entered(body: Node2D) -> void:
	#if ("Player" in body.name):
		#var sprite = body.get_node("Hint")
		#if sprite:
			#sprite.set_visible(true)
#
#func _on_body_exited(body: Node2D) -> void:
	#if ("Player" in body.name):
		#var sprite = body.get_node("Hint")
		#if sprite:
			#sprite.set_visible(false)
