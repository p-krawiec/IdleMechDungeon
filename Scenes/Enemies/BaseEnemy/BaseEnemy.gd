extends CharacterBody2D
class_name BaseEnemy

@export_category("Base Info")
@export var melee_attack_damage: int = 1
@export var harmless = true

@export_category("Base Movement Info")
@export var follow_speed = 50.0
@export var detection_range = 100.0
@export var follow_range = 150.0
@export var wander_speed = 50.0

@export_category("Nodes")
@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer
@export var collision_shape: CollisionShape2D
@export var hitbox_component: HitboxComponent
@export var state_machine: EnemyStateMachine

var notifier_scene = preload("res://Scenes/Util/on_screen_notifier_component.tscn") 

var direction = Vector2.ZERO

func _ready():
	sprite.flip_h = (randi() % 2)
	
	if hitbox_component:
		hitbox_component.connect("area_entered", _on_hitbox_component_area_entered)
		
		var notifier = notifier_scene.instantiate()
		notifier.color = Color.FIREBRICK
		add_child(notifier)

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent and (not harmless):
		area.damage(melee_attack_damage)

func on_death():
	state_machine.die()
