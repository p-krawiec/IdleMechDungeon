extends Control
class_name MainMenu

@export var camera_max_right_position: float
@export var camera_max_left_position: float
@export var camera_max_up_position: float
@export var camera_max_down_position: float
@export var camera_move_speed = 50.0

@onready var camera = $Camera2D

var random_camera_direction: Vector2

func _ready():
	$CanvasLayer/MainMenu/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color.LAWN_GREEN)
	
	random_camera_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	MusicPlayer.fade_in_music(0.5)
	MusicPlayer.change_music_to("LongPreparation")

func _process(delta):
	if camera.position.x <= camera_max_left_position or camera.position.x >= camera_max_right_position or camera.position.y <= camera_max_up_position or camera.position.y >= camera_max_down_position:
		random_camera_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	camera.position += random_camera_direction * delta * camera_move_speed


func _on_settings_button_pressed():
	$CanvasLayer/MainMenu.hide()
	$CanvasLayer/Settings.show()
	$AudioStreamPlayer2D.play()


func _on_inside_settings_button_pressed(button_name):
	if button_name == "Back":
		$CanvasLayer/MainMenu.show()
		$CanvasLayer/Settings.hide()
	$AudioStreamPlayer2D.play()


func _on_quit_button_pressed():
	$AudioStreamPlayer2D.play()
	get_tree().quit()


func _on_scores_button_pressed():
	$AudioStreamPlayer2D.play()
	pass # Replace with function body.


func _on_play_button_pressed():
	$AudioStreamPlayer2D.play()
	get_tree().change_scene_to_file("res://Scenes/Main/game_main.tscn")
