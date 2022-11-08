extends KinematicBody2D

var _velocity := Vector2.ZERO

onready var icon = $PlayerIcon

export var _jump_height : float
export var _jump_time_to_peak : float
export var _jump_time_to_descent : float

onready var _jump_velocity : float = ((2.0 * _jump_height) / _jump_time_to_peak) * -1.0
onready var _jump_gravity : float = ((-2.0 * _jump_height) / (_jump_time_to_peak * _jump_time_to_peak)) * -1.0
onready var _fall_gravity : float = ((-2.0 * _jump_height) / (_jump_time_to_descent * _jump_time_to_descent)) * -1.0

var _is_ground : bool = false
var _ground_height = 0

func get_gravity() -> float:
	return _jump_gravity if _velocity.y < 0.0 else _fall_gravity

func jump():
	if _is_ground:
		print("icon_jump")
		_velocity.y = _jump_velocity
		_is_ground = false
	
func _physics_process(delta):
	if !_is_ground:
		_velocity.y += get_gravity() * delta
	check_ground()
	_velocity = move_and_slide(_velocity, Vector2.UP)

func check_ground():
	if position.y >= _ground_height + 0.1 and !_is_ground:
		_is_ground = true
		_velocity.y = 0
		position.y = 0
	pass

func get_is_ground():
	return _is_ground
	
func update_ground_height(set_ground_height):
	_ground_height = set_ground_height
	
func set_jump_height(value):
	_jump_height = value
	
func set_jump_time_to_peak(value):
	_jump_time_to_peak = value
	
func set_jump_time_to_descent(value):
	_jump_time_to_descent = value
