extends Controller

enum InputState{
	ACCELERATE,
	BRAKE,
	CLUTCH,
	STEER_LEFT,
	STEER_RIGHT
}

var input_state: Dictionary = {
	InputState.ACCELERATE: false,
	InputState.BRAKE: false,
	InputState.CLUTCH: false,
	InputState.STEER_LEFT: false,
	InputState.STEER_RIGHT: false,
}

var steer_speed: float = 4.0
var accelerate_speed: float = 4.0
var brake_speed: float = 4.0
var clutch_speed: float = 4.0

func _unhandled_input(event):
	poll_input(event, "accelerate", InputState.ACCELERATE)
	poll_input(event, "brake", InputState.BRAKE)
	poll_input(event, "steer_left", InputState.STEER_LEFT)
	poll_input(event, "steer_right", InputState.STEER_RIGHT)
	poll_input(event, "clutch", InputState.CLUTCH)

func poll_input(event: InputEvent, action: String, input: InputState):
	if event.is_action_pressed(action):
		input_state[input] = true
	elif event.is_action_released(action):
		input_state[input] = false

func poll_discrete_input():
	pass

func _physics_process(delta):
	var target_steer: float = (
		float(input_state[InputState.STEER_RIGHT]) - 
		float(input_state[InputState.STEER_LEFT])
	)
	control_value[ControlValue.STEER] = move_toward(
		control_value[ControlValue.STEER],
		target_steer,
		steer_speed * delta
	)

	var target_accelerate: float = bool(input_state[InputState.ACCELERATE])
	control_value[ControlValue.ACCELERATE] = move_toward(
		control_value[ControlValue.ACCELERATE],
		target_accelerate,
		accelerate_speed * delta
	)
	
	var target_brake: float = bool(input_state[InputState.BRAKE])
	control_value[ControlValue.BRAKE] = move_toward(
		control_value[ControlValue.BRAKE],
		target_brake,
		brake_speed * delta
	)

	var target_clutch: float = bool(input_state[InputState.CLUTCH])
	control_value[ControlValue.CLUTCH] = move_toward(
		control_value[ControlValue.CLUTCH],
		target_clutch,
		clutch_speed * delta
	)
#func move_to(value: float, target_value: float, step: float):
	#var difference: float = target_value - value
	#if abs(difference) > step:
		#return value + sign(difference) * step
	#else:
		#return target_value
