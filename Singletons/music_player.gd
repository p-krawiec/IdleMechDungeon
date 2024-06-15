extends AudioStreamPlayer

var tracks = [	preload("res://Assets/Music/CyberRunner.ogg"),
				preload("res://Assets/Music/MagicFx.ogg"), 
				preload("res://Assets/Music/SpaceRider.ogg"), 
				preload("res://Assets/Music/SpaceRay.ogg"),
				preload("res://Assets/Music/SpaceshipShooter.ogg")]
				
var boss_track = preload("res://Assets/Music/BossBattle.ogg")

var fading_out = false
var fade_out_time = 0.16

var fading_in = false
var fade_in_time = 1.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
#	stream = load("res://Assets/Music/Space Rider.ogg")
	stream = tracks.pick_random()
	autoplay = true
	bus = "Music"
	
	play()
	
func change_music_to(track_name):
	stream = get_track_stream(track_name)
	play()

func get_track_stream(track_name):
	return load("res://Assets/Music/" + track_name + ".ogg")

func pick_random_track():
	stream = tracks.pick_random()
	play()

func mute_music():
	volume_db = linear_to_db(0)
	
func unmute_music():
	volume_db = linear_to_db(1)

func _process(delta):
	if fading_out:
		volume_db -= (60 / fade_out_time) * delta
		if volume_db <= -60:
			mute_music()
			fading_out = false
	
	if fading_in:
		volume_db += (60 / fade_in_time) * delta
		if volume_db >= 0:
			unmute_music()
			fading_in = false

func fade_out_music(time):
	fade_out_time = time
	fading_out = true
	
func fade_in_music(time):
	fade_in_time = time
	volume_db = -60
	fading_in = true
