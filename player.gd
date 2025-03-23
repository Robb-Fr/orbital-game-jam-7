class_name player extends CharacterBody2D

enum positionEnum {RIGHT, LEFT, DOWN, UP}

const MAX_NB_BOULES = 5
var nb_boules = 0
signal thrown_ball(controller_type: String, pos: Vector2, dir: Vector2, pow: float)
signal thrown_cochon(controller_type: String, pos: Vector2, dir: Vector2, pow: float)
var cochon_shot = true

@export var MAX_ETHANOL = 10.0 					# [0;10]
@export var ETHANOL_DECREASE_PER_TICK = 0.01	# float
@export var ETHANOL_PERFECT_RANGE = 5			# int
@export var DILATATION_FACTOR = 2				# int
@export var POWER_INCREASE_PER_TICK = 1		# int

@export var speed = 400
@export var controller_type: String
@export var ethanol_range = 1.5 				# float
@export var ethanol_decrease_buff = 0.0 		# [0;1]
# TODO: implement below features
@export var precision: float					# ???
@export var increasedSpeed: float				# ???
@export var imperturbability: float				# ???

var screen_size
var sprite_size
var half_sprite_size_width = 75
var half_sprite_size_height = 40
var isFacing: positionEnum
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
	current_ethanol = 5.0 # FIXME: remove this
	hide()

func _process(delta):
	# INPUT MANAGEMENT

	var velocity = Vector2.ZERO
	if Input.is_action_pressed("right" + controller_type):
		isFacing = positionEnum.RIGHT
		velocity.x += 1
	if Input.is_action_pressed("left" + controller_type):
		isFacing = positionEnum.LEFT
		velocity.x -= 1
	if Input.is_action_pressed("down" + controller_type):
		isFacing = positionEnum.DOWN
		velocity.y += 1
	if Input.is_action_pressed("up" + controller_type):
		isFacing = positionEnum.UP
		velocity.y -= 1
	if Input.is_action_just_pressed("spawn_ball" + controller_type) and cochon_shot:
		cochon_shot = false
		thrown_cochon.emit(controller_type, position, Vector2(1,0), 200) 
	elif Input.is_action_just_pressed("spawn_ball" + controller_type) and nb_boules < MAX_NB_BOULES:
		nb_boules += 1
		thrown_ball.emit(controller_type, position, Vector2(1,0), 150) 

	#if !can_move:
		#var arena = get_node("Arena")
		#var target_direction = (arena.position - position).normalized()
		#if velocity.length() > 0:
			#velocity = velocity.normalized() * speed
			#$PlayerSprite.play()
		#else:
			#$PlayerSprite.stop()
		#move_and_slide()
		
		if velocity.x != 0:
			$PlayerSprite.animation = "walk"
			$PlayerSprite.flip_v = false
			$PlayerSprite.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$PlayerSprite.animation = "up"
			$PlayerSprite.flip_v = velocity.y > 0
		
	#if Input.is_action_just_pressed("pressX" + str(controller_nb)):
		#if !is_playing && $Hint.visible:
			#$Hint.visible = false
			#on_stadium_entered()
		#elif is_playing:
			#on_stadium_exit()
			
	# STATE MANAGEMENT
	current_ethanol = clamp(current_ethanol - ETHANOL_DECREASE_PER_TICK / (1.0 - ethanol_decrease_buff), 0, MAX_ETHANOL)
	range_ratio = 1 / (1 + abs(current_ethanol - ETHANOL_PERFECT_RANGE) ** 2)
	
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

func on_stadium_entered():
	$PlayerSprite.stop()
	var target_pos = get_node("../Arena").position
	var direction = target_pos - transform.origin
	direction = direction.normalized()
	
	$Range.position = to_local(transform.origin) + direction * 75.0
	$Range.look_at(target_pos)
	$Range.rotation_degrees += 45.0
	$Range.visible = true
	
	var is_at_left = (target_pos - $Power.global_position).x > 0
	if is_at_left:
		$Power.position = to_local(transform.origin) - Vector2(70, 0)
	else:
		$Power.position = to_local(transform.origin) + Vector2(40, 0)
	$Power.position += Vector2(0, -70)
	$Power.visible = true
	is_playing = true
	
#func updateRangeSize():
#	$Range.transform
	
func on_stadium_exit():
	is_playing = false
	$Power.visible = false
	$Range.visible = false
