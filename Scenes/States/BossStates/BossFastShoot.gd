extends BossState
class_name BossFastShoot

@export_category("Bulelt")
@export var bullet_damage: int = 1
@export var bullet_spawn_point = Vector2(26, 2)

@export_category("First Phase")
@export var projectile_speed_1 = 200
@export var total_shooting_time_1 = 4.0
@export var shooting_speed_multiplier_1 = 1.0

@export_category("Second Phase")
@export var projectile_speed_2 = 300
@export var total_shooting_time_2 = 6.0
@export var shooting_speed_multiplier_2 = 2.0

@export_category("Third Phase")
@export var projectile_speed_3 = 400
@export var total_shooting_time_3 = 10.0
@export var shooting_speed_multiplier_3 = 3.0

@onready var total_shooting_timer = $TotalShootingTimer
@onready var laser_stream_player = $LaserStreamPlayer

var bullet_scene = preload("res://Scenes/Enemies/EnemyBullet/enemy_bullet.tscn")

func enter():
	match parent.current_phase:
		1:
			total_shooting_timer.wait_time = total_shooting_time_1
			(parent.body_animation_player as AnimationPlayer).speed_scale = shooting_speed_multiplier_1
		2:
			total_shooting_timer.wait_time = total_shooting_time_2
			(parent.body_animation_player as AnimationPlayer).speed_scale = shooting_speed_multiplier_2
		3:
			total_shooting_timer.wait_time = total_shooting_time_3
			(parent.body_animation_player as AnimationPlayer).speed_scale = shooting_speed_multiplier_3
	
	if not parent.body_animation_player.is_connected("animation_finished", on_shoot_animation_finished):
		parent.body_animation_player.connect("animation_finished", on_shoot_animation_finished)
	parent.body_animation_player.play("Shoot_Fast_Part1")
	total_shooting_timer.start()
	
func exit():
	(parent.body_animation_player as AnimationPlayer).speed_scale = 1
	
func on_shoot_animation_finished(anim_name: StringName):
	if anim_name == "Shoot_Fast_Part1":
		shoot_bullet()
		parent.body_animation_player.play("Shoot_Fast_Part2")
		
	if anim_name == "Shoot_Fast_Part2":
		shoot_bullet()
		parent.body_animation_player.play("Shoot_Fast_Part1")

func shoot_bullet():
	var bullet_spawn_position: Vector2
	if parent.body_sprite.flip_h == false:
		bullet_spawn_position = parent.position + Vector2(bullet_spawn_point.x, bullet_spawn_point.y)
	else:
		bullet_spawn_position = parent.position + Vector2(-bullet_spawn_point.x, bullet_spawn_point.y)
		
	var direction_to_player = (player.position - bullet_spawn_position).normalized()
	var bullet = bullet_scene.instantiate() as EnemyBullet
	
	match parent.current_phase:
		1:
			bullet.setup(bullet_damage, projectile_speed_1, direction_to_player, bullet_spawn_position)
		2:
			bullet.setup(bullet_damage, projectile_speed_2, direction_to_player, bullet_spawn_position)
		3:
			bullet.setup(bullet_damage, projectile_speed_3, direction_to_player, bullet_spawn_position)
	
	get_tree().get_first_node_in_group("GameMain").add_child(bullet)
	laser_stream_player.play()

func _on_total_shooting_timer_timeout():
	if not (get_parent() as BossStateMachine).is_current_state_equal("BossDie"):
		transition_to.emit(self, "BossIdle")
