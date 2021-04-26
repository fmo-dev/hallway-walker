extends Node

const Skill = preload("res://scripts/skills/Skill.gd")
const SkillStep = preload("res://scripts/skills/SkillStep.gd")
const SkillForce = preload("res://scripts/skills/SkillForce.gd")
const SkillEvents = preload("res://scripts/skills/SkillEvents.gd")
const SkillConditions = preload("res://scripts/skills/SkillConditions.gd")
const SkillCredit = preload("res://scripts/skills/SkillCredit.gd")

var skill_conditions: SkillConditions
var skill_events: SkillEvents

var character

var skills: Dictionary = {
	
	## MOVE #####################
	"move": Skill.new({
		"activated": true,
		"other_actions": ["wall_slide"],
		"blocked_by": ["climb_jump", "climb", "dash", "wall_slide"],
		"replaced_by": ["run", "slide"],
		"start_events": ["synchronize_move_direction"],
		"stop_events": ["reinit_x"],
		"steps": [{
			"events" : ["set_right_direction"],
			"force":{
				"value": 150,
				"axes": "x",
				"replace": true
			}
		}]
	}),
	"wall_slide": Skill.new({
		"activated": true,
		"needs": ["climb"],
		"blocked_by": ["climb_jump", "wall_slide_jump", "escalade", "descend"],
		"start_conditions": ["opposite_direction", "on_wall", "not_on_floor"],
		"stop_conditions": ["on_floor"],
		"steps": [{
			"force": {
				"value": Vector2(15, -20),
				"axes": "all",
				"replace": true
			},
		}],
		"stop": {
			"force": {
				"value": Vector2(0, 0),
				"axes": "all",
				"replace": true
			}
		}
	}),
	
	## UP #######################
	"up": Skill.new({
		"activated": true,
		"blocked_by": ["move", "run"],
		"other_actions": ["escalade"],
		"start_conditions": ["on_floor"],
		"steps": [{
			"events" : ["set_right_direction"]
		}]
	}),
	"escalade": Skill.new({
		"activated": true,
		"needs": ["climb"],
		"start_conditions": ["on_wall"],
		"replaced_by": ["climb_jump"],
		"steps": [{
			"events" : ["reinit_fall_time"],
			"force": {
				"value": Vector2(15, -40),
				"axes": "all",
				"replace": true
			}
		}],
		"stop": {
			"force": {
				"value": Vector2(15, -40),
				"axes": "all",
				"replace": true
			}
		}
	}),
	
	## DOWN #####################
	"down": Skill.new({
		"other_actions": ["slide", "descend"],
		"activated": true,
		"start_conditions": ["on_floor"],
		"stop_conditions": ["not_on_floor"],
		"stop_events": ["reinit_collision_shape"],
		"blocked_by": ["run", "wall_slide", "climb", "jump"],
		"start": {
			"force": {
				"value": 0,
				"axes": "x",
				"replace": true
			}
		},
		"steps": [{
			"events": ["reduce_collision_shape_y_by_25"],
			"conditions": ["on_floor"],
			"next": "instant"
		},
		{
			"conditions": ["on_floor"],
		}]
	}),
	"descend": Skill.new({
		"activated": true,
		"needs": ["climb||hang"],
		"start_conditions": ["on_wall"],
		"steps": [{
			"events" : ["reinit_fall_time"],
			"force": {
				"value": Vector2(15, 40),
				"axes": "all",
				"replace": true
			}
		}],
		"stop": {
			"force": {
				"value": Vector2(15, 40),
				"axes": "all",
				"replace": true
			}
		}
	}),
	"slide": Skill.new({
		"instant": true,
		"activated": true,
		"needs": ["run"],
		"blocked_by": ["jump"],
		"start_conditions": ["on_floor"],
		"stop_conditions": ["not_on_floor"],
		"stop_events": ["reinit_collision_shape"],
		"start": {
			"events": ["reduce_collision_shape_y_by_50"],
		},
		"steps": [{
			"force": {
				"value": 450,
				"variation": 10,
				"limit_force": 250,
				"axes": "x",
				"replace": true
			},
			"next": "limited_force_reached"
		}],
#		"stop": {
#			"events": ["reinit_collision_shape"],
#		}
	}),
	
	## RUN ######################
	"run": Skill.new({
		"activated": true,
		"stop_on_release": true,
		"needs": ["move"],
		"replaced_by": ["slide"],
		"blocked_by": ["down"],
		"start_conditions": ["on_floor"],
		"start_events": ["synchronize_move_direction"],
		"stop_events": ["reinit_x"],
		"steps": [{
			"blocked_by": ["down"],
			"events" : ["set_right_direction"],
			"force": {
				"value": 250,
				"axes": "x",
				"replace": true
			}
		}],
		"stop": {
			"force": {
				"value": 250,
				"axes": "x",
				"replace": true
			}
		}
	}),
	
	## JUMP #####################
	"jump": Skill.new({
		"other_actions": ["wall_slide_jump", "climb_jump", "wall_jump", "air_jump"],
		"activated": true,
		"instant": true,
		"start_conditions": ["on_floor"],
		"stop_conditions": ["on_floor", "on_ceiling"],
		"blocked_by": ["climb", "dash", "wall_jump", "air_jump"],
		"start": {
			"events": ["reinit_fall_time"],
			"force": {
				"value": -400,
				"axes": "y",
				"replace": true
			},
		},
		"steps": [{
			"force": {
				"value": -35,
				"axes": "y",
				"replace": false
			},
		},
		{
			"next": "animation_stop"
		}]
	}),
	"wall_jump": Skill.new({
		"activated": true,
		"instant": true,
		"replaced_by": ["air_jump"],
		"blocked_by": ["climb", "dash", "wall_slide_jump"],
		"start_conditions": ["not_on_floor", "on_wall"],
		"stop_conditions": ["on_floor", "on_ceiling"],
		"start": {
			"events": ["reinit_fall_time", "inverse_move_direction"],
			"force": {
				"value": -450,
				"axes": "y",
				"replace": true
			},
		},
		"steps": [{
			"next": "animation_stop"
		}],
	}),
	"climb_jump": Skill.new({
		"activated": true,
		"instant": true,
		"blocked_by": ["wall_slide", "dash"],
		"start_needs": ["climb"],
		"start_conditions": ["not_on_floor", "on_wall"],
		"stop_conditions": ["on_floor", "on_ceiling"],
		"start": {
			"force": {
				"value": Vector2(0, -200),
				"axes": "all",
				"replace": true
			},
			"events": ["reinit_fall_time"]
		},
		"steps": [{
			"force": {
				"value": Vector2(0, -40),
				"axes": "all",
				"replace": false
			},
		}],
		"stop": {
			"force": {
				"value": Vector2(50, 0),
				"axes": "all",
				"replace": true
			}
		}
	}),
	"air_jump": Skill.new({
		"activated": true,
		"instant": true,
		"start_conditions": ["not_on_floor", "not_on_wall", "not_on_ceiling"],
		"stop_conditions": ["on_floor", "on_ceiling"],
		"blocked_by": ["climb", "dash"],
		"credit": {
			"current": 1,
			"max_credit": 1,
			"total_use_per_step": 1,
			"total_refill_per_step": 1,
			"refill_condition": "is_on_floor",
			"display_type": "text"
		},
		"start": {
			"events": ["reinit_fall_time"],
			"force": {
				"value": -400,
				"axes": "y",
				"replace": true
			},
		},
		"steps": [{
			"force": {
				"value": -25,
				"axes": "y",
				"replace": false
			},
		},
		{
			"next": "animation_stop"
		}]
	}),
	"wall_slide_jump": Skill.new({
		"activated": true,
		"instant": true,
		"start_needs": ["wall_slide"],
		"blocked_by": ["dash"],
		"stop_conditions": ["on_floor", "on_ceiling"],
		"start": {
			"events": ["reinit_fall_time"],
			"force": {
				"value": Vector2(700, -300),
				"axes": "all",
				"replace": true
			},
		},
		"steps": [
			{
				"force": {
					"value": -30,
					"axes": "y",
					"replace": false
				},
				"next": "$on_wall"
			},
			{
				"next": "animation_stop"
			}]
	}),

	
	## DASH ####################
	"dash": Skill.new({
		"activated": true,
		"instant": true,
		"blocked_by": ["escalade", "descend"],
		"credit": {
			"current": 1,
			"max_credit": 1,
			"total_use_per_step": 1,
			"total_refill_per_step": 1,
			"refill_condition": "is_on_floor"
		},
		"start": {
			"events" : ["reinit_fall_time"],
			"force": {
				"value": Vector2(800, 0),
				"axes": "all",
				"replace": true
			},
		},
		"steps": [{
			"force": {
				"value": Vector2(800, 0),
				"axes": "all",
				"replace": true
			},
			"next": "animation_stop"
		}],
		"stop": {
			"force": {
				"value": Vector2(0, 0),
				"axes": "all",
				"replace": true
			},
		}
	}),
	
	## CLIMB ####################
	"climb": Skill.new({
		"other_actions": ["hang"],
		"activated": true,
		"replaced_by": ["wall_slide", "escalade", "descend", "climb_jump"],
		"blocked_by": ["wall_slide_jump"],
		"start_conditions": ["not_on_floor", "on_wall", "top_on_wall"],
		"stop_conditions": ["on_floor", "not_on_wall", "not_top_on_wall"],
		"steps": [{
			"events" : ["reinit_fall_time"],
			"force": {
				"value": Vector2(5, 10),
				"axes": "all",
				"replace": true
			},
		}]
	}),
	"hang": Skill.new({
		"activated": true,
		"start_conditions": ["on_wall", "not_top_on_wall", "top_limit_on_wall"],
		"stop_conditions": ["not_on_wall", "top_on_wall"],
		"steps": [{
			"events" : ["reinit_fall_time"],
			"force": {
				"value": Vector2(0, -0.766667),
				"axes": "all",
				"replace": true
			},
		}]
	}),
	
	## ATTACK MELEE #############
	"attack_melee": Skill.new({
		"activated": true,
		"instant": true,
		"blocked_by": ["climb", "wall_slide"],
		"start": {
			"force": {
				"value": 0,
				"axes": "x",
				"replace": true
			},
		},
		"steps": [{
			"force": {
				"value": 0,
				"axes": "x",
				"replace": false
			},
			"next": "animation_stop"
		}]
	}),
	## ATTACK DISTANCE ##########
	"attack_distance": Skill.new({
		"activated": true,
		"instant": true,
		"blocked_by": ["climb"],
		"steps": [{
			"force": {
				"value": 0,
				"axes": "x",
				"replace": true
			},
			"next": "animation_stop"
		}]
	})
}

func _init(character_ref) -> void:
	character = character_ref
	skill_conditions = SkillConditions.new(character)
	skill_events = SkillEvents.new(character)

###### SET DOABLE SKILLS #########################################################

func refill_skill_credits(character_ref) -> void: 
	for skill in skills: skills[skill].refill_credit(character_ref)

func set_doable_skill(input: String, just_pressed: bool) -> bool:
	var current: Skill = skills[input] as Skill
	for other_action in current.get_other_actions(): 
		if set_doable_skill(other_action, just_pressed): return true
	if !current.is_activated(): return false
	if current.is_instant() && (!current.is_released() || !just_pressed): return false
	current.set_released(false)
	if current.is_in_use(): return false
	if !check_if_in_use(current.get_start_needs()): return false
	elif !check_if_in_use(current.get_needs()): return false
	elif !check_if_in_use(current.get_blocked_by(), false): return false
	if !check_conditions(current.get_start_conditions()): return false
	if !check_if_credited(current): return false
	current.set_in_use(true)
	return true

func check_if_credited(skill: Skill) -> bool: return skill.credit == null || skill.credit.current > 0

func check_if_in_use(actions: Array, wanted_value := true) -> bool:
	for current in actions:
		if "||" in current:
			var currents = current.split("||")
			var value: bool
			for action in currents:
				if skills[action].is_in_use() == wanted_value: value = true
			if !value: return false
		elif skills[current].is_in_use() != wanted_value: return false
	return true

func check_conditions(conditions: Array, wanted_value := true) -> bool:
	for condition in conditions: if check_condition(condition) != wanted_value: return false
	return true

func check_condition(condition: String) -> bool: return skill_conditions.call(condition)

###### DO ACTION && CHECK STEP ###################################################

func do_all_skills(velocity: Vector2) -> Dictionary:
	var current_x = velocity.x
	var actions_names := []
	for skill in skills:
		var skill_applying = can_apply_skill(skill)
		if skill_applying:
			var step_applying = can_apply_step(skill)
			if step_applying:
				if check_if_in_use(skills[skill].get_replaced_by(), false):
					actions_names.push_back(skill)
					velocity = apply_skill(step_applying, velocity)
				check_if_step_passed(step_applying, skill)
	return {"vector": velocity, "names": actions_names, "same_x": velocity.x == current_x}

#### CHECK SKILL ########

func can_apply_skill(skill: String) -> bool:
	var current = skills[skill]
	if !current.is_in_use(): return false
	if current.is_started():
		if !check_conditions(current.get_stop_conditions(), false):
			reset_action(current)
			return false
		elif !check_if_in_use(current.get_needs()):
			reset_action(current)
			return false
		elif !check_if_in_use(current.get_blocked_by(), false):
			reset_action(current)
			return false
	else: apply_events(current.get_start_events())
	return true

#### CHECK STEP ########

func can_apply_step(skill: String) -> SkillStep:
	if !check_if_in_use(skills[skill].get_needs()): skills[skill].pass_all()
	var step: SkillStep = skills[skill].get_current_step()
	if !step: return null
	elif !check_conditions(step.get_conditions()): return null
	elif !check_conditions(step.get_stop_conditions(), false): return null
	elif !check_reinit_step_condition(skill, step): return null
	elif !check_if_in_use(step.get_needs()): return null
	return step

func check_reinit_step_condition(skill: String, step: SkillStep) -> bool:
	var condition = step.get_reinit_steps_conditions()
	if condition && check_condition(condition):
		skills[skill].reset_steps()
		return false
	return true

func check_if_step_passed(step: SkillStep, skill: String) -> void:
	var next_condition = step.get_next()
	if "$" in next_condition:
		var condition = next_condition.substr(1, next_condition.length())
		if check_condition(condition): step.set_passed(true)
	elif next_condition == "animation_stop" && skills[skill].is_animation_finished():
		step.set_passed(true)
	elif next_condition == "released" && skills[skill].is_released():
		step.set_passed(true)
	elif next_condition == "limited_force_reached" && skills[skill].is_limit_force_reached():
		step.set_passed(true)
	elif next_condition == "instant": step.set_passed(true)

#### APPLY #############

func apply_skill(step: SkillStep, velocity: Vector2) -> Vector2:
	apply_events(step.get_events())
	velocity = apply_force(step, velocity)
	return velocity

func apply_events(events: Array) -> void: for event in events: skill_events.call(event)
	
func apply_force(step: SkillStep, velocity: Vector2) -> Vector2: return step.apply_force(velocity)

###### STOP ACTION ###############################################################

func release_skill(input: String) -> void:
	for other_action in skills[input].get_other_actions(): release_skill(other_action)
	skills[input].set_released(true)
	if skills[input].is_in_use() && skills[input].is_stop_on_release(): skills[input].pass_all()


func animation_finish() -> void:
	for skill in skills:
		if skills[skill].is_in_use() && !skills[skill].is_animation_finished():
			skills[skill].set_animation_finished(true)

func reset_action(action: Skill) -> void:
	apply_events(action.get_stop_events())
	action.reset()

func stop_skills() -> void: for skill in skills: if skills[skill].is_stopped(): reset_action(skills[skill])


###### UTILS #####################################################################

func get_skill(skill: String) -> SkillCredit: 
	return skills[skill]
	
func get_skill_credit(skill: String) -> SkillCredit: 
	return skills[skill].get_credit()
