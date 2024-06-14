extends BossState
class_name BossDash

@export_category("Base Info")
@export var dash_line_spawn_position = Vector2(0, 19)


@export_category("First Phase")
@export var dash_speed_modifier_1 = 3.0
@export var dashing_time_1 = 1.5
@export var follow_player_while_dashing_1 = false
@export var dash_charge_time_1 = 0.5

@export_category("Second Phase")
@export var dash_speed_modifier_2 = 2.5
@export var dashing_time_2 = 1.0
@export var follow_player_while_dashing_2 = true
@export var dash_charge_time_2 = 0.5

@export_category("Third Phase")
@export var dash_speed_modifier_3 = 4.0
@export var dashing_time_3 = 1.0
@export var follow_player_while_dashing_3 = true
@export var dash_charge_time_3 = 0.5

@onready var dash_charge_timer = $DashChargeTimer
@onready var dash_duration_timer = $DashDurationTimer

var dash_line_sprite = preload("res://Assets/UI/white_stripe.png")

var dash_direction: Vector2
var is_dash_charging: bool
var dash_line: Sprite2D
var follow_player = false

func enter():
	match parent.current_phase:
		1:
			dash_duration_timer.wait_time = dashing_time_1
			follow_player = follow_player_while_dashing_1
			(parent.body_animation_player as AnimationPlayer).speed_scale = dash_speed_modifier_1 / 2
			(parent.legs_animation_player as AnimationPlayer).speed_scale = dash_speed_modifier_1 / 2
			dash_charge_timer.wait_time = dash_charge_time_1
			move_speed = get_correct_move_speed() * dash_speed_modifier_1
		2:
			dash_duration_timer.wait_time = dashing_time_2
			follow_player = follow_player_while_dashing_2
			(parent.body_animation_player as AnimationPlayer).speed_scale = dash_speed_modifier_2 / 2
			(parent.legs_animation_player as AnimationPlayer).speed_scale = dash_speed_modifier_2 / 2
			dash_charge_timer.wait_time = dash_charge_time_2
			move_speed = get_correct_move_speed() * dash_speed_modifier_2
		3:
			dash_duration_timer.wait_time = dashing_time_3
			follow_player = follow_player_while_dashing_3
			(parent.body_animation_player as AnimationPlayer).speed_scale = dash_speed_modifier_3 / 2
			(parent.legs_animation_player as AnimationPlayer).speed_scale = dash_speed_modifier_3 / 2
			dash_charge_timer.wait_time = dash_charge_time_3
			move_speed = get_correct_move_speed() * dash_speed_modifier_3
	
	
	is_dash_charging = true
	parent.is_following_player = false # stop following player so that dash can charge
	create_dash_line()

func create_dash_line():
	dash_line = Sprite2D.new()
	dash_line.texture = dash_line_sprite
	dash_line.centered = false
	dash_line.offset = Vector2(0, -8)
	dash_line.scale = Vector2(0, 1)
	dash_line.position = dash_line_spawn_position
	
	parent.add_child(dash_line)

func exit():
	parent.body_sprite.scale.y = 1
	parent.outline_sprite.scale.y = 1
	parent.legs_sprite.scale.y = 1
	parent.shadows_sprite.scale.y = 1
	
	(parent.body_animation_player as AnimationPlayer).speed_scale = 1
	(parent.legs_animation_player as AnimationPlayer).speed_scale = 1
	
	move_speed = get_correct_move_speed()
	parent.is_following_player = true
	dash_line.queue_free()

#################################################

func handle_movement(delta):
	if is_dash_charging:
		dash_charge(delta)
	else:
		if not follow_player:
			parent.direction = dash_direction
		else:
			if get_distance_to_player() <= 50:
				follow_player = false
			
			dash_direction = (player.position - parent.position).normalized()
			parent.direction = dash_direction

func physics_update(delta):
	handle_movement(delta)
	
	parent.velocity = move_speed * parent.direction
	var collider = parent.move_and_slide()
	if collider:
		transition_to.emit(self, "BossIdle")

func dash_charge(delta):
	parent.direction = Vector2.ZERO
	parent.body_animation_player.stop()
	
	if dash_charge_timer.is_stopped():
		is_dash_charging = true
		dash_direction = (player.position - parent.position).normalized()
		dash_line.rotation = parent.direction.angle()
		dash_charge_timer.start()
	if is_dash_charging:
		handle_sprite_flip()
		dash_direction = (player.position - parent.position).normalized()
		dash_line.rotation = dash_direction.angle()
		expand_dash_line(delta)

func expand_dash_line(delta):
	dash_line.scale.x += delta * 15 * (1 / dash_charge_timer.wait_time)
	
	parent.body_sprite.scale.y -= delta * 0.3
	parent.outline_sprite.scale.y -= delta * 0.3
	parent.legs_sprite.scale.y -= delta * 0.3
	parent.shadows_sprite.scale.y -= delta * 0.3

##########################################

func handle_animations():
	handle_sprite_flip()
	handle_leg_animations()
	
	if parent.direction != Vector2.ZERO:
		play_walk_animation()
	else:
		parent.body_animation_player.play("Idle")

func play_walk_animation():
	if parent.is_flying:
		parent.body_animation_player.play("Fly")
	else:
		parent.body_animation_player.play("Walk")

func _on_dash_charge_timer_timeout():
	if ((get_parent() as BossStateMachine).current_state == self):
		is_dash_charging = false
		dash_line.scale.x = 0
		parent.body_sprite.scale.y = 1
		parent.outline_sprite.scale.y = 1
		parent.legs_sprite.scale.y = 1
		parent.shadows_sprite.scale.y = 1
		dash_duration_timer.start()
		$AudioStreamPlayer.play()
	

func _on_dash_duration_timer_timeout():
	if ((get_parent() as BossStateMachine).current_state == self):
		transition_to.emit(self, "BossIdle")
