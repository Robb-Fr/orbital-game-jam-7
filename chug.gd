extends Node2D

@export var controller_nb: int
const MAX_CLICKS = 30
const CLICKS_PER_STAGE = 10
##Test without signals but just like it
var characters = [1,2,3,0]

##Other constant need to clean
var characters_name = ["Gégé", "Oliv","Patoche","Nico"]
var timer_start=true
var can_click = false
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
	$Counting.play()
	for i in range (0,4):
		if characters[i]==-1:
			get_node("Player"+str(i)).visible=false
			get_node("Glass"+str(i)).visible=false
		else:
			var player_name= get_node("Player"+str(i))
			print_debug(player_name)
			player_name.play(characters_name[characters[i]])
	# Cache les sprites au début
	$"3".visible = false
	$"2".visible = false
	$"1".visible = false
	$"Buvez!".visible = false
	
	$Countdown.start()

func _process(delta):
	if can_click and Input.is_action_just_pressed("ui_accept"):
		score += 1
	if can_click and Input.is_action_just_pressed("ui_accept"):
		score += 1
	update_glass_sprite(controller_nb, score)
	if score >=MAX_CLICKS and finished[controller_nb]==0:
		#$Burp.play()
		get_node("Glass"+str(controller_nb)).visible=false
		classement.append(controller_nb)
		finished[controller_nb] = 1
	if finished == [1, 1, 1, 1]:
		$Glouglou.stop()
# Affiche les sprites X et Y
		get_node("Player"+str(controller_nb)).visible = false
		get_node("Glass"+str(controller_nb)).visible = false
		$Bg.visible = false
		
		$Classement.text = "Classement: \n 1. Player"+str(classement[0])
# Affiche la boîte de texte
		$Classement.visible = true
	

func update_glass_sprite(controller_nb,score):
	var glass_sprite = get_node("Glass"+str(controller_nb+1))  # Replace "X" with the correct path if necessary
	# Ensure it's a Sprite2D node
	if glass_sprite is Sprite2D:
		var new_texture_index = min(score/5, glass_textures.size() - 1)
		if glass_sprite.texture != glass_textures[new_texture_index]:
			glass_sprite.texture = glass_textures[new_texture_index]


func _on_countdown_timeout() -> void:
	print_debug("timeout")
	# Vérifie quelle étape du compte à rebours est en cours
	if	timer_start:
		timer_start=false
		$"3".visible = true
		$Countdown.start()
	elif $"3".visible:
		# Cache le 3 et affiche le 2
		$"3".visible = false
		$"2".visible = true
		$Countdown.start()  # Redémarre le Timer pour passer à 1
	elif $"2".visible:
		# Cache le 2 et affiche le 1
		$"2".visible = false
		$"1".visible = true
		$"Countdown".start()  # Redémarre le Timer pour passer à l'action
	elif $"1".visible:
		# Cache le 2 et affiche le 1
		$"1".visible = false
		$"Buvez!".visible = true
		$"Countdown".start()  # Redémarre le Timer pour passer à l'action
	elif $"Buvez!".visible:
		$"Buvez!".visible = false
		can_click = true  # Permet de cliquer après le compte à rebours
		print("Le compte à rebours est terminé, vous pouvez maintenant cliquer!")
		$Glouglou.play()
