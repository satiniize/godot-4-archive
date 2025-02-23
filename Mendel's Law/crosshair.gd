extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _draw():
	draw_circle(get_viewport_rect().size / 2.0, 4.0, Color(1.0, 1.0, 1.0, 0.5))


	
