extends CharacterBody2D
class_name Player

@export_category("Base Info")
@export var allow_input = true
@export var touch_ui: TouchUI
@export var default_max_health = 6
@export var default_golden_health = 0
@export var luck = 0.0

@export_category("Movement Info")
@export var move_speed = 100.0
@export var dash_cooldown = 1.0
@export var dash_speed_bonus = 1.5

@export_category("Shooting Info")
@export var max_ammo = 3
@export var shooting_range = 50.0
@export var attack_speed = 1.5
@export var damage = 1
@export var projectile_speed = 300.0
@export var crit_chance = 0.0
@export var penetration = 0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var health_component = $HealthComponent
@onready var shooting_controller = $ShootingController
@onready var hitbox_component = $HitboxComponent
@onready var dash_bar = $DashBar
@onready var after_dash_shoot_cooldown_timer = $AfterDashShootCooldownTimer


var dust_particles_scene = preload("res://Particles/dust_particles.tscn")


var current_ammo = 3
var direction = Vector2.ZERO
var current_state = Util.PlayerState.IDLE
var dash_boost = 1
var dash_timer = 0.0

func handle_keyboard_input():
	if allow_input:
		direction = Vector2(
				Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left"),
				Input.get_action_raw_strength("down") - Input.get_action_raw_strength("up")
		).normalized()
		if Input.is_action_just_pressed("dash") and is_dash_available():
#			var dust_particles = dust_particles_scene.instantiate()
#			dust_particles.position = Vector2(position.x, position.y + 8)
#			get_tree().get_first_node_in_group("GameMain").add_child(dust_particles)
			
			change_state_to(Util.PlayerState.DASH)

func handle_joystick_input():
	if not touch_ui:
		return
	
	if allow_input and touch_ui.is_joystick_visible:
		direction = (touch_ui as TouchUI).direction

func _physics_process(delta):
	handle_keyboard_input()
	handle_joystick_input()
	
	if dash_timer <= 0:
		dash_timer = 0
	else:
		dash_timer -= delta
	
	handle_dash_bar()
	
	match current_state:
		Util.PlayerState.IDLE:
			animation_player.speed_scale = 1
			animation_player.play("Idle")
			if direction != Vector2.ZERO:
				change_state_to(Util.PlayerState.WALK)
			
		Util.PlayerState.WALK:
			if direction.x < 0:
				sprite.flip_h = true
			elif direction.x > 0:
				sprite.flip_h = false
				
			animation_player.play("Walk")
			animation_player.speed_scale = move_speed / 100
			
			if direction == Vector2.ZERO:
				change_state_to(Util.PlayerState.IDLE)
			
		Util.PlayerState.DIE:
			animation_player.speed_scale = 1
			animation_player.play("Death")
			
		Util.PlayerState.DASH:
			dash_boost = dash_speed_bonus
			shooting_controller.enabled = false
			hitbox_component.set_collision_layer_value(9, false)
			animation_player.speed_scale = 1
			if sprite.flip_h:
				animation_player.play("Reload_Dash_Left")
			else:
				animation_player.play("Reload_Dash_Right")
	
	velocity = direction * move_speed * dash_boost
	move_and_slide()

func is_dash_available() -> bool:
	return dash_timer == 0

func on_dash_end():
	dash_boost = 1
	dash_timer = dash_cooldown
	hitbox_component.set_collision_layer_value(9, true)
	current_ammo = max_ammo
	
	after_dash_shoot_cooldown_timer.start()
	change_state_to(Util.PlayerState.IDLE)

func change_state_to(new_state: Util.PlayerState):
	current_state = new_state

func on_death():
	allow_input = false
	direction = Vector2.ZERO
	top_level = true
	change_state_to(Util.PlayerState.DIE)
	
func finish_dying():
	get_tree().reload_current_scene()

func handle_dash_bar():
	if dash_timer == 0:
		dash_bar.visible = false
		return
	
	var dash_rect = dash_bar.get_child(0)
	dash_bar.visible = true
	dash_rect.scale.x = -(dash_timer / dash_cooldown)
	
func _on_after_dash_shoot_cooldown_timer_timeout():
	shooting_controller.enabled = true


# UPGRADES

func play_upgrade_sound(sound):
	var heal_sound = load("res://Assets/Sounds/" + sound + ".wav")
	$UpgradeStreamPlayer2D.stream = heal_sound
	$UpgradeStreamPlayer2D.play()
	
func emit_upgrade_particles(particle, color):
	$UpgradeParticleEffect.texture = load("res://Assets/UI/particles/" + particle + ".png")
	$UpgradeParticleEffect.color = color
	$UpgradeParticleEffect.emitting = true

func heal():
	play_upgrade_sound("heal")
	emit_upgrade_particles("heal", Color.RED)
	(health_component as HealthComponent).heal()

func increase_health():
	play_upgrade_sound("heal")
	emit_upgrade_particles("heart", Color.PALE_VIOLET_RED)
	(health_component as HealthComponent).increase_health()
	
func increase_golden_health():
	play_upgrade_sound("heal")
	emit_upgrade_particles("heart", Color.GOLD)
	(health_component as HealthComponent).increase_golden_health()
	
func regenerate_golden_health():
	if (health_component as HealthComponent).regenerate_golden_health():
		emit_upgrade_particles("heal", Color.GOLD)
		play_upgrade_sound("heal")
	
func increase_ammo():
	play_upgrade_sound("powerup")
	emit_upgrade_particles("arrow", Color.DEEP_SKY_BLUE)
	max_ammo += 1
	current_ammo = max_ammo
	
func increase_luck(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("arrow", Color.DEEP_SKY_BLUE)
	luck += value

func increase_movement_speed(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("general", Color.WEB_GREEN)
	move_speed *= (1.0 + (float(value) / 100.0))

func decrease_dash_cooldown(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("arrow", Color.DEEP_SKY_BLUE)
	dash_cooldown *= 1.0 - (float(value) / 100.0)

func increase_dash_boost(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("general", Color.LIGHT_GREEN)
	dash_speed_bonus *= (1.0 + (float(value) / 100.0))

func increase_pen():
	play_upgrade_sound("powerup")
	emit_upgrade_particles("arrow", Color.MEDIUM_VIOLET_RED)
	penetration += 1
	
func increase_projectile_speed(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("general", Color.WEB_GREEN)
	projectile_speed *= (1.0 + (float(value) / 100.0))
	
func increase_crit_chance(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("arrow", Color.DARK_RED)
	crit_chance += value
	
func increase_attack_range(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("arrow", Color.BLUE_VIOLET)
	shooting_range *= (1.0 + (float(value) / 100.0))
	(shooting_controller as ShootingController).recalculate_shooting_stats()

func increase_attack_speed(value):
	play_upgrade_sound("powerup")
	emit_upgrade_particles("general", Color.LIGHT_GREEN)
	attack_speed *= (1.0 + (float(value) / 100.0))
	(shooting_controller as ShootingController).recalculate_shooting_stats()

func disable_hitboxes():
	hitbox_component.set_collision_layer_value(9, false)
	hitbox_component.set_collision_mask_value(4, false)
	hitbox_component.set_collision_mask_value(10, false)
	hitbox_component.set_collision_mask_value(12, false)
