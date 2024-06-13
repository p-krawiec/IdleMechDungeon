extends EnemyState
class_name EnemyDie

@export var death_animation_name: String = "Death"

@onready var explosion_sound_player = $ExplosionStreamPlayer

func enter():
	parent.harmless = true
	parent.collision_shape.set_deferred("disabled", true)
	explosion_sound_player.play()
	parent.animation_player.play(death_animation_name)
	if not parent.animation_player.is_connected("animation_finished", on_death_animation_finished):
		parent.animation_player.connect("animation_finished", on_death_animation_finished)

func on_death_animation_finished(_anim_name: StringName):
	parent.queue_free()
