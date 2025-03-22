class_name player extends Area2D

enum positionEnum {RIGHT, LEFT, DOWN, UP}

signal hit

@export var MAX_ETHANOL = 10.0 					# [0;10]
@export var ETHANOL_DECREASE_PER_TICK = 0.01	# float
@export var ETHANOL_PERFECT_RANGE = 5			# int
@export var DILATATION_FACTOR = 2				# int

@export var speed = 400
@export var controller_nb: int
@export var ethanol_range = 1.5 				# float
@export var ethanol_decrease_buff = 0.0 		# [0;1]
# TODO: implement below features
@export var precision: float					# ???
@export var increasedSpeed: float				# ???
@export var imperturbability: float				# ???

var screen_size
var sprite_size
var half_sprite_size = 100
var isFacing: positionEnum
var current_ethanol: float
var range_ratio: float

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	$Range.visible = false

func _ready():
	screen_size = get_viewport_rect().size
	isFacing = positionEnum.RIGHT
	range_ratio = 1.0
	current_ethanol = 5.0 # FIXME: remove this
	hide()

func _process(delta):
	# INPUT MANAGEMENT
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("right" + str(controller_nb)):
		isFacing = positionEnum.RIGHT
		velocity.x += 1
	if Input.is_action_pressed("left" + str(controller_nb)):
		isFacing = positionEnum.LEFT
		velocity.x -= 1
	if Input.is_action_pressed("down" + str(controller_nb)):
		isFacing = positionEnum.DOWN
		velocity.y += 1
	if Input.is_action_pressed("up" + str(controller_nb)):
		isFacing = positionEnum.UP
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$PlayerSprite.play()
	else:
		$PlayerSprite.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$PlayerSprite.animation = "walk"
		$PlayerSprite.flip_v = false
		$PlayerSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$PlayerSprite.animation = "up"
		$PlayerSprite.flip_v = velocity.y > 0
		
	# STATE MANAGEMENT
	current_ethanol = clamp(current_ethanol - ETHANOL_DECREASE_PER_TICK / (1.0 - ethanol_decrease_buff), 0, MAX_ETHANOL)
	range_ratio = 1 / (1 + abs(current_ethanol - ETHANOL_PERFECT_RANGE) ** 2)

func _on_stadium_entered():
	match isFacing:
		positionEnum.LEFT:
			$Power.transform.origin = transform.origin + Vector2(half_sprite_size, 0)
			$Range.transform.origin = transform.origin - Vector2(half_sprite_size, 0)
		_:
			$Power.transform.origin = transform.origin - Vector2(half_sprite_size, 0)
			$Range.transform.origin = transform.origin + Vector2(half_sprite_size, 0)

	$Power.visible = true
	$Range.visible = true
	updateRangeSize()
	
func updateRangeSize():
	$Range.transform
	
func _on_stadium_exit():
	$Power.visible = false
	$Range.visible = false


func _on_area_entered(area: Area2D) -> void:
	if (area is arena):
		print_debug('this is an arena')
	if (area is player):
		print_debug('this is a player')
