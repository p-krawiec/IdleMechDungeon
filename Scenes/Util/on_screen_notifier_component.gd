extends VisibleOnScreenNotifier2D
class_name OnScreenNotifierComponent

@export var color: Color = Color.WHITE
@export var should_be_visible = true

var player: Player
var id: String

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	id = str(get_instance_id())

func _process(_delta):
	if should_be_visible:
		if not is_on_screen():
			display_indicator()
		else:
			hide_indicator()
	else:
		hide_indicator()
		
func display_indicator():
	if not player.get_node("Indicators").has_node(id):
		var new_indicator = Sprite2D.new()
		new_indicator.name = id
		new_indicator.visible = false
		new_indicator.add_to_group("Indicator")
		(new_indicator as Sprite2D).texture = load("res://Assets/UI/indicators/indicator.png")
		(new_indicator as Sprite2D).self_modulate = color
		(new_indicator as Sprite2D).scale = (Vector2.ONE / 2)
		new_indicator.z_index = 100
		player.get_node("Indicators").add_child(new_indicator)
	else:
		var indicator = player.get_node("Indicators").get_node(id)
		var direction_to_entity = player.global_position.direction_to(global_position)
		
		(indicator as Sprite2D).position = direction_to_entity.normalized() * 25
		(indicator as Sprite2D).rotation = direction_to_entity.angle()
		
		indicator.visible = true
	
func hide_indicator():
	if player.get_node("Indicators").has_node(id):
		player.get_node("Indicators").get_node(id).queue_free()
