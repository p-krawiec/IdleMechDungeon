extends EnemyState
class_name EnemySpawn

@export var color = Color.GREEN

var spawn_timer = 0.0
var previous_whole_frame: int = -1

func enter():
	parent.direction = Vector2.ZERO
	parent.velocity = Vector2.ZERO
	
	parent.harmless = true
	parent.collision_shape.set_deferred("disabled", true)
	
	parent.sprite.scale = Vector2.ZERO
	parent.visible = true
	
func physics_update(delta):
	if spawn_timer < 1:
		spawn_timer += delta
	else:
		transition_to.emit(self, "EnemyIdle")
		return
		
	if floor(spawn_timer * 10) != previous_whole_frame:
		previous_whole_frame = floor(spawn_timer * 10)
		
	if previous_whole_frame % 2 == 0:
		if parent.sprite.modulate == Color.WHITE:
			parent.sprite.modulate = color
		else:
			parent.sprite.modulate = Color.WHITE
		
	parent.sprite.scale = Vector2(spawn_timer, spawn_timer)

func exit():
	parent.sprite.modulate = Color.WHITE
	parent.sprite.scale = Vector2.ONE
	parent.harmless = false
	parent.collision_shape.set_deferred("disabled", false)
