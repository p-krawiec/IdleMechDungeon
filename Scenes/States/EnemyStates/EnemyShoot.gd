extends EnemyState
class_name EnemyShoot

@export_category("Bullets")
@export var bullet_damage: int = 1
@export var projectile_speed = 100.0
@export_enum("1", "3") var number_of_bullets = 0
@export var bullet_spawn_point = Vector2(1, 5)

@export_category("Shooting")
@export var shoot_animation_name = "Shoot"
@export var shoot_range = 100.0
@export var shoot_cooldown = 2.0

@onready var shoot_cooldown_timer = $ShootCooldownTimer
@onready var laser_stream_player = $LaserStreamPlayer

var bullet_scene = preload("res://Scenes/Enemies/EnemyBullet/enemy_bullet.tscn")

var can_shoot = true

func enter():
	shoot_cooldown_timer.wait_time = shoot_cooldown
	parent.direction = Vector2.ZERO
	if not parent.animation_player.is_connected("animation_finished", on_shoot_animation_finished):
		parent.animation_player.connect("animation_finished", on_shoot_animation_finished)
	parent.animation_player.play(shoot_animation_name)

func on_shoot_animation_finished(anim_name: StringName):
	if anim_name == shoot_animation_name:
		shoot_bullets()

func handle_animations():
	var direction_to_player = (player.position - parent.position).normalized()
	if direction_to_player.x > 0:
		parent.sprite.flip_h = false
	elif direction_to_player.x < 0:
		parent.sprite.flip_h = true

func shoot_bullets():
	var bullet_spawn_position = parent.position + bullet_spawn_point
	
	if number_of_bullets == 0:
		var bullet = bullet_scene.instantiate() as EnemyBullet
		var direction_to_player = (player.position - bullet_spawn_position).normalized()
		bullet.setup(bullet_damage, projectile_speed, direction_to_player, bullet_spawn_position)
		get_tree().get_first_node_in_group("GameMain").add_child(bullet)
		
	elif number_of_bullets == 1:
		var direction_to_player = (player.position - bullet_spawn_position).normalized()
		var random_angle = randf_range(12, 18)

		var bullet1 = bullet_scene.instantiate() as EnemyBullet
		var bullet2 = bullet_scene.instantiate() as EnemyBullet
		var bullet3 = bullet_scene.instantiate() as EnemyBullet

		bullet1.setup(bullet_damage, projectile_speed, direction_to_player.rotated(deg_to_rad(-random_angle)), bullet_spawn_position)
		bullet2.setup(bullet_damage, projectile_speed, direction_to_player, bullet_spawn_position)
		bullet3.setup(bullet_damage, projectile_speed, direction_to_player.rotated(deg_to_rad(random_angle)), bullet_spawn_position)

		get_tree().get_first_node_in_group("GameMain").add_child(bullet1)
		get_tree().get_first_node_in_group("GameMain").add_child(bullet2)
		get_tree().get_first_node_in_group("GameMain").add_child(bullet3)
	
	
	laser_stream_player.play()
	can_shoot = false
	shoot_cooldown_timer.start()
	transition_to.emit(self, "EnemyFollow")

func _on_shoot_cooldown_timer_timeout():
	can_shoot = true
