extends BossState
class_name BossDie

func enter():
	Util.play_time_stopped = true
	MusicPlayer.stop()
	player.disable_hitboxes()
#	parent.legs_sprite.visible = false
#	parent.shadows_sprite = false

	parent.body_animation_player.play("Death")
	if not parent.body_animation_player.is_connected("animation_finished", on_death_animation_finished):
		parent.body_animation_player.connect("animation_finished", on_death_animation_finished)

func on_death_animation_finished(_anim_name: StringName):
	(get_tree().get_first_node_in_group("GameOverScreen") as GameOverScreen).display_screen_game_won()
	parent.queue_free()
