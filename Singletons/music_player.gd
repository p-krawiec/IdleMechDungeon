extends AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
#	stream = load("res://Assets/Music/Space Rider.ogg")
	stream = load("res://Assets/Music/BossBattle.ogg")
	autoplay = true
	bus = "Music"
	volume_db = -5
	
	play()
	
func change_music_to(music_name):
	stream = load("res://Assets/Music/" + music_name + ".ogg")
