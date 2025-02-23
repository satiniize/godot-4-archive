extends Node3D

var prev_inverse_distance: float = 0.0
var inverse_distance: float = 0.0 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var speed: float = 32.0
	var prev_distance = ($Car.transform.origin - $Path3D/PathFollow3D.transform.origin).length()
	$Path3D/PathFollow3D.progress += speed * delta
	var distance = ($Car.transform.origin - $Path3D/PathFollow3D.transform.origin).length()
	if (prev_distance > distance):
		pass
	else:
		$Path3D/PathFollow3D.progress -= speed * delta
		$Path3D/PathFollow3D.progress -= speed * delta
		distance = ($Car.transform.origin - $Path3D/PathFollow3D.transform.origin).length()
		if (prev_distance > distance):
			pass
		else:
			$Path3D/PathFollow3D.progress += speed * delta
