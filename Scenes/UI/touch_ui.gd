extends Control
class_name TouchUI

@onready var joystick = $Joystick
@onready var outline = $Joystick/Outline
@onready var knob = $Joystick/Outline/Knob

@onready var dash_control = $DashControl
@onready var use_control = $UseControl
@onready var pause_control = $PauseControl

var joystick_max_range: float = 150.0
var is_button_pressed = false
var is_joystick_visible = false
var direction: Vector2
var player: Player

func _ready():
	outline.scale = Vector2(0.75, 0.75)
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta):
	joystick.shape.size.x = get_viewport_rect().size.x / 2
	joystick.shape.size.y = get_viewport_rect().size.y
	joystick.position = joystick.shape.size / 2
	
	if not player.allow_input:
		hide()
	else:
		show()
	

func _input(event):
	if event is InputEventScreenTouch and is_button_pressed and not is_joystick_visible:
		outline.visible = true
		outline.position = event.position - joystick.position
		knob.visible = true
		knob.position = Vector2.ZERO
		is_joystick_visible = true
		
	if event is InputEventScreenDrag and is_button_pressed and is_joystick_visible:
		knob.position = (event.position - joystick.position - outline.position)
		knob.position = knob.position.limit_length(joystick_max_range)
		direction = knob.position.normalized()

func _on_joystick_pressed():
	is_button_pressed = true


func _on_joystick_released():
	is_button_pressed = false
	outline.visible = false
	knob.visible = false
	direction = Vector2.ZERO
	is_joystick_visible = false

func _on_dash_button_pressed():
	dash_control.modulate = Color(1, 1, 1, 0.50)
	Input.action_press("dash")

func _on_dash_button_released():
	dash_control.modulate = Color(1, 1, 1, 0.75)

func _on_use_button_pressed():
	use_control.modulate = Color(1, 1, 1, 0.50)
	Input.action_press("use")

func _on_use_button_released():
	use_control.modulate = Color(1, 1, 1, 0.75)

func _on_pause_button_pressed():
	Input.action_press("pause")
