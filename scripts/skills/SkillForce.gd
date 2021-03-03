extends Node

var default_force: Vector2
var axes: String
var replace: bool
var current_force: Vector2
var limit_force: Vector2
var variation: Vector2
var limit_reached: bool

func _init(data: Dictionary) -> void:
	axes = data.axes
	current_force = set_force(data.value)
	default_force = set_force(data.value)
	replace = data.replace
	if "limit_force" in data: limit_force = set_force(data.limit_force)
	if "variation" in data: variation = set_force(data.variation)

func reset() -> void: 
	current_force = default_force
	limit_reached = false

func set_force(value) -> Vector2:
	if axes in ["x", "y"]:
		var vector = Vector2.ZERO
		vector[axes] = value
		return vector
	else: return value

func apply(velocity: Vector2) -> Vector2:
	if axes == 'all': velocity = (Vector2.ZERO if replace else velocity) + current_force
	else: 
		velocity[axes] = 0 if replace else velocity[axes]
		velocity[axes] += current_force[axes]
	if variation :
		if current_force != limit_force: current_force -= variation
		else: limit_reached = true
	return velocity

func has_reach_limit() -> bool: return limit_reached
