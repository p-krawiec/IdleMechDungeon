extends EnemyState
class_name EnemyDash

@export var dash_range = 100.0
@export var dash_speed_modifier = 3.0
@export var dash_charge_time = 0.5
@export var dashing_time = 0.75
@export var dash_line_spawn_position = Vector2(0, 10)
@export var track_player_while_charging = true

@onready var dash_charge_timer = $DashChargeTimer
@onready var dash_timer = $DashTimer

var dash_line_sprite = preload("res://Assets/UI/white_stripe.png")

var dash_direction: Vector2
var move_speed: float
var is_dash_charging: bool
var follow_animation_name: String
var dash_line: Sprite2D

func enter():
	dash_charge_timer.wait_time = dash_charge_time
	dash_timer.wait_time = dashing_time
	is_dash_charging = true
	move_speed = parent.follow_speed * dash_speed_modifier
	follow_animation_name = ((get_parent() as EnemyStateMachine).get_node("EnemyFollow") as EnemyFollow).follow_animation_name
	create_dash_line()

func create_dash_line():
	dash_line = Sprite2D.new()
	dash_line.texture = dash_line_sprite
	dash_line.centered = false
	dash_line.offset = Vector2(0, -8)
	dash_line.scale = Vector2(0, 0.75)
	dash_line.position = dash_line_spawn_position
	
	parent.add_child(dash_line)

func handle_animations():
	if parent.direction.x < 0:
		parent.sprite.flip_h = true
	elif parent.direction.x > 0:
		parent.sprite.flip_h = false
		
	parent.animation_player.play(follow_animation_name)
	
func handle_movement(delta):
	if is_dash_charging:
		dash_charge(delta)
	else:
		parent.direction = dash_direction

func physics_update(delta):
	handle_movement(delta)
	parent.velocity = move_speed * parent.direction
	var collider = parent.move_and_slide()
	if collider:
		transition_to.emit(self, "EnemyFollow")

func dash_charge(delta):
	var dash_line_rotation = parent.direction.angle()
	parent.direction = Vector2.ZERO
	parent.animation_player.stop()
	
	if dash_charge_timer.is_stopped():
		is_dash_charging = true
		dash_line.rotation = dash_line_rotation
		dash_direction = (player.position - parent.position).normalized()
		dash_charge_timer.start()
	if is_dash_charging:
		if track_player_while_charging:
			dash_direction = (player.position - parent.position).normalized()
			dash_line.rotation = dash_direction.angle()
		expand_dash_line(delta)

func expand_dash_line(delta):
	dash_line.scale.x += delta * 10
	parent.sprite.scale.y -= delta * 0.3
	

func exit():
	parent.set_collision_mask_value(10, true) # collisions with other enemies
	parent.sprite.scale.y = 1
	dash_line.queue_free()

func _on_dash_charge_timer_timeout():
	if ((get_parent() as EnemyStateMachine).current_state == self):
		is_dash_charging = false
		dash_line.scale.x = 0
		parent.sprite.scale.y = 1
		dash_timer.start()
		parent.set_collision_mask_value(10, false) # collisions with other enemies)

func _on_dash_timer_timeout():
	if ((get_parent() as EnemyStateMachine).current_state == self):
		transition_to.emit(self, "EnemyFollow")
