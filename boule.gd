class_name boule extends RigidBody2D

@export var controller_type: String
@export var power: int
@export var direction: Vector2
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

var is_thrown = false

#spin 
var is_spinning = false
var spin_center: Vector2
var spin_radius: float
var spin_speed: float  # Radians per second
var current_angle = 0.0

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
			is_spinning = true and $"." is not cochon
		
		else:
			# Calculate horizontal movement
			position = initial_position.lerp(target_position, arc_progress)
			
			# Calculate vertical offset for sprite (arc)
			var arc_offset = sin(arc_progress * PI) * max_arc_height
			sprite.position = Vector2(0, -arc_offset)
			
			# Scale shadow based on height
			var scale_factor = 1.0 - (arc_offset / max_arc_height) * 0.3
			shadow.scale = scale_factor * shadow_init_scale
	
	if is_spinning:
			current_angle += spin_speed * delta
			
			# Calculate new position on the circle
			var new_position = spin_center + Vector2(
				cos(current_angle) * spin_radius,
				sin(current_angle) * spin_radius
			)
			
			# Update position
			position = new_position
			
			# Make the sprite rotate as it spins
			sprite.rotation_degrees += 360 * delta	
			
	if Input.is_action_just_pressed("tirer_" + controller_type) and !is_thrown:
		is_thrown = true
		bowling_throw(direction, power)
	elif Input.is_action_just_pressed("pointer_" + controller_type) and !is_thrown:
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
	spin_radius = abs(spin_center.distance_to(target_position))
	spin_speed = remap(spin_radius, 1, 1000, 1, 10)
	freeze = true
	
