extends StaticBody2D

@export var front: bool = false

func _ready():
	if front:
		$Sprite2D.frame = 180
	else:
		$Sprite2D.frame = 179
