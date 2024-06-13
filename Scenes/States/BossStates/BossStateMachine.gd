extends StateMachine
class_name BossStateMachine

var parent: Boss

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	parent = get_parent()

	for child in get_children():
		if child is BossState:
			var state_name = child.name.to_lower()
			states[state_name] = child
			child.transition_to.connect(on_state_transition_to)

			child.player = player
			child.parent = parent
		else:
			push_error("State machine contains child which is not 'BossState'")

	if initial_state:
		current_state = initial_state
		current_state.enter()
	else:
		push_error("State machine does not have initial state")

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
		(current_state as BossState).process_follow()
