extends CharacterBody2D
class_name EnemyBullet

@export var attack_damage: int = 1
@export var speed = 100

var direction = Vector2.ZERO
var about_to_be_destroyed = false

func setup(_attack_damage: int, _speed: int, _direction: Vector2, _spawn_point: Vector2) -> void:
	attack_damage = _attack_damage
	speed = _speed
	direction = _direction
	position = _spawn_point

func _ready():
	$AnimatedSprite2D.play("round")
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
		
	set_to_destroy()

func set_to_destroy():
	$OnHitParticles.emitting = true
	about_to_be_destroyed = true
	$AnimatedSprite2D.visible = false
	set_collision_mask_value(1, false)
	$HitboxComponent.set_collision_layer_value(12, false)
	$HitboxComponent.set_collision_mask_value(9, false)

func destroy_if_not_emiting():
	if not $OnHitParticles.emitting:
		queue_free()
