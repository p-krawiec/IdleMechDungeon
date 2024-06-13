extends Node2D

var text: String

func _ready():
	$Label.text = text
	$Timer.start()


func _on_timer_timeout():
	queue_free()
