extends Node2D

@export var controller_nb: int
const MAX_CLICKS = 35
const CLICKS_PER_STAGE = 10

var finished = [0,1,1,1]
var classement = []
var player_sprite = []  # Tableau pour stocker les sprites des joueurs
var player_glasses = []  # Tableau pour stocker les sprites des verres
var score = 0
# Liste des textures pour le verre
var glass_textures = [
	preload("res://art/atomic_petanque/Pastis-1.png"),
	preload("res://art/atomic_petanque/Pastis-2.png"),
	preload("res://art/atomic_petanque/Pastis-3.png"),
	preload("res://art/atomic_petanque/Pastis-4.png"),
	preload("res://art/atomic_petanque/Pastis-5.png"),
	preload("res://art/atomic_petanque/Pastis-6.png"),
	preload("res://art/atomic_petanque/Pastis-7.png"),
]

func _ready():
	$Player1.play("Gégé")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		score += 1
	update_glass_sprite(controller_nb, score)
	if score >=35 and finished[controller_nb]==0:
		classement.append(controller_nb)
		print_debug(classement)
		finished[controller_nb] = 1
	if finished == [1, 1, 1, 1]:
		var sprite_x = get_node("Player1")  # Remplace par le chemin réel
		var sprite_y = get_node("Glass1")  # Remplace par le chemin réel
		var text_box = get_node("Classement")
# Affiche les sprites X et Y
		sprite_x.visible = false
		sprite_y.visible = false
		
		text_box.text = "Classement: \n 1. Player"+str(classement[0])
# Affiche la boîte de texte
		text_box.visible = true
	

func update_glass_sprite(controller_nb,score):
	var glass_sprite = get_node("Glass"+str(controller_nb+1))  # Replace "X" with the correct path if necessary
	# Ensure it's a Sprite2D node
	if glass_sprite is Sprite2D:
		var new_texture_index = min(score/5, glass_textures.size() - 1)
		print_debug("idx"+ str(new_texture_index))
		print_debug("score: "+ str(score))
		if glass_sprite.texture != glass_textures[new_texture_index]:
			glass_sprite.texture = glass_textures[new_texture_index]
