class_name player extends CharacterBody2D

signal boule(s_position: Vector2, s_direction: Vector2)

enum hint_sprites {X, E}

const MAX_NB_BOULES = 5
var nb_boules = 0
signal thrown_ball(controller_type: String, pos: Vector2, dir: Vector2, pow: float)
signal thrown_cochon(controller_type: String, pos: Vector2, dir: Vector2, pow: float)
var cochon_shot = true


@export var MAX_ETHANOL = 10.0 					# [0;10]
@export var ETHANOL_DECREASE_PER_TICK = 0.005	# float
@export var ETHANOL_PERFECT_RANGE = 5			# int
@export var DILATATION_FACTOR = 3				# int
@export var POWER_INCREASE_PER_TICK = 1		# int
@export var MAX_RANGE_ANGLE = 2					# int
@export var NUM_SIDES_POLYG = 10				# int
@export var PIXEL_CHANGE = 5					# int

@export var speed = 400
@export var controller_name: String
@export var player_name: String
@export var ethanol_bar_ref: ProgressBar
@export var ethanol_range = 1.5 				# float
@export var ethanol_decrease_buff = 0.0 		# [0;1]
@export var sprite_dict = {
	hint_sprites.X: x_sprite,
	hint_sprites.E: e_sprite
}
@export var sprite_name: String

# TODO: implement below features
@export var precision: float					# ???
@export var increasedSpeed: float				# ???
@export var imperturbability: float				# ???
const x_sprite = "res://art/atomic_petanque/controllers/x.png"
const e_sprite = "res://art/atomic_petanque/controllers/b.png"

var screen_size
var sprite_size
var half_sprite_size_width = 75
var half_sprite_size_height = 40
var current_ethanol: float
var range_ratio: float
var is_playing = false
var power_is_increasing = true

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	$Power.visible = false
	$Range.visible = false
	$Hint.visible = false

func _ready():
	screen_size = get_viewport_rect().size
	range_ratio = 1.0
	current_ethanol = 0.0
	hide()

func _process(delta):
	# INPUT MANAGEMENT
	if !is_playing:
		velocity = Vector2.ZERO
		if Input.is_action_pressed("right_" + str(controller_name)):
			velocity.x += 1
		if Input.is_action_pressed("left_" + str(controller_name)):
			velocity.x -= 1
		if Input.is_action_pressed("down_" + str(controller_name)):
			velocity.y += 1
		if Input.is_action_pressed("up_" + str(controller_name)):
			velocity.y -= 1
			
		if Input.is_action_just_pressed("spawn_ball_" + controller_name) and cochon_shot:
			cochon_shot = false
			thrown_cochon.emit(controller_name, position, Vector2(1,0), 200) 
		elif Input.is_action_just_pressed("spawn_ball_" + controller_name) and nb_boules < MAX_NB_BOULES:
			nb_boules += 1
			thrown_ball.emit(controller_name, position, Vector2(1,0), 150)

		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			$PlayerSprite.play()
		else:
			$PlayerSprite.stop()
		move_and_slide()
		
		#if velocity.x != 0:
			#$PlayerSprite.animation = "walk"
			#$PlayerSprite.flip_v = false
			#$PlayerSprite.flip_h = velocity.x < 0
		#elif velocity.y != 0:
			#$PlayerSprite.animation = "up"
			#$PlayerSprite.flip_v = velocity.y > 0
	elif (is_playing && $Beam.visible):
		var wanted_change: int
		if Input.is_action_pressed("right_" + str(controller_name)):
			wanted_change = 1
		if Input.is_action_pressed("left_" + str(controller_name)):
			wanted_change = -1
		
		#$Beam.rotation_degrees += wanted_change
		update_beam()
		var updated_scale = MAX_RANGE_ANGLE * clamp((1.0 - range_ratio), 0.1, 1)
		$Beam.scale = Vector2(updated_scale, updated_scale)
		var target_pos = get_node("../Arena").position
		var direction = (target_pos - position).normalized()
		var sprite_current_size = $Beam.texture.get_size() * updated_scale
		$Beam.position = to_local(position) + sprite_current_size / 2 * direction
		$Beam.visible = true
		
		#$Marker2D.position = Vector2(
			#$Marker2D.position.x * cos($Marker2D.rotation_degrees + wanted_change),
			#$Marker2D.position.y * sin($Marker2D.rotation_degrees + wanted_change)
		#)
		#$Marker2D.rotation_degrees += wanted_change
		
		#var target_pos = get_node("../Arena").position
		#var direction = target_pos - $Range.position
		#direction = direction.normalized()
		#var center = $Range.position + direction * 100
		#$Marker2D.position = $Range.position + Vector2(
			#100 * cos(deg_to_rad($Range.rotation_degrees) + 67.6),
			#100 * sin(deg_to_rad($Range.rotation_degrees) + 67.5)
		#)
		
		# FIXME: GL as the Marker2D is not centered, it's borken :) 
		#var A = ($Marker2D.position - $Range.position).normalized()
		#var B = target_pos.normalized()
		#var dot_prod = clamp(A.dot(B), 0, 1)
		#$Range.rotation_degrees += wanted_change
		#print(dot_prod)
		#if dot_prod != 0:
			#$Range.rotation_degrees += wanted_change
		#else:
			#$Range.rotation_degrees -= wanted_change
		
	if Input.is_action_just_pressed("action_" + str(controller_name)):
		if !is_playing && $Hint.visible:
			$Hint.visible = false
			on_stadium_entered()
		elif is_playing:
			on_stadium_exit()
			
	if Input.is_action_just_pressed("scope_" + str(controller_name)):
		if is_playing:
			on_shot()
			on_stadium_exit()
			
	# STATE MANAGEMENT
	current_ethanol = clamp(current_ethanol - ETHANOL_DECREASE_PER_TICK / (1.0 - ethanol_decrease_buff), 0, MAX_ETHANOL)
	range_ratio = 1 / (1 + abs(current_ethanol - ETHANOL_PERFECT_RANGE) ** 2)
	if current_ethanol && ethanol_bar_ref:
		ethanol_bar_ref.set_value(current_ethanol)
	
	var power_ref = $Power
	if is_playing:
		if power_is_increasing:
			power_ref.value += clamp(POWER_INCREASE_PER_TICK, 0, power_ref.max_value)
			if power_ref.value == power_ref.max_value:
				power_is_increasing = false
		else:
			power_ref.value -= clamp(POWER_INCREASE_PER_TICK, 0, power_ref.max_value)
			if power_ref.value == power_ref.min_value:
				power_is_increasing = true
				
func set_image(sprite: hint_sprites):
	match sprite:
		hint_sprites.E:
			$Hint.texture = preload(e_sprite)
		hint_sprites.X:
			$Hint.texture = preload(x_sprite)
			
func update_beam():
	var target_pos = get_node("../Arena").position
	var direction = target_pos - transform.origin
	direction = direction.normalized()
	var actual_angle_of_range = MAX_RANGE_ANGLE * clamp((1.0 - range_ratio), 0.1, 1)
	$Beam.look_at(target_pos)
	$Beam.rotation_degrees -= 90
	
	#var half_actual_range = actual_angle_of_range / 2
	#$Range.position = to_local(transform.origin) + direction * 50.0
	#$Range.look_at(target_pos)
	#$Range.rotation_degrees += (90 - half_actual_range)
	#$Marker2D.scale = Vector2(actual_angle_of_range, actual_angle_of_range)
	#$Marker2D.position = to_local(transform.origin) + direction * 75
	#$Marker2D.look_at(target_pos)
	#$Marker2D.rotation_degrees += 270

func on_stadium_entered():
	$PlayerSprite.stop()
	is_playing = true
	
	var target_pos = get_node("../Arena").position
	var is_at_left = (target_pos - $Power.global_position).x > 0
	if is_at_left:
		$Power.position = to_local(transform.origin) - Vector2(70, 0)
	else:
		$Power.position = to_local(transform.origin) + Vector2(40, 0)
	$Power.position += Vector2(0, -70)
	set_image(hint_sprites.E)
	$Power.visible = true
	$Hint.visible = true
	update_beam()
	$Beam.visible = true
	
	#var direction = target_pos - transform.origin
	#direction = direction.normalized()
	#var actual_angle_of_range = MAX_RANGE_ANGLE * clamp((1.0 - range_ratio), 0.1, 1)
	#var half_actual_range = actual_angle_of_range / 2
	#$Range.position = to_local(transform.origin) + direction * 50.0
	#$Range.look_at(target_pos)
	#$Range.rotation_degrees += (90 - half_actual_range)
	#draw_range_arc(100, NUM_SIDES_POLYG, actual_angle_of_range)
	#$Marker2D.scale = Vector2(actual_angle_of_range, actual_angle_of_range)
	#$Marker2D.position = to_local(transform.origin) + direction * 75
	#$Marker2D.look_at(target_pos)
	#$Marker2D.rotation_degrees += 270
	#$Marker2D.visible = true

#func draw_range_arc(radius: float, num_sides: int, angle: float)  -> void:
	#var points = PackedVector2Array()
	#var center = Vector2(to_local(position))
	#points.push_back(center)
	#for i in range(num_sides):
		#var point = deg_to_rad(i * angle / num_sides - 90)
		#var vect = Vector2.ZERO + Vector2(cos(point), sin(point)) * radius
		#points.push_back(vect)
	#$Range.polygon = points
	#$Range.visible = true
	
func on_stadium_exit():
	set_image(hint_sprites.X)
	is_playing = false
	$Power.visible = false
	$Range.visible = false
	$Beam.visible = false
	#$Marker2D.visible = false
	
func on_shot():
	var target_pos = get_node("../Arena").position
	var direction = target_pos - transform.origin
	direction = direction.normalized()
	
	var random_offset = Vector2(
		randf_range(-range_ratio * PIXEL_CHANGE, range_ratio * PIXEL_CHANGE),
		randf_range(-range_ratio * PIXEL_CHANGE, range_ratio * PIXEL_CHANGE)
	)
	
	# TODO TOM: faudrait s'assurer si ça c'est ok hihi	
	var randomized_direction = direction + direction.normalized() * range_ratio * random_offset
	print("Vecteur initial : ", direction)
	print("Vecteur modifié : ", randomized_direction)
	
	boule.emit(position, direction)
