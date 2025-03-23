class_name Boule extends RigidBody2D


@export var power: int
@export var direction: Vector2
@export var player_nb: int
@export var initial_position: Vector2
#var f = true

# arc throw
var is_arcing = false
var arc_height = 0.0
var max_arc_height = 100.0
var arc_progress = 0.0
var arc_duration = 1.0
var target_position = Vector2.ZERO

# Visual nodes
var sprite
var shadow
var shadow_init_scale

var is_thrown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".gravity_scale = 0
	$".".position = initial_position
	sprite = $Texture
	shadow = $Shadow
	shadow_init_scale = shadow.scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_arcing and !freeze and linear_velocity.length() > 10:
		sprite.rotation_degrees += linear_velocity.length() * 0.2 * delta
	#if f:
		#print_debug("boule 1", position)
		#print_debug("sprite 1", sprite.position)


	if is_arcing:
		# Update arc progress
		arc_progress += delta / arc_duration
		
		if arc_progress >= 1.0:
			# Finish arcing motion
			is_arcing = false
			position = target_position
			sprite.position = Vector2.ZERO
		else:
			# Calculate horizontal movement
			position = initial_position.lerp(target_position, arc_progress)
			
			# Calculate vertical offset for sprite (arc)
			var arc_offset = sin(arc_progress * PI) * max_arc_height
			sprite.position = Vector2(0, -arc_offset)
			
			# Scale shadow based on height
			var scale_factor = 1.0 - (arc_offset / max_arc_height) * 0.3
			shadow.scale = scale_factor * shadow_init_scale
			
	if Input.is_action_just_pressed("tire") and !is_thrown:
		is_thrown = true
		bowling_throw(direction, power)
	elif Input.is_action_just_pressed("pointe") and !is_thrown:
		is_thrown = true
		arc_throw(direction, 2*power)
	
	#if f:
		#print_debug("boule 2", position)
		#print_debug("sprite 2", sprite.position)
		#f=false

func bowling_throw(direction, power):
	# Reset any arcing state
	is_arcing = false
	sprite.position = Vector2.ZERO
	
	freeze = false
	var force = direction.normalized() * power
	force.y += 50  
	
	apply_central_impulse(force)
	sprite.rotation_degrees += power * get_physics_process_delta_time()
	


func arc_throw(direction, power):
	is_arcing = true
	arc_progress = 0.0
	initial_position = position  
	target_position = position + direction.normalized() * power
	max_arc_height = 0.4 * power  
	arc_duration = 0.003 * power
	
	freeze = true
