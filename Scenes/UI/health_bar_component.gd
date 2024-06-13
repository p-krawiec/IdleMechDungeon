extends Node2D

@export var health_component: HealthComponent

@onready var sprite = $Sprite2D
@onready var color_rect = $ColorRect


func _ready():
	visible = false

func _process(_delta):
	match_health()
	
func match_health():
	var health = health_component.current_health
	var max_health = health_component.max_health
	var percentage = float(health) / float(max_health)
	
	if health != max_health:
		visible = true
	
	if percentage <= 0:
		
		queue_free()
	else:
		color_rect.scale.x = percentage
