class_name Controller

extends Node

enum ControlValue{
	ACCELERATE,
	BRAKE,
	CLUTCH,
	STEER,
	GEAR
}
var control_value: Dictionary = {
	ControlValue.ACCELERATE: 0.0,
	ControlValue.BRAKE: 0.0,
	ControlValue.CLUTCH: 0.0,
	ControlValue.STEER: 0.0,
	ControlValue.GEAR: 0.0,
}
