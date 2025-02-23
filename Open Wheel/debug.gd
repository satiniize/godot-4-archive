extends Node

var current_car: Car
var log: PackedStringArray = ["~~~ idk what to put here ~~~"]

func add_log(message: String):
	var entry: String = "[" + Time.get_time_string_from_system() + "]"
	entry += " ~ "
	entry += message
	log.append(entry)

func parse_command(input: String):
	var argv: PackedStringArray = input.split(" ", false)
	var argc: int = argv.size()
	if argc != 0:
		match argv[0].to_lower():
			"showrgforces":
				pass
			"setaccel":
				var speed = float(argv[1])
				current_car.test_accel = speed
				add_log("Speed set to %s" % speed)
			"hitcar":
				if argc == 4:
					var x: float = float(argv[1])
					var y: float = float(argv[2])
					var z: float = float(argv[3])
					var impulse: Vector3 = Vector3(x, y, z)
					current_car.apply_impulse(impulse)
				else:
					add_log("Not enough parameters!")
			"timescale":
				if argc >= 2:
					Engine.set_time_scale(float(argv[1]))
				else:
					add_log("Not enough parameters!")
			_:
				add_log("Unknown command \"%s\"" % argv[0])
