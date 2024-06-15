extends Control
class_name GameOverScreen

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	$AnimationPlayer.play("RESET")
	hide()


func display_screen_game_over():
	$VBoxContainer/TimeLabel.hide()
	$VBoxContainer/GameOverLabel.text = "Game Over"
	$VBoxContainer/GameOverLabel.add_theme_color_override("font_color", Color.FIREBRICK)
	$VBoxContainer/TryAgainLabel.text = "Try Again?"
	$AnimationPlayer.play("Blur")
	show()
	player.allow_input = false
	
func display_screen_game_won():
	$VBoxContainer/TimeLabel.show()
	$VBoxContainer/GameOverLabel.text = "Boss Defeated"
	$VBoxContainer/GameOverLabel.add_theme_color_override("font_color", Color.WEB_GREEN)
	$VBoxContainer/TryAgainLabel.text = "Game won, congratulations!"
	$VBoxContainer/TimeLabel.text = "Time: " + Util.get_formatted_time()
	$AnimationPlayer.play("Blur")
	show()
	player.allow_input = false
	MusicPlayer.fade_in_music(1)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_main_menu_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
