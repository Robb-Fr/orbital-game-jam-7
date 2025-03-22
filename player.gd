extends Area2D

enum positionEnum {RIGHT, LEFT, DOWN, UP}

signal hit

@export var speed = 400
@export var controller_nb: int
@export var ethanol_decrease = 10
@export var ethanol_perfect = 5

var screen_size
var sprite_size
var isFacing: positionEnum
var half_sprite_size = 100

# GAMING VARS
var ethanol: float
var ethanol_decrease_rate: float # depends on the addiction status
var perfect_state_range: float # depends on the addiction status
var precision: float
var increasedSpeed: float
var imperturbability: float

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	$Range.visible = false

func _ready():
	screen_size = get_viewport_rect().size
	isFacing = positionEnum.RIGHT
	
	ethanol = 50
	ethanol_decrease_rate = 0.1
	perfect_state_range = 2
	
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
	# TODO: implement this
	ethanol = clamp(ethanol - ethanol_decrease * ethanol_decrease_rate, 0, 100)
	
	var res = 1 #lol
	print_debug(ethanol)
	print_debug(res)

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
	return # TODO implement this with the alcool
	
func _on_stadium_exit():
	$Power.visible = false
	$Range.visible = false
			
func _on_body_entered(body):
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
