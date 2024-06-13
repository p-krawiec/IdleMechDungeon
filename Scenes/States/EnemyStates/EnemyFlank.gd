extends EnemyState
class_name EnemyFlank

@export var flanking_chance = 0.1
@export var flanking_time = 2.0

@onready var flank_timer = $FlankTimer

var follow_animation_name: String
var move_speed: float
var flank_direction: float

func enter():
	follow_animation_name = ((get_parent() as EnemyStateMachine).get_node("EnemyFollow") as EnemyFollow).follow_animation_name
	move_speed = parent.follow_speed
	flank_timer.wait_time = flanking_time
	start_flanking()

func handle_animations():
	if parent.direction.x > 0:
		parent.sprite.flip_h = false
	elif parent.direction.x < 0:
		parent.sprite.flip_h = true
		
	parent.animation_player.play(follow_animation_name)
	
func physics_update(_delta):
	handle_movement()
	parent.velocity = move_speed * parent.direction
	parent.move_and_slide()

func handle_movement():
	distance_to_player = get_distance_to_player()
	
	if distance_to_player > 1:
		parent.direction = (player.position - parent.position).normalized()
		var flanking_direction = parent.direction.rotated(PI/2 * flank_direction).normalized()
		parent.direction = (parent.direction + flanking_direction).normalized()
	else:
		parent.direction = Vector2.ZERO

func start_flanking():
	if randf() < 0.5:
		flank_direction = 1
	else:
		flank_direction = 1
	
	flank_timer.start()

func _on_flank_timer_timeout():
	if ((get_parent() as EnemyStateMachine).current_state == self):
		transition_to.emit(self, "EnemyFollow")
