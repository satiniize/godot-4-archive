extends CharacterBody3D

#Movement variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_ground_speed: float = 10.0
var max_air_speed: float = 10.0
var ground_accel: float = 32.0
var air_accel: float = 4.0

#Camera variables
var bob_phase_angle: float = 0.0
var camera_rotation: Vector2	= Vector2.ZERO
var camera_recoil: Vector2		= Vector2.ZERO

#Weapon variables
var weapon_cooldown: float = 0.0
var active_weapon: int = 0
var weapon_held_down

@export var inventory: Dictionary


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	inventory[0] = Bioweapon.new()


func _physics_process(delta) -> void:
	move(delta)
	look()
	shoot(delta)


func move(delta: float) -> void:
	var on_floor: bool = is_on_floor()
	
	var look_basis: Basis		= transform.basis
	var move_direction: Vector3	= Vector3.ZERO
	
	move_direction += -look_basis.z * Input.get_axis("move_backward", "move_forward")
	move_direction += look_basis.x * Input.get_axis("move_left", "move_right")
	move_direction = move_direction.normalized()
	
	var target_velocity: Vector3 = Vector3.ZERO
	if on_floor:
		target_velocity = move_direction * max_ground_speed
	else:
		target_velocity = move_direction * max_air_speed
	
	var projected_velocity: Vector3	= Plane.PLANE_XZ.project(velocity)
	var velocity_delta: Vector3		= target_velocity - projected_velocity
	var speed_delta: float			= velocity_delta.length()
	
	var accel: float = 0.0
	if on_floor:
		accel = min(ground_accel * delta, speed_delta)
	else:
		accel = min(air_accel * delta, speed_delta)
	
	if not is_zero_approx(speed_delta): #Might cause floating point issues, causing giant spikes
		velocity += velocity_delta / speed_delta * accel
	
	if Input.is_action_pressed("move_jump") and on_floor:
		velocity += Vector3.UP * 8.0
	else:
		velocity += Vector3.DOWN * gravity * delta
	
	move_and_slide()
	
	#TODO: possibly change velocity.length() to other function
	bob_phase_angle += projected_velocity.dot(projected_velocity) * delta * 0.1
	bob_phase_angle = fmod(bob_phase_angle, 2.0*PI)


func look() -> void:
	var y_rotation_basis	= Basis.IDENTITY.rotated(Vector3.UP, camera_rotation.y + camera_recoil.y)
	var x_rotation_basis	= Basis.IDENTITY.rotated(Vector3.RIGHT, camera_rotation.x + camera_recoil.x)
	
	transform.basis			= y_rotation_basis
	$Head.transform.basis	= x_rotation_basis
	
	$Head/Camera3D.transform.origin.x = sin(bob_phase_angle) * 0.08
	$Head/Camera3D.transform.origin.y = abs(cos(bob_phase_angle)) * 0.08
	$Head/Camera3D.rotation.z = -0.008 * velocity.dot(y_rotation_basis.x) + sin(bob_phase_angle) * 0.01


func shoot(delta: float) -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var origin: Vector3 = global_transform.origin
	var target: Vector3 = origin + $Head.global_transform.basis.z * 100.0
	
	var parameters: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, target)
	
	var result: Dictionary = space_state.intersect_ray(parameters)
	
	if result:
		pass
	
	weapon_cooldown -= delta
	if Input.is_action_pressed("weapon_shoot"):
		if weapon_cooldown <= 0.0:
			weapon_cooldown += inventory[0].phenotype[Bioweapon.Phenotype.REFRACTORY_PERIOD] #refractory period
			camera_recoil.x += 0.05 #recoil
			camera_recoil.y += randf_range(-camera_recoil.x, camera_recoil.x)
	elif Input.is_action_pressed("weapon_special"):
		pass
	elif weapon_cooldown <= 0.0:
		weapon_cooldown = 0.0
	
	camera_recoil *= exp(-delta * 2.0) #recoil decay
	
	$Head/Sprite3D.transform.origin.z = -1.0 + camera_recoil.length()*camera_recoil.length() * 8.0
	$Head/Sprite3D.transform.origin.y = -0.15 + camera_recoil.length()*camera_recoil.length() * 2.0
	$Head/Sprite3D.rotation.z = camera_recoil.length()*camera_recoil.length() * -8.0


func _input(event) -> void:
	if event is InputEventMouseMotion:
		camera_rotation.y += -px_to_rad(event.relative.x)
		camera_rotation.x += -px_to_rad(event.relative.y)


func px_to_rad(pixels : float) -> float:
	var sensitivity: float = 20.8
	var dpi: float = 1000.0
	return pixels / (dpi / 2.54) / sensitivity * PI * 2.0
