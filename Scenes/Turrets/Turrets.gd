extends Node2D


var type
var enemy
var built : bool = false
var ready : bool = true
var enemy_array : Array = []


func _ready():
	if built:
		(self.get_node("Range/CollisionShape2D") as CollisionShape2D).get_shape().radius = 0.5 * GameData.tower_data[type]["range"]


func _physics_process(_delta):
	if enemy_array.size() > 0 and built:
		select_enemy()
		turn()
		if ready:
			fire()
	else:
		enemy = null
		
		
func turn():
	get_node("Turret").look_at(enemy.position)
	
	
func select_enemy():
	var enemy_progress_array : Array = []
	for i in enemy_array:
		enemy_progress_array.append(i.offset)
	var max_offset : float = enemy_progress_array.max()
	var enemy_index : int = enemy_progress_array.find(max_offset)
	enemy = enemy_array[enemy_index]


func fire():
	ready = false
	enemy.on_hit(GameData.tower_data[type]["damage"])
	yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout")
	ready = true

func _on_Range_body_entered(body : KinematicBody2D):
	enemy_array.append(body.get_parent())


func _on_Range_body_exited(body : KinematicBody2D):
		enemy_array.erase(body.get_parent())
