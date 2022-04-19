extends PathFollow2D


var speed : int = 150
var hp: int = 50

onready var health_bar := $HealthBar


func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_toplevel(true)


func _physics_process(delta : float):
	move(delta)
	
	
func move(delta : float):
	set_offset(get_offset() + speed * delta)
	health_bar.set_position(position - Vector2(30, 30))


func on_hit(damage : int):
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		on_destroy()
		
		
func on_destroy():
	self.queue_free()
