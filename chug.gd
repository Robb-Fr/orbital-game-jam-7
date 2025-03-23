extends Node2D

const MAX_CLICKS = 30
const CLICKS_PER_STAGE = 10
##Test without signals but just like it

var change_bg

##Other constant need to clean
var for_real=1
var winner
var players_char=[]
var players_ready = false
var controller_nb
var characters_name = ["Gégé", "Oliv","Patoche","Nico"]
var timer_start=true
var can_click = false
var finished = [0,0,0,0]
var classement = []
var player_sprite = []  # Tableau pour stocker les sprites des joueurs
var player_glasses = []  # Tableau pour stocker les sprites des verres
var score_0 = 0
var score_1 = 0
var score_2 = 0
var score_3 = 0
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
signal lets_play
signal player_chars_are(Array)
signal winner_is(id)

func _ready():
	var scene_a = get_node("HUD")  # Change selon ta structure
	# Connecte SceneB au signal de SceneA
	if scene_a:
		print("SceneB attend le signal de SceneA...")
	else:
		print("Erreur : Impossible de trouver SceneA")
	change_bg = preload("res://art/atomic_petanque/Leaderboard.png")

func _process(delta):
	if can_click and Input.is_action_just_pressed("action_wasd"):
		if players_char[0] is String:
			score_0 += 1
			controller_nb=0
			update_glass_sprite(controller_nb, score_0)
			if score_0 >=MAX_CLICKS and finished[controller_nb]==0:
				$Burp.play()
				get_node("Glass"+str(controller_nb)).visible=false
				classement.append(controller_nb)
				finished[controller_nb] = 1
	if can_click and Input.is_action_just_pressed("action_arrows"):
		if players_char[1] is String:
			score_1 += 1
			controller_nb=1
			update_glass_sprite(controller_nb, score_1)
			if score_1 >=MAX_CLICKS and finished[controller_nb]==0:
				$Burp.play()
				get_node("Glass"+str(controller_nb)).visible=false
				classement.append(controller_nb)
				finished[controller_nb] = 1
	if can_click and Input.is_action_just_pressed("action_controller_1"):
		if players_char[2] is String:
			score_2 += 1
			controller_nb=2
			update_glass_sprite(controller_nb, score_2)
			if score_2 >=MAX_CLICKS and finished[controller_nb]==0:
				$Burp.play()
				get_node("Glass"+str(controller_nb)).visible=false
				classement.append(controller_nb)
				finished[controller_nb] = 1
	if can_click and Input.is_action_just_pressed("action_controller_2"):
		if players_char[3] is String:
			score_3 += 1
			controller_nb=3
			update_glass_sprite(controller_nb, score_3)
			if score_3 >=MAX_CLICKS and finished[controller_nb]==0:
				$Burp.play()
				get_node("Glass"+str(controller_nb)).visible=false
				classement.append(controller_nb)
				finished[controller_nb] = 1
	if finished == [1, 1, 1, 1] and for_real==1:
		$Glouglou.stop()
# Affiche les sprites X et Y
		var text_temp="Classement: "
		for i in range (0,4):
			if players_char[i] is String:
				get_node("Player"+str(i)).visible = false
				get_node("Glass"+str(i)).visible = false
				text_temp+="\n"+str(i+1)+". Player"+str(classement[i])
		winner=classement[0]
		$Bg.texture = change_bg
		$Bg.visible = false

		$Classement.text = text_temp
# Affiche la boîte de texte
		$Classement.visible = true
		$Button.visible = true
		$Bg.visible = true
	
func update_glass_sprite(controller_nb,score):
	var glass_sprite = get_node("Glass"+str((controller_nb)))
	# Ensure it's a Sprite2D node
	if glass_sprite is Sprite2D:
		var new_texture_index = min(score/5, glass_textures.size() - 1)
		if glass_sprite.texture != glass_textures[new_texture_index]:
			glass_sprite.texture = glass_textures[new_texture_index]


func _on_countdown_timeout() -> void:
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
		$Glouglou.play()

func _start_scene():
	for i in range (0,4):
		if players_char[i] is int:
			get_node("Player"+str(i)).visible=false
			get_node("Glass"+str(i)).visible=false
			finished[i]=1
		else:
			var player_name= get_node("Player"+str(i))
			player_name.play(players_char[i])
	# Cache les sprites au début
	$"3".visible = false
	$"2".visible = false
	$"1".visible = false
	$"Buvez!".visible = false
	
	await get_tree().create_timer(1.5).timeout  
	$Counting.play()
	$Countdown.start()
	
func _on_hud_start_minigame() -> void:
	print('starting')
	_start_scene()# Replace with function body.

func _on_hud_all_players_selected_bis(characters: Array) -> void:
	players_char=characters

func hide_all_sprites():
	for node in get_children():
		if node is Sprite2D or node is AnimatedSprite2D:
			node.hide()


func _on_button_pressed() -> void:
	for_real=0
	print_debug("pressed mon sang")
	player_chars_are.emit(players_char) #i.e. ["Gégé","Oliv",-1,-1]
	winner_is.emit(winner) # Replace with function body.
	$Classement.visible = false
	$Button.visible = false
	$Bg.visible = false
