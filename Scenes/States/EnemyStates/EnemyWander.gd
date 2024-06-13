extends EnemyState
class_name EnemyWander

@export var wander_animation_name: String = "Walk"
@export var wander_chance = 0.66
@export var random_move_time = 1.5

@onready var random_move_timer = $RandomMoveTimer

var random_direction: Vector2
var move_speed: float
var detection_range: float

var has_follow_state: bool

func enter():
	move_speed = parent.wander_speed
	detection_range = parent.detection_range
	random_move_timer.wait_time = random_move_time
	random_direction = get_random_direction()
	
	has_follow_state = (get_parent() as EnemyStateMachine).has_state("EnemyFollow")
	
func physics_update(_delta):
	handle_movement()
	parent.velocity = move_speed * parent.direction
	
	var collider = parent.move_and_slide()
	if collider:
		random_move_timer.stop()
		decide_what_to_do()

func handle_movement():
	parent.direction = random_direction

	distance_to_player = get_distance_to_player()
	if has_follow_state and distance_to_player <= parent.detection_range:
		transition_to.emit(self, "EnemyFollow")
	else:
		decide_what_to_do()

func handle_animations():
	if parent.direction.x > 0:
		parent.sprite.flip_h = false
	elif parent.direction.x < 0:
		parent.sprite.flip_h = true

	parent.animation_player.play(wander_animation_name)

func get_random_direction():
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _on_timer_timeout():
	if ((get_parent() as EnemyStateMachine).current_state == self):
		parent.direction = Vector2.ZERO
		decide_what_to_do()

func decide_what_to_do():
	if not random_move_timer.is_stopped():
		return
		
	var should_walk = bool(randf() < wander_chance)

	if should_walk:
		transition_to.emit(self, "EnemyWander")
	else:
		transition_to.emit(self, "EnemyIdle")
	
	random_move_timer.start()
