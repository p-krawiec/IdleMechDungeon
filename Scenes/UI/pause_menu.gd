extends Control

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	$AnimationPlayer.play("RESET")
	hide()
	
	$Main.hide()
	$Settings.hide()
	set_sliders()

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
	get_tree().reload_current_scene()
	resume()


func _on_back_button_pressed():
	$Main.show()
	$Settings.hide()
	$AudioStreamPlayer2D.play()

func set_sliders():
	if AudioServer.is_bus_mute(0):
		$Settings/VBoxContainer/MasterSlider.value = -20
	else:
		$Settings/VBoxContainer/MasterSlider.value = AudioServer.get_bus_volume_db(0)
		
	if AudioServer.is_bus_mute(2):
		$Settings/VBoxContainer/SoundsSlider.value = -20
	else:
		$Settings/VBoxContainer/SoundsSlider.value = AudioServer.get_bus_volume_db(2)
		
	if AudioServer.is_bus_mute(1):
		$Settings/VBoxContainer/MusicSlider.value = -20
	else:
		$Settings/VBoxContainer/MusicSlider.value = AudioServer.get_bus_volume_db(1)

func _on_master_slider_value_changed(value):
	if value == -20:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, value)


func _on_sounds_slider_value_changed(value):
	if value == -20:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
		AudioServer.set_bus_volume_db(2, value)


func _on_music_slider_value_changed(value):
	if value == -20:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_volume_db(1, value)


func _on_restore_to_defaults_button_pressed():
	AudioServer.set_bus_volume_db(0, 0)
	AudioServer.set_bus_volume_db(1, 0)
	AudioServer.set_bus_volume_db(2, 0)
	set_sliders()
