class_name Car

extends RigidBody3D

@export var controller: Controller
@export var running_gear: RunningGear
@export var engine: CarEngine
@export var transmission: Transmission
@export var differential: Differential

@export var gear_ratios: Array[float] = [
	-2.00,  # Reverse gear
	2.07,
	1.56,
	1.20,
	0.95,
	0.77,
	0.63
]
@export var final_drive: float = 4.26
@export var clutch_torque_capacity: float = 621.0
var transmission_inertia: float = 0.5
var differential_inertia: float = 0.5

var current_gear: int = 1

var camera_mode: CameraMode = CameraMode.FOLLOW
var camera_rotation: Vector3 = Vector3.ZERO
var follow_camera_start_align: bool = true
var camera_shake: Vector3 = Vector3.ZERO

enum CameraMode{
	FOLLOW,
	BUMPER
}
@onready var camera: Dictionary = {
	CameraMode.FOLLOW : $FollowCameraPivot/FollowCamera,
	CameraMode.BUMPER : $BumperCamera
}

func _ready() -> void:
	Debug.current_car = self
	running_gear.update_wheel_properties()

func _input(event) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			follow_camera_start_align = false
			$FollowCameraReset.start()
			camera_rotation.y += event.relative.x * -0.005
			camera_rotation.x += event.relative.y * -0.005
			camera_rotation.y = wrapf(camera_rotation.y, -PI, PI)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta) -> void:
	camera_rotation.x = clamp(camera_rotation.x, -PI/2.0, 0)
	if follow_camera_start_align:
		camera_rotation *= pow(32, -delta)
	$FollowCameraPivot.rotation.y = camera_rotation.y
	$FollowCameraPivot.rotation.x = camera_rotation.x
	$FollowCameraPivot/FollowCamera.transform.origin = Vector3.ZERO
	$FollowCameraPivot/FollowCamera.transform.origin.z = 6.0
	$FollowCameraPivot/FollowCamera.transform.origin.y = 2.0 * (1.0 + sin(camera_rotation.x))
	var just_changed_camera: bool = false
	if Input.is_action_just_pressed("camera"):
		just_changed_camera = true
		camera_mode = CameraMode.values()[(int(camera_mode) + 1) % CameraMode.size()]
	if just_changed_camera:
		match camera_mode:
			CameraMode.FOLLOW:
				$BumperCamera.current = false
				$FollowCameraPivot/FollowCamera.current = true
			CameraMode.BUMPER:
				$FollowCameraPivot/FollowCamera.current = false
				$BumperCamera.current = true

var engine_angular_velocity: float = 0.0
var differential_angular_velocity: float = 0.0

func _integrate_forces(state) -> void:
	# Handle gear shifting
	if Input.is_action_just_pressed("shift_up"):
		current_gear = (current_gear + 1)
	if Input.is_action_just_pressed("shift_down"):
		current_gear = (current_gear - 1)

	# Simulate basic vehicle systems
	running_gear.simulate_suspensions(state, controller)

	# Calculate drivetrain forces
	var engine_torque = engine.get_engine_torque(engine_angular_velocity, controller)

	# Sum differential torque from rear wheels
	var differential_torque = 0.0
	var drivetrain_inertia = differential_inertia + transmission_inertia
	for wheel in [RunningGear.Wheel.REAR_LEFT, RunningGear.Wheel.REAR_RIGHT]:
		differential_torque += running_gear.wheel_states[wheel][RunningGear.WheelState.TORQUE]
		drivetrain_inertia += running_gear.wheel_properties[wheel][RunningGear.WheelProperty.INERTIA]
	# Calculate clutch forces
	var combined_gear_ratio = gear_ratios[current_gear] * final_drive
	var speed_difference: float = engine_angular_velocity - differential_angular_velocity * combined_gear_ratio
	var applied_clutch: float = clutch_torque_capacity * (1.0 - controller.control_value[Controller.ControlValue.CLUTCH])
	var applied_torque: float = max(abs(engine_torque), abs(differential_torque))
	var clutch_torque: float = sign(speed_difference) * min(applied_torque, applied_clutch)

	# Update angular velocities
	engine_angular_velocity += (engine_torque - clutch_torque) / engine.inertia * state.step
	differential_angular_velocity += (clutch_torque * combined_gear_ratio - differential_torque) / (drivetrain_inertia) * state.step

	# Apply forces to wheels
	for wheel in RunningGear.Wheel.values():
		if not running_gear.wheel_states[wheel][RunningGear.WheelState.IN_CONTACT]:
			continue

		var offset = state.transform.basis * running_gear.wheel_properties[wheel][RunningGear.WheelProperty.POSITION]

		state.apply_force(
			running_gear.wheel_states[wheel][RunningGear.WheelState.LOAD],
			offset
		)
		state.apply_force(
			running_gear.wheel_states[wheel][RunningGear.WheelState.FORCE],
			running_gear.wheel_states[wheel][RunningGear.WheelState.CONTACT_POINT]
		)

	# Update wheel angular velocities
	for wheel in [RunningGear.Wheel.REAR_LEFT, RunningGear.Wheel.REAR_RIGHT]:
		running_gear.wheel_states[wheel][RunningGear.WheelState.ANGULAR_VELOCITY] = differential_angular_velocity

func _on_follow_camera_reset_timeout():
	follow_camera_start_align = true
