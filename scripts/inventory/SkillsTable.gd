extends Node

const Character = preload("res://scripts/object/characters/Character.gd")

var character: Character

var params := {
	"walk": {
		"activated": true,
		"in_use": false,
		"force": 400
	},
	"run": {
		"activated": true,
		"in_use": false,
		"force": 2
	},
	"jump": {
		"activated": true,
		"interrupted": false,
		"in_use": false,
		"force":  -700,
		"launched": false,
		"left": 2,
		"max_use": 2,
		"block": ["melee"]
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
		"fuel": 30,
		"base_fuel": 30,
		"state_displayed": true,
		"block": ["jump", "wall_jump", "melee", "shoot"]
	},
	"melee": {
		"activated": true,
		"in_use": false,
		"block": ["shoot"],
		"priority": true
	},
	"shoot": {
		"activated": true,
		"in_use": false,
		"delay": .5,
		"counter": 0,
		"block": ["melee"],
		"priority": true
	},
	"wall_hook": {
		"activated": true,
		"in_use": false,
		"block": ["run", "jump", "melee", "jetpack"]
	},
	"wall_climb": {
		"activated": true,
		"in_use": false,
		"block": ["shoot"],
		"force" : 150
	},
	"wall_lower": {
		"activated": true,
		"in_use": false,
		"block": ["shoot"],
		"force" : 150
	},
	"wall_climb_finish": {
		"in_use": false,
		"block": ["all", "wall_hook"],
		"force": Vector2(-200, 200)
	}
}

func _init(character_ref: Character) -> void: character = character_ref

func _process(delta: float) -> void:
	if !params.jetpack.in_use && params.jetpack.fuel < params.jetpack.base_fuel : params.jetpack.fuel += 0.1
	
func activate_skill(skill: String) -> void:
	params[skill].activated = true
	character.displayed_state.push_back(skill)


func can_do_action(action: String) -> bool: return !action_is_blocked(action) && self.call("can_" + action)

func action_is_blocked(action: String) -> bool:
	for key in params:
		if "block" in params[key]:
			var allBlocked = 'all' in params[key].block
			if (allBlocked && !action in params[key].block) || (!allBlocked && action in params[key].block):
				if params[key].in_use:
					params[action].in_use = false
					return true
	return false
	
### MOVE

# WALK
func can_walk() -> bool: return params.walk.activated
	
func is_walking() -> bool: return params.walk.in_use

func start_walking() -> void: params.walk.in_use = true

func walk() -> float: return params.walk.force * (params.run.force if is_running() else 1)

func stop_walking() -> void: params.walk.in_use = false

# RUN
func can_run() -> bool: return params.walk.activated && is_walking() && (!is_jumping() || params.run.in_use)

func is_running() -> bool: return params.run.in_use

func start_running() -> void: params.run.in_use = true

func stop_running() -> void: params.run.in_use = false


### JUMP
func can_jump() -> bool:
	return params.jump.activated && (can_first_jump() || can_more_jumps() || can_wall_jump())

func can_first_jump() -> bool: return character.is_on_floor()

func can_more_jumps() -> bool:
	if params.jump.left > 0:
		if params.jump.left < params.jump.max_use: return true
		elif params.jump.left > 1:
			params.jump.left -= 1
			return true
	return false

func can_wall_jump() -> bool: return params.wall_jump.activated && !character.is_on_floor() && character.is_on_wall()

func start_jumping() -> void:
	character.fall_time = 0
	params.jump.in_use = true
	params.jump.launched = false
	params.jump.interrupted = false
	params.wall_jump.launched = false
	params.jump.left -= 1

func is_jumping() -> bool: return params.jump.in_use

func jump() -> Vector2:
	if !params.jump.launched:
		params.jump.launched = true
		if can_wall_jump(): return Vector2(launch_wall_jump(), params.jump.force)
		return Vector2(character.velocity.x, params.jump.force)
	else:
		var vectorX: float
		if params.wall_jump.launched:
			if is_jetpacking(): params.wall_jump.launched = false
			vectorX = params.wall_jump.force * params.wall_jump.direction
		else: vectorX = character.velocity.x
		if !params.jump.interrupted: return Vector2(vectorX, character.velocity.y - character.weight)
		else: return Vector2(vectorX, character.velocity.y)

func launch_wall_jump() -> float:
	params.wall_jump.direction = -1 if character.face_off else 1
	params.wall_jump.launched = true
	params.jump.left = params.jump.max_use - 1
	return params.wall_jump.force

func interrupt_jump() -> void: params.jump.interrupted = true

func jump_ended() -> bool: return params.jump.launched && character.is_on_floor()

func stop_jumping() -> void:
	params.jump.in_use = false
	params.jump.left = params.jump.max_use


### JETPACK
func activate_jetpack_ability() -> void: params.jetpack.activated = true

func is_jetpacking() -> bool: return params.jetpack.activated && (params.jetpack.in_use || refill_jetpack_fuel())

func refill_jetpack_fuel() -> void: if params.jetpack.fuel < params.jetpack.base_fuel : params.jetpack.fuel += .1

func get_jetpack_current_fuel() -> float: return params.jetpack.fuel

func start_jetpacking() -> void: params.jetpack.in_use = true

func can_jetpack() -> bool: return params.jetpack.activated && params.jetpack.fuel > 0

func jetpacking() -> Vector2:
	params.jetpack.fuel -= 0.4
	if params.jetpack.fuel <= 0: params.jetpack.in_use = false
	var x = params.jetpack.force.x * (1 if params.jetpack.fuel > 10 else params.jetpack.fuel / 10)
	return Vector2(x, params.jetpack.force.y)

func stop_jetpacking() -> void: params.jetpack.in_use = false


# MELEE
func can_melee() -> bool: return params.melee.activated && !params.melee.in_use && !action_is_blocked("melee")

func is_meleeing() -> bool: return params.melee.in_use

func start_meleeing() -> void: params.melee.in_use = true

func stop_meleeing() -> void: params.melee.in_use = false


# SHOOT
func can_shoot() -> bool: return params.shoot.activated && !action_is_blocked("shoot")

func is_shooting() -> bool: return params.shoot.activated && params.shoot.in_use

func start_shooting() -> void: params.shoot.in_use = true

func shooting() -> bool:
	if params.shoot.counter <= 0:
		params.shoot.counter = params.shoot.delay
		return true
	else:
		params.shoot.counter -= 0.025
		return false

func stop_shooting() -> void:
	params.shoot.counter = 0
	params.shoot.in_use = false


### WALL CLIMB
func can_wall_hook() -> bool:
	var active: bool = params.wall_hook.activated
	var not_on_floor_and_on_wall := !character.is_on_floor() && character.is_on_wall()
	var collider_ok := !character.bottom_back.is_colliding() && character.bottom_front.is_colliding()
	return active && not_on_floor_and_on_wall && collider_ok

func start_wall_hooking() -> void:
	params.wall_hook.in_use = true
	stop_jetpacking()

func is_wall_hooking() -> bool: return params.wall_hook.in_use

func wall_hook() -> Vector2:
	character.fall_time = 0
	var y = character.GRAVITY * character.fall_time
	var vector = Vector2(0, -y)
	if is_wall_climbing(): vector.y -= params.wall_climb.force
	elif is_finishing_climbing(): vector -= params.wall_climb_finish.force
	elif is_wall_lowering() : vector.y += params.wall_lower.force
	return vector

func stop_wall_hooking() -> void: params.wall_hook.in_use = false

func can_wall_climb() -> bool:  return params.wall_climb.activated && is_wall_hooking()

func is_wall_climbing() -> bool: return params.wall_climb.in_use

func start_wall_climbing() -> void: params.wall_climb.in_use = true

func stop_wall_climbing() -> void: params.wall_climb.in_use = false

func finish_wall_climbing() -> void: 
	params.wall_climb_finish.in_use = true
	character.switch_collision(true)


func is_finishing_climbing() -> bool: return params.wall_climb_finish.in_use  

func stop_wall_climb_finish() -> void: 
	character.switch_collision(false)
	params.wall_climb_finish.in_use = false

func can_wall_lower() -> bool:  return params.wall_lower.activated && is_wall_hooking()

func is_wall_lowering() -> bool: return params.wall_lower.in_use

func start_wall_lowering() -> void: params.wall_lower.in_use = true

func stop_wall_lowering() -> void: params.wall_lower.in_use = false

func finish_wall_lowering() -> Vector2: return Vector2(-40, 0)
