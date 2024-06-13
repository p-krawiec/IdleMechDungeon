extends EnemyState
class_name EnemyFollow

@export var follow_animation_name: String = "Walk"

var move_speed: float

var has_flank_state: bool
var flanking_chance: float

var has_dash_state: bool
var dash_range: float

var has_shoot_state: bool
var shoot_range: float

func enter():
	move_speed = parent.follow_speed
	
	has_flank_state = (get_parent() as EnemyStateMachine).has_state("EnemyFlank")
	if has_flank_state:
		flanking_chance = ((get_parent() as EnemyStateMachine).get_node("EnemyFlank") as EnemyFlank).flanking_chance
		
	has_dash_state = (get_parent() as EnemyStateMachine).has_state("EnemyDash")
	if has_dash_state:
		dash_range = ((get_parent() as EnemyStateMachine).get_node("EnemyDash") as EnemyDash).dash_range
		
	has_shoot_state = (get_parent() as EnemyStateMachine).has_state("EnemyShoot")
	if has_shoot_state:
		shoot_range = ((get_parent() as EnemyStateMachine).get_node("EnemyShoot") as EnemyShoot).shoot_range

func exit():
	parent.direction = Vector2.ZERO
	parent.velocity = Vector2.ZERO

func physics_update(_delta):
	handle_movement()
	parent.velocity = move_speed * parent.direction
	parent.move_and_slide()
	
func handle_movement():
	distance_to_player = get_distance_to_player()
	
	if player and (distance_to_player <= parent.follow_range):
		if has_flank_state and randf() < flanking_chance:
			transition_to.emit(self, "EnemyFlank")
		if has_dash_state and distance_to_player <= dash_range:
			transition_to.emit(self, "EnemyDash")
		if has_shoot_state and distance_to_player <= shoot_range:
			if ((get_parent() as EnemyStateMachine).get_node("EnemyShoot") as EnemyShoot).can_shoot:
				transition_to.emit(self, "EnemyShoot")
		if distance_to_player > 1:
			parent.direction = (player.position - parent.position).normalized()
		else:
			parent.direction = Vector2.ZERO
	else:
		transition_to.emit(self, "EnemyIdle")

func handle_animations():
	if parent.direction.x < 0:
		parent.sprite.flip_h = true
	elif parent.direction.x > 0:
		parent.sprite.flip_h = false
		
	parent.animation_player.play(follow_animation_name)

