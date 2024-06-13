extends StaticBody2D

@export var on: bool = true

func _ready():
	if on:
		$AnimatedSprite2D.play("on")
	else:
		$AnimatedSprite2D.play("off")
