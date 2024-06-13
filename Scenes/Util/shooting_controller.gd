extends Area2D
class_name ShootingController

@export var enabled = true

var player: Player
var bullet_scene = preload("res://Scenes/Player/player_bullet.tscn")
var enemies_in_range = []
var can_shoot = true

var closest_enemy = null
var direction_to_closest_enemy = null

func _ready():
	player = get_parent()
	($RangeShape.shape as CircleShape2D).radius = player.shooting_range
	$CooldownTimer.wait_time = 1.0 / player.attack_speed
	
func _process(_delta):
	if not enabled:
		return
	
	calculate_direction_to_closest_enemy()
	
	if not closest_enemy:
		return
	
	if can_shoot and player.current_ammo >= 1:
		var did_crit = randi() % 100 < player.crit_chance
		
		var bullet = bullet_scene.instantiate() as PlayerBullet
		bullet.direction = direction_to_closest_enemy
		if did_crit:
			bullet.attack_damage = player.damage * 2
		else:
			bullet.attack_damage = player.damage
		bullet.speed = player.projectile_speed
		bullet.max_pen = player.penetration
		
		$AudioStreamPlayer.play()
		bullet.position = get_parent().position
		get_tree().get_first_node_in_group("GameMain").add_child(bullet)
		
		can_shoot = false
		player.current_ammo -= 1
		$CooldownTimer.start()
		

func recalculate_shooting_stats():
	($RangeShape.shape as CircleShape2D).radius = player.shooting_range
	$CooldownTimer.wait_time = 1.0 / player.attack_speed

func _on_body_entered(body):
	if (body as Node).is_in_group("Enemy") or (body as Node).is_in_group("Boss"):
		enemies_in_range.append(body)

func _on_body_exited(body):
	if (body as Node).is_in_group("Enemy") or (body as Node).is_in_group("Boss"):
		enemies_in_range.erase(body)

func _on_cooldown_timer_timeout():
	can_shoot = true

func calculate_closest_enemy():
	var min_distance = INF
	closest_enemy = null
	
	for enemy in enemies_in_range:
		if enemy is BaseEnemy and enemy.harmless:
			continue
		
		var distance = position.distance_squared_to(enemy.position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
func calculate_direction_to_closest_enemy():
	calculate_closest_enemy()
	if closest_enemy:
		direction_to_closest_enemy = get_parent().position.direction_to(closest_enemy.position)
	else:
		direction_to_closest_enemy = Vector2.ZERO
