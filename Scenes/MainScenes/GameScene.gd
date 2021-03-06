extends Node2D


signal game_finished(result)


var map_node : Node2D
var build_mode : bool = false
var build_valid : bool = false
var build_location
var build_type : String

var current_wave : int = 0
var enemies_in_wave : int = 0
var base_health : int = 100

func _ready():
	map_node = $Map1 # TODO make dynamic
	
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
	

##
## Wave Functions
##
func start_next_wave():
	var wave_data : Array = retrieve_wave_data()
	yield(get_tree().create_timer(0.2), "timeout")
	spawn_enemies(wave_data)
	
	
func retrieve_wave_data() -> Array:
	var wave_data = [["BlueTank", 0.7], ["BlueTank", 0.1], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7]] # TODO Make dynamic
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data
	

func spawn_enemies(wave_data: Array):
	for i in wave_data:
		var new_enemy : PathFollow2D = load("res://Scenes/Enemies/" + i[0] + ".tscn").instance()
		new_enemy.connect("base_damage", self, "on_base_damage")
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(i[1]), "timeout")
	
	
##
## Building Functions
##
func cancel_build_mode():
	build_mode = false
	build_valid = false
	$UI/TowerPreview.free()
	
	
func verify_and_build():
	if build_valid:
		# TODO Test to verify player has enough cash
		var amount = GameData.tower_data[build_type]["cost"]
		if ($UI as UI).has_enough_money(amount):
			($UI as UI).update_money_amount(-amount)
			var new_tower: Node2D = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
			new_tower.position = build_location
			new_tower.built = true
			new_tower.type = build_type
			new_tower.category = GameData.tower_data[build_type]["category"]
			map_node.get_node("Turrets").add_child(new_tower, true)
		else:
			# TODO display to player
			print("not enough money!")
			($UI as UI).not_enough_money()


func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type + "T1"
	build_mode = true
	($UI as UI).set_tower_preview(build_type, get_global_mouse_position())

	
func update_tower_preview():
	var mouse_position : Vector2 = get_global_mouse_position()
	var tower_exclusion : TileMap = map_node.get_node("TowerExclusion")
	var current_tile : Vector2 = tower_exclusion.world_to_map(mouse_position)
	var tile_position : Vector2 = tower_exclusion.map_to_world(current_tile)
	
	# -1 means tile is empty (and therefore a valid location to place a new tower)
	if tower_exclusion.get_cellv(current_tile) == -1:
		($UI as UI).update_tower_preview(tile_position, "#ad54ff3c")
		build_valid = true
		build_location = tile_position
	else:
		($UI as UI).update_tower_preview(tile_position, "#adff4545")
		build_valid = false


func on_base_damage(damage : int):
	base_health -= damage
	if base_health <= 0:
		emit_signal("game_finished", false)
	else:
		($UI as UI).update_health_bar(base_health)
