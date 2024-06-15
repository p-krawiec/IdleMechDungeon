extends Control

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	$AnimationPlayer.play("RESET")
	hide()
	
	$Main.hide()
	$Settings.hide()

func _physics_process(_delta):
	testEsc()
	
func resume():
	$AudioStreamPlayer2D.play()
	get_tree().paused = false
	hide()
#	(get_tree().get_first_node_in_group("MusicPlayer") as AudioStreamPlayer2D)
	
	$Main.hide()
	$Settings.hide()
	player.allow_input = true
	
func pause():
	$AudioStreamPlayer2D.play()
	get_tree().paused = true
	$AnimationPlayer.play("Blur")
	show()
	
	$Main.show()
	$Settings.hide()
	player.allow_input = false
	
func testEsc():
	if Input.is_action_just_pressed("pause"):
		if $Settings.visible:
			$Main.show()
			$Settings.hide()
		else:
			if get_tree().paused:
				resume()
			else:
				pause()

func _on_resume_button_pressed():
	resume()


func _on_settings_button_pressed():
	$Main.hide()
	$Settings.show()
	$AudioStreamPlayer2D.play()

func _on_menu_button_pressed():
	get_tree().paused = false
	$AudioStreamPlayer2D.play()
	get_tree().change_scene_to_file("res://Scenes/Main/main_menu.tscn")


func _on_inside_settings_button_pressed(button_name):
	if button_name == "Back":
		$Main.show()
		$Settings.hide()
	$AudioStreamPlayer2D.play()
