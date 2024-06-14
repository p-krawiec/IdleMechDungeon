extends BossState
class_name BossBigShoot

@export_category("Bulelt")
@export var bullet_damage: int = 1
@export var bullet_spawn_point = Vector2(-4, -13)

@export_category("First Phase")
@export var number_of_bullets_1 = 11
@export var shooting_angle_1 = 120.0
@export var projectile_speed_1 = 150


@export_category("Second Phase")
@export var number_of_bullets_2 = 11
@export var shooting_angle_2 = 120.0
@export var projectile_speed_2 = 150


@export_category("Third Phase")
@export var number_of_bullets_3 = 11
@export var shooting_angle_3 = 120.0
@export var projectile_speed_3 = 150
@export var shooting_time = 3.0

@onready var laser_stream_player = $LaserStreamPlayer
@onready var third_phase_shooting_timer = $ThirdPhaseShootingTimer

var bullet_scene = preload("res://Scenes/Enemies/EnemyBullet/enemy_bullet.tscn")

func enter():
	third_phase_shooting_timer.wait_time = shooting_time
	
	if not parent.body_animation_player.is_connected("animation_finished", on_shoot_animation_finished):
		parent.body_animation_player.connect("animation_finished", on_shoot_animation_finished)
	parent.body_animation_player.play("Shoot_Big_Part1")
	if parent.current_phase == 3:
		third_phase_shooting_timer.start()

func on_shoot_animation_finished(anim_name: StringName):
	match parent.current_phase:
		1:
			if anim_name == "Shoot_Big_Part1":
				shoot_bullets(shooting_angle_1, projectile_speed_1, number_of_bullets_1)
				transition_to.emit(self, "BossIdle")
		2:
			if anim_name == "Shoot_Big_Part1":
				shoot_bullets(shooting_angle_2, projectile_speed_2, number_of_bullets_2)
				parent.body_animation_player.play("Shoot_Big_Part2")
			
			if anim_name == "Shoot_Big_Part2":
				shoot_bullets(shooting_angle_2, projectile_speed_2, number_of_bullets_2)
				transition_to.emit(self, "BossIdle")
		3:
			if anim_name == "Shoot_Big_Part1":
				shoot_bullets(shooting_angle_3, projectile_speed_3, number_of_bullets_3)
				parent.body_animation_player.play("Shoot_Big_Part2")
			
			if anim_name == "Shoot_Big_Part2":
				shoot_bullets(shooting_angle_3, projectile_speed_3, number_of_bullets_3)
				parent.body_animation_player.play("Shoot_Big_Part1")

func shoot_bullets(shooting_angle, projectile_speed, number_of_bullets):
	var bullet_spawn_position: Vector2
	if parent.body_sprite.flip_h == false:
		bullet_spawn_position = parent.position + Vector2(bullet_spawn_point.x, bullet_spawn_point.y)
	else:
		bullet_spawn_position = parent.position + Vector2(-bullet_spawn_point.x, bullet_spawn_point.y)
		
	var direction_to_player = (player.position - bullet_spawn_position).normalized()
	
	var half_angle = shooting_angle / 2.0
	var angle_increment: float
	if number_of_bullets > 1:
		half_angle = shooting_angle / 2.0
		angle_increment = shooting_angle / float(number_of_bullets - 1)
	else:
		half_angle = 0
		angle_increment = 0
	
	for i in range(number_of_bullets):
		var angle = -half_angle + (i * angle_increment)
		var bullet_direction = direction_to_player.rotated(deg_to_rad(angle))
		
		var bullet = bullet_scene.instantiate() as EnemyBullet
		bullet.setup(bullet_damage, projectile_speed, bullet_direction, bullet_spawn_position)
		
		get_tree().get_first_node_in_group("GameMain").add_child(bullet)
		laser_stream_player.play()


func _on_third_phase_shooting_timer_timeout():
	if not (get_parent() as BossStateMachine).is_current_state_equal("BossDie"):
		parent.body_animation_player.stop()
		transition_to.emit(self, "BossIdle")
