extends State
class_name BossState

var parent: Boss
var player: Player
var move_speed: float

var distance_to_player: float

func die():
	parent.make_passive()
	transition_to.emit(self, "BossDie")
	
func get_distance_to_player():
	return parent.position.distance_to(player.position)

func process_follow():
	if not parent.is_following_player:
		return
		
	handle_leg_animations()
	handle_sprite_flip()
	
	move_speed = get_correct_move_speed()

	distance_to_player = get_distance_to_player()
	if distance_to_player > 1:
		parent.direction = (player.position - parent.position).normalized()
	else:
		parent.direction = Vector2.ZERO
		
	parent.velocity = move_speed * parent.direction
	parent.move_and_slide()

func get_correct_move_speed():
	if parent.is_flying:
		return parent.fly_speed
	else:
		return parent.walk_speed

func handle_sprite_flip():
	if parent.direction.x > 0:
		parent.outline_sprite.flip_h = false
		parent.legs_sprite.flip_h = false
		parent.shadows_sprite.flip_h = false
		parent.body_sprite.flip_h = false

	elif parent.direction.x < 0:
		parent.outline_sprite.flip_h = true
		parent.legs_sprite.flip_h = true
		parent.shadows_sprite.flip_h = true
		parent.body_sprite.flip_h = true

func handle_leg_animations():
	if parent.direction != Vector2.ZERO:
		parent.legs_animation_player.play("Walk")
	else:
		parent.legs_animation_player.play("Idle")
