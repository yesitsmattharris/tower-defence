extends PathFollow2D

var speed : int = 150

func _physics_process(delta: float):
	move(delta)
	
func move(delta: float):
	set_offset(get_offset() + speed * delta)
