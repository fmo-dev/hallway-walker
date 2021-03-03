extends Node

const SkillStep = preload("res://scripts/skills/SkillStep.gd") 

var activated := false setget set_activated, is_activated
var other_actions := [] setget set_other_actions, get_other_actions
var replaced_by := [] setget set_replaced_by, get_replaced_by
var instant := false setget set_instant, is_instant
var stop_on_release := false setget set_stop_on_release, is_stop_on_release

### TO RESET
var in_use := false setget set_in_use, is_in_use
var started := false setget set_started, is_started
var stopped := false setget set_stopped, is_stopped
var animation_finished := false setget set_animation_finished, is_animation_finished
var released := true setget set_released, is_released

### CONDITIONS 
var start_needs := [] setget set_start_needs, get_start_needs
var needs := [] setget set_needs, get_needs
var blocked_by := [] setget set_blocked_by, get_blocked_by
var start_conditions := [] setget set_start_conditions, get_start_conditions
var stop_conditions := [] setget set_stop_conditions, get_stop_conditions

### EVENTS
var start_events := [] setget set_start_events, get_start_events
var stop_events := [] setget set_stop_events, get_stop_events

### STEPS
var start: SkillStep setget ,get_start
var steps := [] setget set_steps, get_steps
var stop: SkillStep setget ,get_stop


func _init(data: Dictionary) -> void:
	if data.get("activated"): set_activated(data.activated)
	if data.get("other_actions"): set_other_actions(data.other_actions)
	if data.get("replaced_by"): set_replaced_by(data.replaced_by)
	if data.get("instant"): set_instant(data.instant)
	if data.get("stop_on_release"): set_stop_on_release(data.stop_on_release)
	if data.get("start_needs"): set_start_needs(data.start_needs)
	if data.get("needs"): set_needs(data.needs)
	if data.get("blocked_by"): set_blocked_by(data.blocked_by)
	if data.get("start_needs"): set_start_needs(data.start_needs)
	if data.get("needs"): set_needs(data.needs)
	if data.get("start_conditions"): set_start_conditions(data.start_conditions)
	if data.get("stop_conditions"): set_stop_conditions(data.stop_conditions)
	if data.get("start_events"): set_start_events(data.start_events)
	if data.get("stop_events"): set_stop_events(data.stop_events)
	if data.get("start"): set_start(data.start)
	if data.get("steps"): set_steps(data.steps)
	if data.get("stop"): set_stop(data.stop)

func reset() -> void:
	set_in_use(false) || set_started(false) || set_stopped(false)
	reset_steps() || set_animation_finished(false)
	for step in steps: step.reset()

func get_current_step() -> SkillStep:
	if !started: 
		started = true
		if start: return start
	for step in steps: if !step.is_passed(): return step
	stopped = true
	return stop if stop else null

func pass_all() -> void: for step in steps: step.passed = true

func reset_steps() -> void: for step in steps: step.passed = false

#### GETTER / SETTER

func set_activated(value: bool) -> void: activated = value
func is_activated() -> bool: return activated

func set_other_actions(value: Array) -> void: other_actions = value
func get_other_actions() -> Array: return other_actions

func set_replaced_by(value: Array) -> void: replaced_by = value
func get_replaced_by() -> Array: return replaced_by

func set_instant(value: bool) -> void: instant = value
func is_instant() -> bool: return instant

func set_stop_on_release(value: bool) -> void: stop_on_release = value
func is_stop_on_release() -> bool: return stop_on_release

func set_in_use(value: bool) -> void: in_use = value
func is_in_use() -> bool: return in_use

func set_started(value: bool) -> void: started = value
func is_started() -> bool: return started

func set_stopped(value: bool) -> void: stopped = value
func is_stopped() -> bool: return stopped

func set_animation_finished(value: bool) -> void: animation_finished = value
func is_animation_finished() -> bool: return animation_finished

func set_released(value: bool) -> void: released = value
func is_released() -> bool: return released

func set_start_needs(value: Array) -> void: start_needs = value
func get_start_needs() -> Array: return start_needs

func set_needs(value: Array) -> void: needs = value
func get_needs() -> Array: return needs

func set_blocked_by(value: Array) -> void: blocked_by = value
func get_blocked_by() -> Array: return blocked_by

func set_start_conditions(value: Array) -> void: start_conditions = value
func get_start_conditions() -> Array: return start_conditions

func set_stop_conditions(value: Array) -> void: stop_conditions = value
func get_stop_conditions() -> Array: return stop_conditions

func set_start_events(value: Array) -> void: start_events = value
func get_start_events() -> Array: return start_events

func set_stop_events(value: Array) -> void: stop_events = value
func get_stop_events() -> Array: return stop_events

func set_start(value: Dictionary) -> void: start = SkillStep.new(value, false)
func get_start() -> SkillStep: return start

func set_steps(values: Array) -> void: for value in values: steps.push_back(SkillStep.new(value))
func get_steps() -> Array: return steps

func set_stop(value: Dictionary) -> void: stop = SkillStep.new(value, false)

func get_stop() -> SkillStep: return stop
