extends Node

const GravityObject = preload("res://scripts/object/GravityObject.gd")

var object: GravityObject

var params := {
	"move": {
		"activated": true,
		"in_use": false,
		"force": 400,
	},
	"jump": {
		"activated": true,
		"interrupted": false,
		"force":  -700,
		"launched": false,
		"left": 2,
		"max_use": 2
	},
	"wall_jump": {
		"activated": true,
		"launched": true,
		"force": 500,
		"direction": 1
	},
	"jetpack": {
		"activated": false, 
		"force": Vector2(900, -200), 
		"in_use": false, 
		"fuel": 100, 
		"base_fuel": 100
	}
}

func _init(object_ref: GravityObject) -> void: object = object_ref

func _process(delta: float) -> void:
	if !params.jetpack.in_use && params.jetpack.fuel < params.jetpack.base_fuel : params.jetpack.fuel += 0.1

### MOVE
func is_moving() -> bool: return params.move.in_use

func start_moving() -> void: params.move.in_use = true

func move() -> float: return params.move.force

func stop_moving() -> void: params.move.in_use = false


### JUMP
func can_jump() -> bool:
	return params.jump.activated && (can_first_jump() || can_more_jumps() || can_wall_jump())

func can_first_jump() -> bool: return object.is_on_floor()

func can_more_jumps() -> bool:
	if params.jump.left > 0:
		if params.jump.left < params.jump.max_use: return true
		elif params.jump.left > 1:
			params.jump.left -= 1
			return true
	return false

func can_wall_jump() -> bool: return params.wall_jump.activated && !object.is_on_floor() && object.is_on_wall()

func start_jumping() -> void:
	object.fall_time = 0
	params.jump.launched = false
	params.jump.interrupted = false
	params.wall_jump.launched = false
	params.jump.left -= 1

func is_jumping() -> bool: return params.jump.left < params.jump.max_use

func jump() -> Vector2:
	if !params.jump.launched:
		params.jump.launched = true
		if can_wall_jump(): return Vector2(launch_wall_jump(), params.jump.force)
		return Vector2(object.velocity.x, params.jump.force)
	else: 
		var vectorX: float
		if params.wall_jump.launched: 
			vectorX = params.wall_jump.force * params.wall_jump.direction
		else: vectorX = object.velocity.x
		if !params.jump.interrupted: return Vector2(vectorX, object.velocity.y - object.weight)
		else: return Vector2(vectorX, object.velocity.y)

func launch_wall_jump() -> float:
	params.wall_jump.direction = -1 if object.face_off else 1
	params.wall_jump.launched = true
	params.jump.left = params.jump.max_use - 1
	return params.wall_jump.force

func interrupt_jump() -> void: params.jump.interrupted = true

func jump_ended() -> bool: return params.jump.launched && object.is_on_floor()

func stop_jumping() -> void: params.jump.left = params.jump.max_use


### JETPACK
func activate_jetpack_ability() -> void: params.jetpack.activated = true

func is_jetpacking() -> bool: return params.jetpack.activated && (params.jetpack.in_use || refill_jetpack_fuel())

func refill_jetpack_fuel() -> void: if params.jetpack.fuel < params.jetpack.base_fuel : params.jetpack.fuel += .1

func get_jetpack_current_fuel() -> float: return params.jetpack.fuel

func start_jetpacking() -> void: params.jetpack.in_use = true

func can_jetpacking() -> bool: return params.jetpack.activated && params.jetpack.fuel > 0

func jetpacking() -> Vector2:
	params.jetpack.fuel -= 0.4
	if params.jetpack.fuel <= 0: params.jetpack.in_use = false
	var x = params.jetpack.force.x * (1 if params.jetpack.fuel > 10 else params.jetpack.fuel / 10)
	return Vector2(x, params.jetpack.force.y)

func stop_jetpacking() -> void: params.jetpack.in_use = false
