class_name RunningGear

extends Node

@export_group("Tire Model")
@export_subgroup("Pacejka Magic Formula")
@export var pacejka_b: float = 0.714
@export var pacejka_c: float = 1.40
@export var pacejka_d: float = 1.00
@export var pacejka_e: float = -0.20

@export_subgroup("Friction and Stiffness")
@export var longitudinal_friction_coefficient: float = 1.0
@export var lateral_friction_coefficient: float = 1.0
@export var longitudinal_stiffness: float = 25000.0
@export var cornering_stiffness: float = 20000.0
@export var camber_stiffness: float = 0.0

@export_group("Chassis")
@export var wheel_base: float = 3.0
@export var track_width: float = 2.0

@export_group("Running Gear")
@export_subgroup("Suspension")
@export var front_spring_stiffness: float = 60000
@export var rear_spring_stiffness: float = 80000
# TODO: Implement variable damping (rebound and bump stiffness)
@export var front_shock_damping: float = 6000
@export var rear_shock_damping: float = 8000
@export var front_ride_height: float = 0.2
@export var rear_ride_height: float = 0.2

@export_subgroup("Anti-roll bars")
@export var front_antiroll_bar_stiffness: float
@export var rear_antiroll_bar_stiffness: float

@export_subgroup("Alignment")
@export var front_camber: float
@export var rear_camber: float
@export var front_toe: float
@export var rear_toe: float
@export var front_caster: float
@export var rear_caster: float

@export_subgroup("Brakes")
@export_range(0.0, 1.0) var brake_balance
@export var brake_pressure: float
@export var brake_max_torque: float

@export_group("Wheels")
@export_subgroup("Front Wheels")
@export var front_rim_size: float
@export var front_tire_width: float
@export_range(0.0, 100.0) var front_tire_profile
@export var front_wheel_inertia: float = 0.4
@export var front_tire_pressure: float

@export_subgroup("Rear Wheels")
@export var rear_rim_size: float
@export var rear_tire_width: float
@export_range(0.0, 100.0) var rear_tire_profile
@export var rear_wheel_inertia: float = 0.4
@export var rear_tire_pressure: float

@export_group("Steering")
@export var front_max_steer_angle: float
@export var rear_max_steer_angle: float

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
	IN_CONTACT,
	CONTACT_POINT,
	TORQUE,
	IS_SLIPPING,
}

var wheel_states: Dictionary = {
	Wheel.FRONT_LEFT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: Vector3.ZERO,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IN_CONTACT: false,
		WheelState.CONTACT_POINT: Vector3.ZERO,
		WheelState.TORQUE: 0.0,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.FRONT_RIGHT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: Vector3.ZERO,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IN_CONTACT: false,
		WheelState.CONTACT_POINT: Vector3.ZERO,
		WheelState.TORQUE: 0.0,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.REAR_LEFT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: Vector3.ZERO,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IN_CONTACT: false,
		WheelState.CONTACT_POINT: Vector3.ZERO,
		WheelState.TORQUE: 0.0,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.REAR_RIGHT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.LOAD: Vector3.ZERO,
		WheelState.FORCE: Vector3.ZERO,
		WheelState.IN_CONTACT: false,
		WheelState.CONTACT_POINT: Vector3.ZERO,
		WheelState.TORQUE: 0.0,
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
			WheelProperty.POSITION: Vector3(-track_width / 2.0, 0, -wheel_base / 2.0),
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
			WheelProperty.POSITION: Vector3(track_width / 2.0, 0, -wheel_base / 2.0),
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
			WheelProperty.POSITION: Vector3(-track_width / 2.0, 0, wheel_base / 2.0),
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
			WheelProperty.POSITION: Vector3(track_width / 2.0, 0, wheel_base / 2.0),
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

func simulate_suspensions(state, controller) -> void:
	var origin = state.transform.origin
	var x_basis = state.transform.basis.x
	var y_basis = state.transform.basis.y
	var z_basis = state.transform.basis.z

	for wheel in Wheel.values():
		#LGTM
		var offset = (
			x_basis * wheel_properties[wheel][WheelProperty.POSITION].x +
			z_basis * wheel_properties[wheel][WheelProperty.POSITION].z
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

		if not result:
			wheel_states[wheel][WheelState.IN_CONTACT] = false
			continue
		#LGTM
		var collision_point: Vector3 = result["position"]
		var rotation_radius: Vector3 = (
			collision_point - (origin + state.transform.basis * state.center_of_mass)
		)
		var contact_velocity: Vector3 = (
			state.linear_velocity + state.angular_velocity.cross(rotation_radius)
		)
		var suspension_load: Vector3 = calculate_suspension_load(
			cast_end - collision_point,             # Spring compression distance (state.step x)
			contact_velocity.project(y_basis),      # Vertical velocity component for damping
			wheel_properties[wheel][WheelProperty.SPRING_STIFFNESS],
			wheel_properties[wheel][WheelProperty.SHOCK_DAMPING]
		)

		if not suspension_load.dot(y_basis) > 0.0: # Spring is in compression
			continue

		wheel_states[wheel][WheelState.IN_CONTACT] = true

		wheel_states[wheel][WheelState.LOAD] = suspension_load
		wheel_states[wheel][RunningGear.WheelState.CONTACT_POINT] = collision_point - origin

		var wheel_steer_angle: float = (
			-controller.control_value[Controller.ControlValue.STEER] *
			wheel_properties[wheel][WheelProperty.MAX_STEER_ANGLE] *
			wheel_properties[wheel][WheelProperty.STEER_BIAS]
		)
		var wheel_direction: Vector3 = -z_basis.rotated(y_basis, wheel_steer_angle)

		var wheel_speed: float = (
			wheel_states[wheel][WheelState.ANGULAR_VELOCITY] *
			wheel_properties[wheel][WheelProperty.EFFECTIVE_RADIUS]
		)

		var free_rolling_speed: float = contact_velocity.dot(wheel_direction)
		var slip_ratio: float = 0.0

		# Slip ratio
		# TODO: Double check backwards logic
		if !is_zero_approx(free_rolling_speed):
			slip_ratio = (wheel_speed - free_rolling_speed) / abs(free_rolling_speed)
		elif !is_zero_approx(wheel_speed):
			slip_ratio = 2.0
		else:
			slip_ratio = 0.0

		var velocity_longitudinal = contact_velocity.dot(wheel_direction)
		var velocity_lateral = contact_velocity.dot(wheel_direction.rotated(y_basis, -PI/2.0))

		var slip_angle_gradient: float = 2.0

		# TODO: This might be a bug; I dont think this works going backwards
		if !is_zero_approx(velocity_longitudinal):
			slip_angle_gradient = velocity_lateral / velocity_longitudinal

		var normalized_slip_ratio: float = (
			longitudinal_stiffness *
			slip_ratio / (
				longitudinal_friction_coefficient *
				suspension_load.dot(y_basis)
			)
		)
		var normalized_slip_angle: float = (
			cornering_stiffness *
			slip_angle_gradient / (
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
		var combined_slip_scaling_factor: float		= (
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
			* combined_slip_scaling_factor
		)
		var normalized_longitudinal_force: float = (
			slip_ratio
			* combined_slip_scaling_factor
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

		var wheel_torque = longitudinal_force.dot(wheel_direction) * wheel_properties[wheel][WheelProperty.EFFECTIVE_RADIUS]

		wheel_states[wheel][WheelState.TORQUE] = wheel_torque

		wheel_states[wheel][WheelState.ANGULAR_VELOCITY] -= (
			wheel_torque
			/ wheel_properties[wheel][WheelProperty.INERTIA]
			* state.step
		)

func multiplier(combined_normalized_slip: float, mu_zero: float) -> float:
	var result: float = 1.0
	if abs(combined_normalized_slip) <= 2.0*PI:
		result = 0.5*(1.0 + mu_zero) - 0.5*(1.0 - mu_zero) * cos(combined_normalized_slip / 2.0)
	return result

func pacejka(x: float, b: float, c: float, d: float, e: float) -> float:
	return d * sin(c * atan(b * x - e * (b * x - atan(b * x))))
