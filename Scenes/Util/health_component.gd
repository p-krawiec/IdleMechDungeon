extends Node2D
class_name HealthComponent

signal entity_died

@export var max_health: int = 1
@export var max_golden_health: int = 0

@onready var hurt_timer = $HurtTimer

var current_health: int
var current_golden_health: int
var parent: Node2D

var damage_text_scene = preload("res://Scenes/UI/damage_text.tscn")

func _ready():
	parent = get_parent()
	current_health = max_health
	current_golden_health = max_golden_health
	

func take_damage(attack_damage: int):	
	if current_golden_health > 0:
		if current_golden_health >= attack_damage:
			current_golden_health -= attack_damage
		else:
			var remaining_damage = attack_damage - current_golden_health
			current_golden_health = 0
			current_health -= remaining_damage
	else:
		current_health -= attack_damage
	
#	display_damage_text(attack_damage)
	
	hurt_flash()
	$HurtStreamPlayer2D.play()
	
	if current_health <= 0:
		if parent.has_method("on_death"):
			parent.on_death()
		else:
			parent.queue_free()
		
func hurt_flash():
	parent.modulate = Color.RED
	if parent is Player:
		(get_tree().get_first_node_in_group("HUD") as HUD).get_node("HurtPanel").visible = true
	hurt_timer.start()

func _on_hurt_timer_timeout():
	parent.modulate = Color.WHITE
	if parent is Player:
		(get_tree().get_first_node_in_group("HUD") as HUD).get_node("HurtPanel").visible = false
	
func display_damage_text(attack_damage: int):
	var text = damage_text_scene.instantiate()
	text.text = str(attack_damage)
	text.position = parent.position
	parent.get_parent().add_child(text)

func heal():
	current_health = max_health
	current_golden_health = max_golden_health
	
func regenerate_golden_health():
	var did_regenerate = false
	if current_golden_health != max_golden_health:
		current_golden_health = max_golden_health
		did_regenerate = true
	return did_regenerate

func increase_health():
	max_health += 2
	current_health += 2
	if current_health > max_health:
		current_health = max_health

func increase_golden_health():
	max_golden_health += 1
	current_golden_health += 1
	if current_golden_health > max_golden_health:
		current_golden_health = max_golden_health
