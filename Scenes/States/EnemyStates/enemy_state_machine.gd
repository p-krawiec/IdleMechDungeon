extends StateMachine
class_name EnemyStateMachine

var parent: BaseEnemy

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	parent = get_parent()

	for child in get_children():
		if child is EnemyState:
			var state_name = child.name.to_lower()
			states[state_name] = child
			child.transition_to.connect(on_state_transition_to)

			child.player = player
			child.parent = parent
		else:
			push_error("State machine contains child which is not 'EnemyState'")

	if initial_state:
		current_state = initial_state
		current_state.enter()
	else:
		push_error("State machine does not have initial state")
