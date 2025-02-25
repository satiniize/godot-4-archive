class_name Car

extends RigidBody3D

@export var controller: Controller

@export_group("Tire Model")
@export var longitudinal_friction_coefficient: float = 1.0
@export var lateral_friction_coefficient: float = 1.0
@export var longitudinal_stiffness: float = 25000.0
@export var cornering_stiffness: float = 20000.0
@export var camber_stiffness: float = 0.0

@export_subgroup("Pacejka Magic Formula")
@export var pacejka_b: float = 0.714
@export var pacejka_c: float = 1.40
@export var pacejka_d: float = 1.00
@export var pacejka_e: float = -0.20

@export_group("Chassis Specs")
@export var wheel_base: float = 3.0
@export var track_width: float = 2.0

@export_group("Engine Specs")
@export var torque_curve: Curve
@export var peak_torque: float = 200.0
@export var idle_speed: float = 209.4
@export var lower_redline: float = 1047
@export var upper_redline: float = 1047
@export var engine_inertia: float = 0.2

@export_group("Transmission Specs")
@export_subgroup("Gearing")
@export var final_drive: float = 4.26
@export var gear_ratios: Array[float] = [
	-2.00,  # Reverse gear
	2.07,
	1.56,
	1.20,
	0.95,
	0.77,
	0.63
]
@export var clutch_torque_capacity: float = 621.0
@export var transmission_efficiency: float = 1.0

@export_group("Running Gear Specs")
@export_subgroup("Suspension")
@export var front_spring_stiffness: float = 60000
@export var rear_spring_stiffness: float = 80000
# TODO: Implement variable damping (rebound and bump stiffness)
@export var front_shock_damping: float = 6000
@export var rear_shock_damping: float = 8000
@export var front_ride_height: float = 0.2
@export var rear_ride_height: float = 0.2

@export_subgroup("Alignment")
@export var front_camber: float
@export var rear_camber: float
@export var front_toe: float
@export var rear_toe: float
@export var front_caster: float
@export var rear_caster: float

@export_subgroup("Anti-roll bars")
@export var front_antiroll_bar_stiffness: float
@export var rear_antiroll_bar_stiffness: float

@export_subgroup("Brakes")
@export_range(0.0, 1.0) var brake_balance
@export var brake_pressure: float
@export var brake_max_torque: float

@export_subgroup("Differential")
@export var something_idk_man: float

@export_subgroup("Wheel")
@export var front_rim_size: float
@export var front_tire_width: float
@export_range(0.0, 100.0) var front_tire_profile
@export var front_wheel_inertia: float = 0.4
@export var front_tire_pressure: float
@export var rear_rim_size: float
@export var rear_tire_width: float
@export_range(0.0, 100.0) var rear_tire_profile
@export var rear_wheel_inertia: float = 0.4
@export var rear_tire_pressure: float

@export_subgroup("Steering")
@export var front_max_steer_angle: float
@export var rear_max_steer_angle: float

@export_group("Aerodynamics")
@export var template_value: float

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

var engine_angular_velocity: float = 0.0
var current_gear: int = 1
var differential_angular_velocity: float = 0.0
var transmission_inertia: float = 0.5

enum Wheel{
	FRONT_LEFT,
	FRONT_RIGHT,
	REAR_LEFT,
	REAR_RIGHT
}

enum WheelState{
	ANGULAR_VELOCITY,
	LOAD,
	FORCE,
	IS_SLIPPING,
}

var wheel_states: Dictionary = {
	Wheel.FRONT_LEFT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: 0.0,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.FRONT_RIGHT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: 0.0,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.REAR_LEFT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: 0.0,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.REAR_RIGHT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: 0.0,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IS_SLIPPING: false,
	}
}

enum WheelProperty{
	POSITION,
	SPRING_STIFFNESS,
	SHOCK_DAMPING,
	RIDE_HEIGHT,
	EFFECTIVE_RADIUS,
	MAX_STEER_ANGLE,
	STEER_BIAS,
	INERTIA,
	DRIVEN
}
var wheel_properties: Dictionary

func update_wheel_properties() -> void:
	wheel_properties = {
		Wheel.FRONT_LEFT: {
			WheelProperty.POSITION: Vector3(-1, 0, -1),
			WheelProperty.SPRING_STIFFNESS: front_spring_stiffness,
			WheelProperty.SHOCK_DAMPING: front_shock_damping,
			WheelProperty.RIDE_HEIGHT: front_ride_height,
			WheelProperty.EFFECTIVE_RADIUS: 0.3,
			WheelProperty.MAX_STEER_ANGLE: 30.0 * PI / 180.0,
			WheelProperty.STEER_BIAS: 1.0,
			WheelProperty.INERTIA: 0.6,
			WheelProperty.DRIVEN: false,
		},
		Wheel.FRONT_RIGHT: {
			WheelProperty.POSITION: Vector3(1, 0, -1),
			WheelProperty.SPRING_STIFFNESS: front_spring_stiffness,
			WheelProperty.SHOCK_DAMPING: front_shock_damping,
			WheelProperty.RIDE_HEIGHT: front_ride_height,
			WheelProperty.EFFECTIVE_RADIUS: 0.3,
			WheelProperty.MAX_STEER_ANGLE: 30.0 * PI / 180.0,
			WheelProperty.STEER_BIAS: 1.0,
			WheelProperty.INERTIA: 0.6,
			WheelProperty.DRIVEN: false,
		},
		Wheel.REAR_LEFT: {
			WheelProperty.POSITION: Vector3(-1, 0, 1),
			WheelProperty.SPRING_STIFFNESS: rear_spring_stiffness,
			WheelProperty.SHOCK_DAMPING: rear_shock_damping,
			WheelProperty.RIDE_HEIGHT: rear_ride_height,
			WheelProperty.EFFECTIVE_RADIUS: 0.3,
			WheelProperty.MAX_STEER_ANGLE: 30.0 * PI / 180.0,
			WheelProperty.STEER_BIAS: 0.0,
			WheelProperty.INERTIA: 0.6,
			WheelProperty.DRIVEN: true,
		},
		Wheel.REAR_RIGHT: {
			WheelProperty.POSITION: Vector3(1, 0, 1),
			WheelProperty.SPRING_STIFFNESS: rear_spring_stiffness,
			WheelProperty.SHOCK_DAMPING: rear_shock_damping,
			WheelProperty.RIDE_HEIGHT: rear_ride_height,
			WheelProperty.EFFECTIVE_RADIUS: 0.3,
			WheelProperty.MAX_STEER_ANGLE: 30.0 * PI / 180.0,
			WheelProperty.STEER_BIAS: 0.0,
			WheelProperty.INERTIA: 0.6,
			WheelProperty.DRIVEN: true,
		}
	}
	return

func _ready():
	Debug.current_car = self
	update_wheel_properties()

func _input(event):
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

func _process(delta):
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

	if Input.is_action_just_pressed("shift_up"):
		current_gear = (current_gear + 1)
	if Input.is_action_just_pressed("shift_down"):
		current_gear = (current_gear - 1)

func calculate_suspension_load(spring_compression_delta, suspension_velocity, spring_stiffness, shock_damping):
	var spring_force: Vector3 = (
		spring_stiffness *
		-spring_compression_delta
	)
	var shock_force: Vector3 = (
		shock_damping *
		-suspension_velocity
	)
	return spring_force + shock_force

func process_engine_logic(state) -> void:
 # Calculate applied clutch value
	var applied_clutch: float = (
		clutch_torque_capacity *
		(1.0 - controller.control_value[Controller.ControlValue.CLUTCH])
	)
	# Engine acceleration and braking logic
	var target_engine_angular_velocity: float = idle_speed + (upper_redline - idle_speed) * controller.control_value[Controller.ControlValue.ACCELERATE]
	var engine_torque: float = peak_torque * torque_curve.sample(engine_angular_velocity / upper_redline) * sign(target_engine_angular_velocity - engine_angular_velocity)
	var engine_angular_acceleration: float = engine_torque / engine_inertia
	engine_angular_velocity += engine_angular_acceleration * state.step

	# Apply clutch limits to engine torque
	engine_torque = sign(engine_torque) * min(abs(engine_torque), applied_clutch)

	# Differential interaction calculations
	var total_gear_ratio: float = final_drive * gear_ratios[current_gear]
	var engine_differential_speed_difference: float = engine_angular_velocity - differential_angular_velocity * total_gear_ratio
	var engine_impulse: float = sign(engine_differential_speed_difference) * applied_clutch * state.step
	var differential_impulse: float = sign(engine_differential_speed_difference) * applied_clutch * total_gear_ratio * state.step

	engine_angular_velocity -= engine_impulse / engine_inertia
	differential_angular_velocity += differential_impulse / transmission_inertia

# TODO: Implement camber force
func _integrate_forces(state) -> void:
	process_engine_logic(state)

	var differential_torque: float = 0.0
	var total_differential_inertia = transmission_inertia

	var origin = state.transform.origin
	var x_basis = state.transform.basis.x
	var y_basis = state.transform.basis.y
	var z_basis = state.transform.basis.z

	for wheel in Wheel.values():
		#LGTM
		var offset = (
			x_basis * wheel_properties[wheel][WheelProperty.POSITION].x * track_width / 2.0 +
			z_basis * wheel_properties[wheel][WheelProperty.POSITION].z * wheel_base / 2.0
		)

		var margin = 0.04
		var cast_origin = (origin + offset) + (y_basis * margin)
		var cast_end = (
			cast_origin +
			-y_basis * (
				wheel_properties[wheel][WheelProperty.RIDE_HEIGHT] +
				margin
			)
		)

		var space_state: PhysicsDirectSpaceState3D = state.get_space_state()
		var query = PhysicsRayQueryParameters3D.create(cast_origin, cast_end, 0x01)
		var result = space_state.intersect_ray(query)

		if result:
			#LGTM
			var collision_point: Vector3 = result["position"]
			var rotation_radius: Vector3 = (
				collision_point - (origin + state.transform.basis * state.center_of_mass)
			)
			var contact_velocity: Vector3 = (
				state.linear_velocity + state.angular_velocity.cross(rotation_radius)
			)
			var suspension_load: Vector3 = calculate_suspension_load(
				cast_end - collision_point, #Delta x, in vector form
				contact_velocity.project(y_basis), #Speed for dampening
				wheel_properties[wheel][WheelProperty.SPRING_STIFFNESS],
				wheel_properties[wheel][WheelProperty.SHOCK_DAMPING]
			)

			if suspension_load.dot(y_basis) > 0.0: #Spring is in compression
				wheel_states[wheel][WheelState.LOAD] = suspension_load.length()
				state.apply_force(suspension_load, collision_point - origin)

				var wheel_steer_angle: float = (
					-controller.control_value[Controller.ControlValue.STEER] *
					wheel_properties[wheel][WheelProperty.MAX_STEER_ANGLE] *
					wheel_properties[wheel][WheelProperty.STEER_BIAS]
				)
				var wheel_direction: Vector3 = -z_basis.rotated(y_basis, wheel_steer_angle)

				# TODO: Replace with proper differential model
				if wheel_properties[wheel][WheelProperty.DRIVEN]:
					wheel_states[wheel][WheelState.ANGULAR_VELOCITY] = differential_angular_velocity

				var wheel_speed: float = (
					wheel_states[wheel][WheelState.ANGULAR_VELOCITY] *
					wheel_properties[wheel][WheelProperty.EFFECTIVE_RADIUS]
				)

				var free_rolling_speed: float = contact_velocity.dot(wheel_direction)
				var slip_ratio: float = 0.0

				# Slip ratio
				if !is_zero_approx(free_rolling_speed):
					slip_ratio = (wheel_speed - free_rolling_speed) / abs(free_rolling_speed)
				elif !is_zero_approx(wheel_speed):
					slip_ratio = 2.0
				else:
					slip_ratio = 0.0

				# TODO: Change wheel_direction definition for future compatibility
				var velocity_longitudinal = contact_velocity.dot(wheel_direction)
				var velocity_lateral = contact_velocity.dot(wheel_direction.rotated(y_basis, -PI/2.0))

				var slip_angle: float = 0.0
				var slip_angle_gradient: float = 2.0

				# TODO: This might be a bug; I dont think this works going backwards
				if !is_zero_approx(velocity_longitudinal):
					slip_angle = atan2(velocity_lateral, velocity_longitudinal) / PI
					slip_angle_gradient = velocity_lateral / velocity_longitudinal
					# slip_angle_gradient = tan(slip_angle)

				#TODO: fix backwards slip logic

				var normalized_slip_ratio: float = (
					longitudinal_stiffness *
					slip_ratio / (
						longitudinal_friction_coefficient *
						suspension_load.dot(y_basis)
					)
				)
				var normalized_slip_angle: float = (
					cornering_stiffness *
					tan(slip_angle) / (
						lateral_friction_coefficient *
						suspension_load.dot(y_basis)
					)
				)
				var normalized_combined_slip: float = (
					sqrt(
						normalized_slip_ratio*normalized_slip_ratio +
						normalized_slip_angle*normalized_slip_angle
					)
				)

				var mu_zero: float = (
					cornering_stiffness *
					longitudinal_friction_coefficient / (
						longitudinal_stiffness *
						lateral_friction_coefficient
					)
				)
				var multiplier_value: float		= multiplier(normalized_combined_slip, mu_zero)
				var pacejka_value: float		= pacejka(normalized_combined_slip, pacejka_b, pacejka_c, pacejka_d, pacejka_e)
				var magic_constant: float		= (
					pacejka_value
					/ max(
						sqrt(
							slip_ratio*slip_ratio +
							multiplier_value*multiplier_value *
							slip_angle_gradient*slip_angle_gradient
						),
						0.001
					)
				)

				var normalized_lateral_force: float = (
					multiplier_value
					* sign(velocity_longitudinal) #TODO: Band aid fix; figure out why this is
					* slip_angle_gradient
					* magic_constant
				)
				var normalized_longitudinal_force: float = (
					slip_ratio
					* magic_constant
				)

				var longitudinal_force: Vector3 = (
					wheel_direction *
					suspension_load.dot(y_basis) *
					longitudinal_friction_coefficient *
					normalized_longitudinal_force
				)
				var lateral_force: Vector3 = (
					wheel_direction.rotated(y_basis, PI/2.0) *
					suspension_load.dot(y_basis) *
					lateral_friction_coefficient *
					normalized_lateral_force
				)
				var total_force: Vector3 = (
					longitudinal_force + lateral_force
				)

				wheel_states[wheel][WheelState.FORCE] = total_force
				state.apply_force(
					total_force,
					collision_point - origin
				)

				var wheel_torque = longitudinal_force.dot(wheel_direction) * wheel_properties[wheel][WheelProperty.EFFECTIVE_RADIUS]
				var wheel_angular_acceleration = (
					wheel_torque
					/ wheel_properties[wheel][WheelProperty.INERTIA]
				)
				if wheel_properties[wheel][WheelProperty.DRIVEN]:
					total_differential_inertia += wheel_properties[wheel][WheelProperty.INERTIA]
					differential_torque -= (
					   wheel_torque
					)
				else:
					wheel_states[wheel][WheelState.ANGULAR_VELOCITY] -= (
						wheel_angular_acceleration *
						state.step
					)
	differential_angular_velocity += (differential_torque / total_differential_inertia) * state.step

func multiplier(combined_normalized_slip: float, mu_zero: float) -> float:
	var result: float = 1.0
	if abs(combined_normalized_slip) <= 2.0*PI:
		result = 0.5*(1.0 + mu_zero) - 0.5*(1.0 - mu_zero) * cos(combined_normalized_slip / 2.0)
	return result

func pacejka(x: float, b: float, c: float, d: float, e: float) -> float:
	return d * sin(c * atan(b * x - e * (b * x - atan(b * x))))

func _on_follow_camera_reset_timeout():
	follow_camera_start_align = true
