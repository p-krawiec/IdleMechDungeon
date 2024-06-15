extends EnemyState
class_name EnemyIdle

@export var idle_animation_name: String = "Idle"

var has_wander_state: bool
var wander_chance: float
var random_move_timer: Timer

var has_follow_state: bool

func enter():
	parent.direction = Vector2.ZERO
	parent.velocity = Vector2.ZERO
	
	has_wander_state = (get_parent() as EnemyStateMachine).has_state("EnemyWander")
	if has_wander_state:
		wander_chance = ((get_parent() as EnemyStateMachine).get_node("EnemyWander") as EnemyWander).wander_chance
		random_move_timer = ((get_parent() as EnemyStateMachine).get_node("EnemyWander") as EnemyWander).random_move_timer
		
	has_follow_state = (get_parent() as EnemyStateMachine).has_state("EnemyFollow")
	
func update(_delta):
	if not player or player.is_dead:
		decide_what_to_do()
		return
	
	distance_to_player = get_distance_to_player()
	if has_follow_state and distance_to_player <= parent.detection_range:
		transition_to.emit(self, "EnemyFollow")
	else:
		decide_what_to_do()

func handle_animations():
	parent.animation_player.play("Idle")

func decide_what_to_do():
	if not random_move_timer.is_stopped():
		return
		
	var should_walk = bool(randf() < wander_chance)

	if should_walk:
		transition_to.emit(self, "EnemyWander")
	else:
		transition_to.emit(self, "EnemyIdle")
	
	random_move_timer.start()
