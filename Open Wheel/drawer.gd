extends Control

@export var fl_friction_circle: Control
@export var fr_friction_circle: Control
@export var rl_friction_circle: Control
@export var rr_friction_circle: Control

func _process(delta):
	queue_redraw()

func _draw():
	##draw_circle(Vector2(256, 256), 16.0, Color.RED)
	##draw_circle(Vector2(256, 256), 128.0, Color(Color.DIM_GRAY, 0.5))
	draw_circle(fl_friction_circle.get_screen_position(), fl_friction_circle.size.x, Color(0.0, 0.0, 0.0, 0.5))
