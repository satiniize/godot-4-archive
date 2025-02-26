class_name CarEngine

extends Node

@export var torque_curve: Curve
@export var peak_torque: float = 200.0
@export var idle_speed: float = 2000.0 * 0.1047
@export var lower_redline: float = 10000.0 * 0.1047
@export var upper_redline: float = 10000.0 * 0.1047
@export var inertia: float = 0.2

func get_engine_torque(engine_angular_velocity, controller) -> float:
	var target_engine_angular_velocity: float = idle_speed + (upper_redline - idle_speed) * controller.control_value[Controller.ControlValue.ACCELERATE]
	var engine_torque: float = peak_torque * torque_curve.sample(engine_angular_velocity / upper_redline) * sign(target_engine_angular_velocity - engine_angular_velocity)
	return engine_torque
