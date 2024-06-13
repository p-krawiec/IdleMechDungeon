extends CharacterBody2D

@export var move_speed = 30.0
@onready var sprite = $AnimatedSprite2D

var direction = Vector2.ZERO
var random_direction = Vector2.ZERO
var random_speed_modifier = 1.0

func _ready():
	decide_what_to_do()

func _physics_process(_delta):
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x <0:
		sprite.flip_h = true
	
	velocity = direction * move_speed * random_speed_modifier
	
	var collider = move_and_slide()
	if collider:
		direction = Vector2.ZERO
		decide_what_to_do()

func decide_what_to_do():
	var should_walk = bool(randi() % 2 == 0)
	$Timer.wait_time = get_random_wander_time()
	
	if should_walk:
		random_speed_modifier = get_random_speed_modified()
		random_direction = get_random_direction()
		direction = random_direction
	else:
		direction = Vector2.ZERO
	
	$Timer.start()

func _on_timer_timeout():
	direction = Vector2.ZERO
	decide_what_to_do()

func get_random_speed_modified() -> float:
	return randf_range(0.5, 1.1)

func get_random_direction() -> Vector2:
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func get_random_wander_time() -> float:
	return randf_range(0.5, 3.5)

