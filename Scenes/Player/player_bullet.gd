extends CharacterBody2D
class_name PlayerBullet

@export var attack_damage: int = 1
@export var speed = 300

var direction = Vector2.ZERO
var current_pen = 0
var max_pen = 0
var about_to_be_destroyed = false

func _ready():
	rotation = direction.angle()

func _physics_process(_delta):
	if about_to_be_destroyed:
		destroy_if_not_emiting()
		return
	
	velocity = direction * speed
	var collider = move_and_slide()
	if collider:
		set_to_destroy()

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		area.damage(attack_damage)
		current_pen += 1
		
	if current_pen > max_pen:
		set_to_destroy()

func set_to_destroy():
	$OnHitParticles.emitting = true
	about_to_be_destroyed = true
	$AnimatedSprite2D.visible = false
	set_collision_mask_value(1, false)
	$HitboxComponent.set_collision_layer_value(11, false)
	$HitboxComponent.set_collision_mask_value(10, false)

func destroy_if_not_emiting():
	if not $OnHitParticles.emitting:
		queue_free()
