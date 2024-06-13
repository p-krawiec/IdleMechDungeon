extends Node2D

var did_emission_started = false

func _ready():
	$CPUParticles2D.emitting = true
	did_emission_started = true
	
func _process(_delta):
	if did_emission_started:
		if not $CPUParticles2D.emitting:
			queue_free()
