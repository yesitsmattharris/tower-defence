extends Node2D


var map_node : Node2D
var build_mode : bool = false
var build_valid : bool = false
var build_location
var build_type : String


func _ready():
	map_node = get_node("Map1") # TODO make dynamic
	
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()])


func _process(delta):
	if build_mode:
		update_tower_preview()

	
func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()
	
	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").queue_free()
	
	
func verify_and_build():
	if build_valid:
		# TODO Test to verify player has enough cash
		var new_tower: Node2D = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		map_node.get_node("Turrets").add_child(new_tower, true)
		# TODO deduct cash
		# TODO update cash label


func initiate_build_mode(tower_type):
	build_type = tower_type + "T1"
	build_mode = true
	(get_node("UI") as UI).set_tower_preview(build_type, get_global_mouse_position())

	
func update_tower_preview():
	var mouse_position : Vector2 = get_global_mouse_position()
	var tower_exclusion : TileMap = map_node.get_node("TowerExclusion")
	var current_tile : Vector2 = tower_exclusion.world_to_map(mouse_position)
	var tile_position : Vector2 = tower_exclusion.map_to_world(current_tile)
	
	# -1 means tile is empty (and therefore a valid location to place a new tower)
	if tower_exclusion.get_cellv(current_tile) == -1:
		(get_node("UI") as UI).update_tower_preview(tile_position, "#ad54ff3c")
		build_valid = true
		build_location = tile_position
	else:
		(get_node("UI") as UI).update_tower_preview(tile_position, "#adff4545")
		build_valid = false
