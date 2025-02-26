extends Control

var force_front_left: Vector3 = Vector3.ZERO
var force_front_right: Vector3 = Vector3.ZERO
var force_rear_left: Vector3 = Vector3.ZERO
var force_rear_right: Vector3 = Vector3.ZERO

var load_front_left: float = 0.0
var load_front_right: float = 0.0
var load_rear_left: float = 0.0
var load_rear_right: float = 0.0

var car_relative_velocity: Vector3 = Vector3.ZERO

func _process(_delta):
	queue_redraw()

func draw_friction_forces(position: Vector2, force: Vector3, load: float):
	var scaler: float = 0.02
	var offset = Vector2(force.x, force.z) * scaler
	draw_circle(position, load * scaler, Color.YELLOW)
	draw_line(position, position + offset, Color.GREEN, 16.0)

func _draw():
	var rect_pos = Vector2(128, 128)
	var rect_size = Vector2(256, 384)

	draw_rect(Rect2(rect_pos, rect_size), Color.DIM_GRAY)
	var fl_pos = rect_pos + Vector2.ZERO
	var fr_pos = rect_pos + Vector2(rect_size.x, 0)
	var rl_pos = rect_pos + Vector2(0, rect_size.y)
	var rr_pos = rect_pos + Vector2(rect_size.x, rect_size.y)

	draw_friction_forces(fl_pos, force_front_left, load_front_left)
	draw_friction_forces(fr_pos, force_front_right, load_front_right)
	draw_friction_forces(rl_pos, force_rear_left, load_rear_left)
	draw_friction_forces(rr_pos, force_rear_right, load_rear_right)

	var line_start = rect_pos + rect_size / 2
	var velocity_offset = Vector2(car_relative_velocity.x, car_relative_velocity.z) * 8
	var line_end = line_start + velocity_offset
	draw_line(line_start, line_end, Color.RED, 16.0)
