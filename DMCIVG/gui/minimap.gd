extends MarginContainer

# export variables
export (NodePath) var player
export var zoom = 1.5

# child node reference variables
onready var grid = get_node("contents/grid")
onready var player_marker = get_node("contents/grid/player")
onready var enemy_marker = get_node("contents/grid/enemy")
onready var boss_marker = get_node("contents/grid/boss")
onready var item_marker = get_node("contents/grid/item")

# tag dictionary
onready var icons = {"enemy": enemy_marker, "boss": boss_marker, "item": item_marker}

# minimap logistics
var grid_scale
var markers = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	player_marker.position = grid.rect_size / 2
	print("mm pos: ", player_marker.position)
	grid_scale = grid.rect_size / (get_viewport_rect().size * zoom)
	var map_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in map_objects:
		var new_marker = icons[item.mm_icon]
		grid.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker
		print("new marker: ", new_marker)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !player:
		return
	for item in markers:
		var obj_pos = (item.position - get_node(player).position) * grid_scale + grid.rect_size / 2
		if grid.get_rect().has_point(obj_pos + grid.rect_position):
			markers[item].show()
		else:
			markers[item].hide()
		obj_pos.x = clamp(obj_pos.x, 0, grid.rect_size.x)
		obj_pos.y = clamp(obj_pos.y, 0, grid.rect_size.y)
		markers[item].position = obj_pos
