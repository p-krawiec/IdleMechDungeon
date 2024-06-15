extends Control
class_name HUD

@export var player: Player

@onready var time_label = $TimeLabel
@onready var ammo_container = $AmmoContainer
@onready var reload_label = $ReloadLabel

@onready var normal_hearts = $HeartContainer/NormalHearts
@onready var golden_hearts = $HeartContainer/GoldenHearts

var empty_cell_sprite = preload("res://Assets/UI/empty cell x3.png")
var full_cell_sprite = preload("res://Assets/UI/full cell x3.png")

var empty_heart_sprite = preload("res://Assets/UI/heart empty v2 x3.png")
var full_heart_sprite = preload("res://Assets/UI/heart full v3 x3.png")
var half_heart_sprite = preload("res://Assets/UI/heart half v3 x3.png")

var full_golden_heart_sprite = preload("res://Assets/UI/golden heart full v3 x3.png")
var half_golden_heart_sprite = preload("res://Assets/UI/golden heart half v3 x3.png")

var player_hp_component: HealthComponent

func _ready():
	$WaveLabel.visible = false
	
	player_hp_component = player.health_component
	recalculate_ammo()
	recalculate_health()
	recalculate_golden_hearts()
	reload_label.get_child(0).play("reload")

func _process(_delta):
	display_time()
	display_ammo()
	display_reload()
	display_health()
	display_golden_health()

func recalculate_ammo():
	for child in ammo_container.get_children():
		child.queue_free()
	
	for i in range(player.max_ammo):
		var ammo_rect = TextureRect.new() as TextureRect
		ammo_rect.texture = empty_cell_sprite
		ammo_container.add_child(ammo_rect)
	
func recalculate_health():
	for child in normal_hearts.get_children():
		child.queue_free()
	
	for i in range(player_hp_component.max_health / 2):
		var hp_rect = TextureRect.new() as TextureRect
		hp_rect.texture = full_heart_sprite
		normal_hearts.add_child(hp_rect)

func recalculate_golden_hearts():
	for child in golden_hearts.get_children():
		child.queue_free()
		
	var i = player_hp_component.max_golden_health
	while i > 0:
		var hp_rect = TextureRect.new() as TextureRect
		if i % 2 == 0:
			hp_rect.texture = full_golden_heart_sprite
			i -= 1
		else:
			hp_rect.texture = half_golden_heart_sprite
		golden_hearts.add_child(hp_rect)
		golden_hearts.move_child(hp_rect, 0)
		i -= 1

func display_time():
	time_label.text = Util.get_formatted_time()
	
func display_ammo():
	var i = 1
	for ammo in ammo_container.get_children():
		if i <= player.current_ammo:
			ammo.texture = full_cell_sprite
		else:
			ammo.texture = empty_cell_sprite
		i += 1

func display_health():
	var total_hearts = (player_hp_component.max_health / 2)
	var current_health = player_hp_component.current_health
	
	for i in range(total_hearts):
		var heart = normal_hearts.get_child(i)
		
		if current_health > (2 * (i + 1) - 1):
			heart.texture = full_heart_sprite
		elif current_health >= (2 * i + 1) and current_health < (2 * (i + 1)):
			heart.texture = half_heart_sprite
		else:
			heart.texture = empty_heart_sprite
	

func display_golden_health():
	var total_hearts = golden_hearts.get_child_count()
	var golden_health = player_hp_component.current_golden_health
	
	for i in range(total_hearts):
		var heart = golden_hearts.get_child(i)
		
		if golden_health > (2 * (i + 1) - 1):
			heart.texture = full_golden_heart_sprite
		elif golden_health >= (2 * i + 1) and golden_health < (2 * (i + 1)):
			heart.texture = half_golden_heart_sprite
		else:
			heart.queue_free()

func display_reload():
	if player.is_dead:
		reload_label.visible = false
		return
	
	if player.current_ammo != 0:
		reload_label.visible = false
	else:
		reload_label.visible = true

func display_wave_text(text):
	$WaveLabel.text = text
	$WaveLabel/AnimationPlayer.play("Fade_out")

func play_cinematic_animation(anim_name):
	$CinematicAnimationPlayer.play(anim_name)
