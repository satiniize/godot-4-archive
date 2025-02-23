class_name Car

extends RigidBody3D

@export var controller: Controller

@export_group("Tire Model")
@export var longitudinal_friction_coefficient: float = 1.2
@export var lateral_friction_coefficient: float = 1.2
@export var longitudinal_stiffness: float = 24000.0
@export var cornering_stiffness: float = 24000.0
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
@export var engine_inertia: float = 0.65

@export_group("Transmission Specs")
@export_subgroup("Gearing")
@export var final_drive: float = 4.26
@export var gear_ratios: Array[float] = [
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
#Springs
@export var front_spring_stiffness: float = 60000
@export var rear_spring_stiffness: float = 80000
#Shocks -> should change so damping changes (ie. rebound and bump stiffness)
@export var front_shock_damping: float = 6000
@export var rear_shock_damping: float = 8000
#Ride height
@export var front_ride_height: float = 0.2 ##How high the front raycast is from the ground
@export var rear_ride_height: float = 0.2 ##How high the rear raycast is from the ground

@export_subgroup("Alignment")
#Camber
@export var front_camber: float
@export var rear_camber: float
#Toe
@export var front_toe: float
@export var rear_toe: float
#Caster
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
#Front wheel
@export var front_rim_size: float
@export var front_tire_width: float
@export_range(0.0, 100.0) var front_tire_profile
@export var front_wheel_inertia: float = 0.4 
@export var front_tire_pressure: float
#Rear Wheel
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
var current_gear: int = 0
var differential_angular_velocity: float = 0.0
var transmission_inertia: float = 1.0
#^^^ positive means a forward sum velocity of the wheels
# Wheel Attributes
enum Wheel{
	FRONT_LEFT,
	FRONT_RIGHT,
	REAR_LEFT,
	REAR_RIGHT
}

enum WheelState{
	ANGULAR_VELOCITY,
	LOAD,
	IS_SLIPPING,
}
var wheel_states: Dictionary = {
	Wheel.FRONT_LEFT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.FRONT_RIGHT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.REAR_LEFT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
		WheelState.IS_SLIPPING: false,
	},
	Wheel.REAR_RIGHT: {
		WheelState.ANGULAR_VELOCITY: 0.0,
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
	update_wheel_properties()
	Debug.current_car = self
	
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
	#$BumperCamera.transform.origin.y = 0.5 + randf_range(-0.05, 0.05)
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


#read the book again bruh
#1. basic wheel dynamics (has to be general) -> kindof completed
#2. camber force
func _integrate_forces(state) -> void:
	var applied_clutch: float = (
		clutch_torque_capacity *
		(1.0 - controller.control_value[Controller.ControlValue.CLUTCH])
	)
	
	#VVV this should be changed to mass flow rate model
	var target_engine_speed: float = idle_speed + (upper_redline - idle_speed) * controller.control_value[Controller.ControlValue.ACCELERATE]
	
	var engine_torque: float
	if engine_angular_velocity < target_engine_speed:
		engine_torque = peak_torque * torque_curve.sample(engine_angular_velocity / upper_redline)
	#Shitty engine braking, please overhaul
	else:
		engine_torque = -peak_torque * torque_curve.sample(engine_angular_velocity / upper_redline)
	
	#this probably should take place at the end
	var engine_angular_acceleration: float = (
		engine_torque /
		engine_inertia
	)
	engine_angular_velocity += (
		engine_angular_acceleration *
		state.step
	)
	
	if engine_torque > applied_clutch:
		engine_torque = applied_clutch
	
	var total_gear_ratio = final_drive * gear_ratios[current_gear]
	
	var engine_differential_speed_difference: float = (
		engine_angular_velocity - 
		differential_angular_velocity * total_gear_ratio
	)
	
	###Im not sure if this actually even works so please check
	var clutch_impulse: float = applied_clutch * state.step
	var engine_impulse = (
		sign(engine_differential_speed_difference) *
		applied_clutch *
		state.step
	)
	var differential_impulse = (
		sign(engine_differential_speed_difference) *
		applied_clutch * total_gear_ratio * 
		state.step
	)
	
	engine_angular_velocity -= engine_impulse / engine_inertia
	differential_angular_velocity += differential_impulse / transmission_inertia
	var differential_load: float = 0.0
	#Get directions
	var origin = state.transform.origin
	var x_axis = state.transform.basis.x
	var y_axis = state.transform.basis.y
	var z_axis = state.transform.basis.z
	for wheel in Wheel.values():
		#Get position of wheels
		var offset = (
			x_axis * wheel_properties[wheel][WheelProperty.POSITION].x * track_width / 2.0 +
			z_axis * wheel_properties[wheel][WheelProperty.POSITION].z * wheel_base / 2.0
		)
		#Suspension ray casting
		var margin = 0.04
		var cast_origin = (origin + offset) + (y_axis * margin)
		var cast_end = (
			cast_origin +
			-y_axis * (
				wheel_properties[wheel][WheelProperty.RIDE_HEIGHT] +
				margin
			)
		)
		var space_state: PhysicsDirectSpaceState3D = state.get_space_state()
		var query = PhysicsRayQueryParameters3D.create(cast_origin, cast_end, 0x01)
		var result = space_state.intersect_ray(query)
		if result:
			#SPRINGS AND SHOCKS
			var collision_point: Vector3 = result["position"]
			var rotation_radius: Vector3 = (
				collision_point - (origin + state.center_of_mass)
			)
			var contact_velocity: Vector3 = (
				state.linear_velocity + state.angular_velocity.cross(rotation_radius)
			)
			var spring_force: Vector3 = (
				wheel_properties[wheel][WheelProperty.SPRING_STIFFNESS] * 
				-(cast_end - collision_point)
			)
			var shock_force: Vector3 = (
				wheel_properties[wheel][WheelProperty.SHOCK_DAMPING] * 
				-contact_velocity.project(y_axis)
			)
			var load: Vector3 = spring_force + shock_force
			#SPRINGS AND SHOCKS
			#Check if wheel is in load
			if load.dot(y_axis) > 0.0:
				#Apply spring force
				state.apply_force(load, collision_point - origin)
				
				#Wheel properties
				var wheel_steer_angle: float = (
					-controller.control_value[Controller.ControlValue.STEER] *
					wheel_properties[wheel][WheelProperty.MAX_STEER_ANGLE] *
					wheel_properties[wheel][WheelProperty.STEER_BIAS]
				)
				var wheel_direction: Vector3 = -z_axis.rotated(y_axis, wheel_steer_angle)
				#THIS SHOULD BE REPLACED BY DIFFERENTIAL MODELS
				#ie Diff_speed = wheel1_speed + wheel2_speed
				#for now this is a locked diff
				if wheel_properties[wheel][WheelProperty.DRIVEN]:
					wheel_states[wheel][WheelState.ANGULAR_VELOCITY] = differential_angular_velocity
				
				var wheel_speed: float = (
					wheel_states[wheel][WheelState.ANGULAR_VELOCITY] *
					wheel_properties[wheel][WheelProperty.EFFECTIVE_RADIUS]
				)

				var free_rolling_speed: float = contact_velocity.dot(wheel_direction)
				#SLIP RATIO
				#Honestly should probably revert back to SAE definition
				var slip_ratio: float = 0.0
				#if !is_zero_approx(wheel_speed) or !is_zero_approx(free_rolling_speed):
				if !is_zero_approx(free_rolling_speed):
					#should be w*r / V - 1
					#var denominator: float = max(abs(wheel_speed), abs(free_rolling_speed))
					var denominator: float = abs(free_rolling_speed)
					slip_ratio = (wheel_speed - free_rolling_speed) / denominator
				elif !is_zero_approx(wheel_speed):
					slip_ratio = 99.0
				else:
					slip_ratio = 0.0
				#SLIP ANGLE
				var slip_angle: float = 0.0
				if !is_zero_approx(
					contact_velocity.dot(wheel_direction.rotated(y_axis, PI/2.0))
				):
					slip_angle = wheel_direction.signed_angle_to(contact_velocity, y_axis) / PI
				#NORMALIZED SLIP
				var normalized_slip_ratio: float = (
					longitudinal_stiffness * 
					slip_ratio / (
						longitudinal_friction_coefficient *
						load.dot(y_axis)
					)
				)
				var normalized_slip_angle: float = (
					cornering_stiffness *
					tan(slip_angle) / (
						lateral_friction_coefficient *
						load.dot(y_axis)
					)
				)
				#COMBINED SLIP CONDITION
				var normalized_combined_slip: float = (
					sqrt(
						normalized_slip_ratio*normalized_slip_ratio +
						normalized_slip_angle*normalized_slip_angle
					)
				)
				#MAGIC
				var mu_zero: float = (
					cornering_stiffness *
					longitudinal_friction_coefficient / (
						longitudinal_stiffness *
						lateral_friction_coefficient
					)
				)
				var multiplier_value: float = multiplier(normalized_combined_slip, mu_zero)
				var slip_angle_gradient: float = tan(slip_angle)
				var pacejka_value: float = pacejka(normalized_combined_slip, pacejka_b, pacejka_c, pacejka_d, pacejka_e)
				var magic_denominator: float = sqrt(
					slip_ratio*slip_ratio + 
					multiplier_value*multiplier_value *
					slip_angle_gradient*slip_angle_gradient
				)
				if is_zero_approx(magic_denominator):
					magic_denominator = 0.04
				#NORMALIZED FORCES, IN FLOATS RANGING FROM idk???
				var normalized_lateral_force: float = (
					pacejka_value *
					multiplier_value *
					slip_angle_gradient /
					magic_denominator
				)
				var normalized_longitudinal_force: float = (
					pacejka_value *
					slip_ratio /
					magic_denominator
				)
				#FORCES
				var longitudinal_force: Vector3 = (
					wheel_direction *
					load.dot(y_axis) *
					longitudinal_friction_coefficient *
					normalized_longitudinal_force
				)
				var lateral_force: Vector3 = (
					wheel_direction.rotated(y_axis, -PI/2.0) *
					load.dot(y_axis) *
					lateral_friction_coefficient *
					normalized_lateral_force
				)
				var total_contact_force = longitudinal_force + lateral_force
				state.apply_force(total_contact_force, collision_point - origin)
				var wheel_angular_acceleration = (
					longitudinal_force.dot(wheel_direction) *
					wheel_properties[wheel][WheelProperty.EFFECTIVE_RADIUS] /
					wheel_properties[wheel][WheelProperty.INERTIA]
				)
				if wheel_properties[wheel][WheelProperty.DRIVEN]:
					differential_load -= (
						wheel_angular_acceleration *
						state.step
					)
				else:
					wheel_states[wheel][WheelState.ANGULAR_VELOCITY] -= (
						wheel_angular_acceleration *
						state.step
					)
	differential_angular_velocity += differential_load

func multiplier(combined_normalized_slip: float, mu_zero: float) -> float:
	var result: float = 1.0
	if abs(combined_normalized_slip) <= 2.0*PI:
		result = 0.5*(1.0 + mu_zero) - 0.5*(1.0 - mu_zero) * cos(combined_normalized_slip / 2.0)
	return result

func pacejka(x: float, b: float, c: float, d: float, e: float) -> float:
	return d * sin(c * atan(b * x - e * (b * x - atan(b * x))))



#func _physics_process(delta):


func _on_follow_camera_reset_timeout():
	follow_camera_start_align = true
