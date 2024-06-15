extends PanelContainer

signal button_pressed(button_name: String)

func _ready():
	get_settings()

func get_settings():
	$VBoxContainer/MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$VBoxContainer/SoundsSlider.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	$VBoxContainer/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$VBoxContainer/TutorialCheckButton.button_pressed = Util.show_tutorial
	

func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_sounds_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_restore_to_defaults_button_pressed():
	AudioServer.set_bus_volume_db(0, linear_to_db(1))
	AudioServer.set_bus_volume_db(1, linear_to_db(1))
	AudioServer.set_bus_volume_db(2, linear_to_db(1))
	$VBoxContainer/TutorialCheckButton.button_pressed = true
	get_settings()
	button_pressed.emit("Restore")

func _on_back_button_pressed():
	button_pressed.emit("Back")

func _on_tutorial_check_button_toggled(_button_pressed):
	Util.show_tutorial = _button_pressed
	
