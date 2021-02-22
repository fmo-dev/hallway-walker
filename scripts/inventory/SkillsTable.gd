extends Node

const Character = preload("res://scripts/object/characters/Character.gd")

var character: Character

var skills := {
	"move": {
		"activated": true,
		"in_use": false,
		"force": Vector2(200,0),
		"change": "x",
		"replace": true
	},
	"up": {
		"activated": true,
		"need": ["climb"],
		"in_use": false,
		"force": Vector2(0,-60),
		"change": "y",
		"replace": true
	},
	"down": {
		"activated": true,
		"need": ["climb"],
		"in_use": false,
		"force": Vector2(0, 60),
		"change": "y",
		"replace": true
	},
	"run": {
		"activated": true,
		"in_use": false,
		"conditions": ["on_floor"],
		"need": ["move"],
		"replace_actions": ["move"],
		"force": Vector2(400,0),
		"change": "x",
		"replace": true
	},
	"jump": {
		"activated": true,
		"in_use": false,
		"available": 2,
		"max": 2,
		"instant_active": false,
		"conditions": ["on_floor_or_one_less_and_available"],
		"block": ["attack_melee"],
		"launch": {
			"force": Vector2(0, -400),
			"event": ["reinit_fall_time", "one_less_if_from_falling"],
			"change": "y",
			"replace": true,
			"launched": false
		},
		"force": Vector2(0, -30),
		"force_stop": false,
		"change": "y",
		"other_actions": ["wall_jump"],
		"replace": false,
		"stop_conditions": ["on_floor"],
		#"finish_animation": true
	},
	"wall_jump": {
		"activated": true,
		"in_use": false,
		"launch": {
			"force": Vector2(350, -300),
			"change": "all",
			"replace": true,
			"event": ["reinit_fall_time", "inverse_move_direction", "one_less_jump_than_max"],
			"launched": false
		},
		"force": Vector2(100, -30),
		"change": "all",
		"block": ["move"],
		"conditions": ["not_on_floor", "on_wall"],
		"stop_conditions": ["on_floor"],
		"stop_event": ["synchronize_move_direction"],
		"replace": false
	},
	"dash": {
		"activated": true,
		"in_use": false,
		"instant_active": false,
		"launch": {
			"force": Vector2(5000, 0),
			"change": "x",
			"replace": true
		},
		"force": Vector2.ZERO,
		"change": "x",
		"replace": false
	},
	"climb": {
		"activated": true,
		"in_use": false,
		"block": ["run", "jump", "attack_melee", "dash"],
		"force": Vector2(5, 5),
		"event": ["reinit_fall_time"],
		"conditions": ["not_on_floor", "on_wall"],
		"stop_conditions": ["on_floor", "not_on_wall"],
		"change": "all",
		"replace": true
	},
	"attack_melee": {
		"activated": false,
		"in_use": false
	},
	"attack_distance": {
		"activated": false,
		"in_use": false
	}
}

func _init(character_ref: Character) -> void: character = character_ref

func is_instant_action(action: String) -> bool:
	if "instant_active" in skills[action]:
		if check_other_actions(action, true) || can_do_action(action, true):
			skills[action].instant_active = true
			skills[action].in_use = false
			if "launch" in skills[action]:
				skills[action].launch.launched = false
			return true
	return false

func check_other_actions(action: String, restart: bool = false) -> String:
	if "other_actions" in skills[action]:
		for other_action in skills[action].other_actions:
			if can_do_action(other_action, restart): return other_action
	return ""
	
func can_do_action(action: String, restart: bool = false) -> bool:
	if !restart:
		if skills[action].in_use : return true
		if "instant_active" in skills[action] && !skills[action].instant_active: return false
	if check_if_action_in_array("block", action): return false
	if "conditions" in skills[action]: 
		for condition in skills[action].conditions:
			if !self.call(condition, action): return false
	return action_is_allowed(action)


func other_in_progress(action: String) -> String:
	if "other_actions" in skills[action]:
		for other_action in skills[action].other_actions:
			if skills[other_action].in_use: return other_action
	return ""

func action_is_allowed(action: String) -> bool:
	if "need" in skills[action]: for key in skills[action].need: if !skills[key].in_use: return false
	return skills[action].activated

func action_launched(action: String) -> bool:
	if "launch" in skills[action]: return skills[action].launch.launched
	else: return false

func stop_action(action: String) -> void:
	if "instant_active" in skills[action]: skills[action].instant_active = false
	skills[action].in_use = false
	if "max" in skills[action]: skills[action].available = skills[action].max
	for skill in skills:
		if "need" in skills[skill] && action in skills[skill].need: stop_action(skill)
	if "stop_event" in skills[action]:
		for event in skills[action].stop_event: self.call(event, action)

func check_stop_condition(action: String) -> bool:
	if "force_stop" in skills[action]: skills[action].force_stop = true
	if "stop_conditions" in skills[action]: 
		for condition in skills[action].stop_conditions:
			if !self.call(condition, action): 
				character.set_pending_action(action)
				return false
	return true

func check_if_action_stopped(action: String) -> bool:
	if skills[action].in_use:
		if "stop_conditions" in skills[action]:
			for condition in skills[action].stop_conditions:
				if self.call(condition, action): return true
			return false
	return false

func is_doing_action(action: String) -> bool: return skills[action].in_use

func do_action(action: String, velocity: Vector2) -> Vector2:
	if !check_if_action_in_array("replace_actions", action, true):
		var current = skills[action]
		if !current.in_use && "launch" in current: 
			print("Jump LAUNCH")
			if "max" in skills[action]: skills[action].available -= 1
			if "force_stop" in skills[action]: skills[action].force_stop = false
			current = current.launch
			current.launched = true
		elif "force_stop" in skills[action] && skills[action].force_stop: return velocity
		if "force" in skills[action]:
			for key in ["x", "y"]:
				if current.change in [key, "all"]:
					velocity[key] = current.force[key] + (0 if current.replace else velocity[key])
			skills[action].in_use = true
		if "event" in current: for event in current.event: self.call(event, action)
	return velocity

func check_if_action_in_array(key: String, action: String, keep_in_use: bool = false) -> bool:
	for skill in skills:
		if key in skills[skill]:
			var all = 'all' in skills[skill][key]
			if (all && !action in skills[skill][key]) || (!all && action in skills[skill][key]):
				if skills[skill].in_use:
					skills[action].in_use = keep_in_use
					return true
	return false


##### EVENT #####################################################################

func reinit_fall_time(action: String) -> void: character.reinit_fall_time()

func inverse_move_direction(action: String) -> void: character.inverse_move_direction()

func synchronize_move_direction(action: String) -> void: character.synchronize_move_direction()

func one_less_jump_than_max(action: String) -> void: 
	if skills.jump.max == skills.jump.available: skills.jump.available -= 1

func one_less_if_from_falling(action: String) -> void:
	print("WOLOLO")
	if skills[action].max > 1 && skills[action].max == skills[action].available + 1:
		print("YAHOUZA")
		if !character.is_on_floor():
			skills[action].available -= 1
		


##### CONDITIONS ###############################################################

func on_floor(action: String) -> bool: return character.is_on_floor()

func not_on_floor(action: String) -> bool: return !on_floor(action)

func on_wall(action: String) -> bool: return character.is_on_wall()

func not_on_wall(action: String) -> bool: return !on_wall(action)

func launched(action: String) -> bool: return skills[action].max > skills[action].max

func available(action: String) -> bool: return skills[action].available > 0

func re_doable(action: String) -> bool: return skills[action].max > 1

func re_doable_and_available(action: String) -> bool: return re_doable(action) && available(action)

func on_floor_or_one_less_and_available(action: String) -> bool: 
	return on_floor(action) || re_doable_and_available(action)

#func _process(delta: float) -> void:
#	if !params.jetpack.in_use && params.jetpack.fuel < params.jetpack.base_fuel : params.jetpack.fuel += 0.1
#
#func activate_skill(skill: String) -> void:
#	params[skill].activated = true
#	character.displayed_state.push_back(skill)
#
#
#func can_do_action(action: String) -> bool: return !action_is_blocked(action) && self.call("can_" + action)
#

#
#### MOVE
#
## WALK
#func can_walk() -> bool: return params.walk.activated
#
#func is_walking() -> bool: return params.walk.in_use
#
#func start_walking() -> void: params.walk.in_use = true
#
#func walk() -> float: return params.walk.force * (params.run.force if is_running() else 1)
#
#func stop_walking() -> void: params.walk.in_use = false
#
## RUN
#func can_run() -> bool: return params.walk.activated && is_walking() && (!is_jumping() || params.run.in_use)
#
#func is_running() -> bool: return params.run.in_use
#
#func start_running() -> void: params.run.in_use = true
#
#func stop_running() -> void: params.run.in_use = false
#
#
#### JUMP
#func can_jump() -> bool:
#	return params.jump.activated && (can_first_jump() || can_more_jumps() || can_wall_jump())
#
#func can_first_jump() -> bool: return character.is_on_floor()
#
#func can_more_jumps() -> bool:
#	if params.jump.left > 0:
#		if params.jump.left < params.jump.max_use: return true
#		elif params.jump.left > 1:
#			params.jump.left -= 1
#			return true
#	return false
#
#func can_wall_jump() -> bool: return params.wall_jump.activated && !character.is_on_floor() && character.is_on_wall()
#
#func start_jumping() -> void:
#	character.fall_time = 0
#	params.jump.in_use = true
#	params.jump.launched = false
#	params.jump.interrupted = false
#	params.wall_jump.launched = false
#	params.jump.left -= 1
#
#func is_jumping() -> bool: return params.jump.in_use
#
#func jump() -> Vector2:
#	if !params.jump.launched:
#		params.jump.launched = true
#		if can_wall_jump(): return Vector2(launch_wall_jump(), params.jump.force)
#		return Vector2(character.velocity.x, params.jump.force)
#	else:
#		var vectorX: float
#		if params.wall_jump.launched:
#			if is_jetpacking(): params.wall_jump.launched = false
#			vectorX = params.wall_jump.force * params.wall_jump.direction
#		else: vectorX = character.velocity.x
#		if !params.jump.interrupted: return Vector2(vectorX, character.velocity.y - character.weight)
#		else: return Vector2(vectorX, character.velocity.y)
#
#func launch_wall_jump() -> float:
#	params.wall_jump.direction = -1 if character.face_off else 1
#	params.wall_jump.launched = true
#	params.jump.left = params.jump.max_use - 1
#	return params.wall_jump.force
#
#func interrupt_jump() -> void: params.jump.interrupted = true
#
#func jump_ended() -> bool: return params.jump.launched && character.is_on_floor()
#
#func stop_jumping() -> void:
#	params.jump.in_use = false
#	params.jump.left = params.jump.max_use
#
#
#### JETPACK
#func activate_jetpack_ability() -> void: params.jetpack.activated = true
#
#func is_jetpacking() -> bool: return params.jetpack.activated && (params.jetpack.in_use || refill_jetpack_fuel())
#
#func refill_jetpack_fuel() -> void: if params.jetpack.fuel < params.jetpack.base_fuel : params.jetpack.fuel += .1
#
#func get_jetpack_current_fuel() -> float: return params.jetpack.fuel
#
#func start_jetpacking() -> void: params.jetpack.in_use = true
#
#func can_jetpack() -> bool: return params.jetpack.activated && params.jetpack.fuel > 0
#
#func jetpacking() -> Vector2:
#	params.jetpack.fuel -= 0.4
#	if params.jetpack.fuel <= 0: params.jetpack.in_use = false
#	var x = params.jetpack.force.x * (1 if params.jetpack.fuel > 10 else params.jetpack.fuel / 10)
#	return Vector2(x, params.jetpack.force.y)
#
#func stop_jetpacking() -> void: params.jetpack.in_use = false
#
#
## MELEE
#func can_melee() -> bool: return params.melee.activated && !params.melee.in_use && !action_is_blocked("melee")
#
#func is_meleeing() -> bool: return params.melee.in_use
#
#func start_meleeing() -> void: params.melee.in_use = true
#
#func stop_meleeing() -> void: params.melee.in_use = false
#
#
## SHOOT
#func can_shoot() -> bool: return params.shoot.activated && !action_is_blocked("shoot")
#
#func is_shooting() -> bool: return params.shoot.activated && params.shoot.in_use
#
#func start_shooting() -> void: params.shoot.in_use = true
#
#func shooting() -> bool:
#	if params.shoot.counter <= 0:
#		params.shoot.counter = params.shoot.delay
#		return true
#	else:
#		params.shoot.counter -= 0.025
#		return false
#
#func stop_shooting() -> void:
#	params.shoot.counter = 0
#	params.shoot.in_use = false
#
#
#### WALL CLIMB
#func can_wall_hook() -> bool:
#	var active: bool = params.wall_hook.activated
#	var not_on_floor_and_on_wall := !character.is_on_floor() && character.is_on_wall()
#	var collider_ok := !character.bottom_back.is_colliding() && character.bottom_front.is_colliding()
#	return active && not_on_floor_and_on_wall && collider_ok
#
#func start_wall_hooking() -> void:
#	params.wall_hook.in_use = true
#	stop_jetpacking()
#
#func is_wall_hooking() -> bool: return params.wall_hook.in_use
#
#func wall_hook() -> Vector2:
#	character.fall_time = 0
#	var y = character.GRAVITY * character.fall_time
#	var vector = Vector2(0, -y)
#	if is_wall_climbing(): vector.y -= params.wall_climb.force
#	elif is_finishing_climbing(): vector -= params.wall_climb_finish.force
#	elif is_wall_lowering() : vector.y += params.wall_lower.force
#	return vector
#
#func stop_wall_hooking() -> void: params.wall_hook.in_use = false
#
#func can_wall_climb() -> bool:  return params.wall_climb.activated && is_wall_hooking()
#
#func is_wall_climbing() -> bool: return params.wall_climb.in_use
#
#func start_wall_climbing() -> void: params.wall_climb.in_use = true
#
#func stop_wall_climbing() -> void: params.wall_climb.in_use = false
#
#func finish_wall_climbing() -> void: 
#	params.wall_climb_finish.in_use = true
#	character.switch_collision(true)
#
#
#func is_finishing_climbing() -> bool: return params.wall_climb_finish.in_use  
#
#func stop_wall_climb_finish() -> void: 
#	character.switch_collision(false)
#	params.wall_climb_finish.in_use = false
#
#func can_wall_lower() -> bool:  return params.wall_lower.activated && is_wall_hooking()
#
#func is_wall_lowering() -> bool: return params.wall_lower.in_use
#
#func start_wall_lowering() -> void: params.wall_lower.in_use = true
#
#func stop_wall_lowering() -> void: params.wall_lower.in_use = false
#
#func finish_wall_lowering() -> Vector2: return Vector2(-40, 0)
