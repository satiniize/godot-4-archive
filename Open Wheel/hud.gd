extends CanvasLayer

@onready var command_line: LineEdit = $Console/VBoxContainer/HBoxContainer/Command
@export var car: Car

func _process(delta):
	$Console/VBoxContainer/CommandHistory.text = "\n".join(Debug.log)
	if Input.is_action_just_pressed("console"):
		$Console.popup()
	$Label.text = "Engine RPM: %s" % snappedi(car.engine_angular_velocity / 0.1047, 100)
	$Label.text = "Engine RPM: %s" % (car.engine_angular_velocity / 0.1047)
	
	#$Label.text = "Engine Speed: %s" % car.engine_speed

func _on_command_text_submitted(new_text):
	Debug.parse_command(new_text)
	command_line.text = ""

func _on_submit_pressed():
	Debug.parse_command(command_line.text)
	command_line.text = ""
