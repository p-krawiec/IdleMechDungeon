extends Node
class_name State

signal transition_to(state: State, new_state_name: String)

func enter():
	pass
	
func exit():
	pass
	
func update(_delta: float):
	pass
	
func physics_update(_delta: float):
	pass

func handle_animations():
	pass

func die():
	pass
