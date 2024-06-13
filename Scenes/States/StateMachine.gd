extends Node
class_name StateMachine

@export var initial_state: State

var states: Dictionary = {}
var current_state: State
var player: Player

func _process(delta):
	if current_state:
		current_state.update(delta)
		current_state.handle_animations()

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_state_transition_to(state: State, new_state_name: String):
	new_state_name = new_state_name.to_lower()
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name) as State
	if not new_state:
		return
		
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()

func has_state(state_name: String) -> bool:
	return states.has(state_name.to_lower())

func die():
	if current_state:
		current_state.die()
