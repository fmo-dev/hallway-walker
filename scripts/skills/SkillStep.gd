extends Node

const SkillForce = preload("res://scripts/skills/SkillForce.gd") 

### TO RESET
var passed := false setget set_passed, is_passed

### CONDITIONS
var needs := [] setget set_needs, get_needs
var conditions := [] setget set_conditions, get_conditions
var stop_conditions := [] setget set_stop_conditions, get_stop_conditions
var reinit_steps_conditions: String setget set_reinit_steps_conditions, get_reinit_steps_conditions

### EFFECTS
var events := [] setget set_events, get_events
var force: SkillForce  setget ,get_force

var next := "released" setget set_next, get_next

func _init(data: Dictionary, main_step: bool = true) -> void:
	if data.get("needs"): set_needs(data.needs)
	if data.get("conditions"): set_conditions(data.conditions)
	if data.get("stop_conditions"): set_stop_conditions(data.stop_conditions)
	if data.get("reinit_steps_conditions"): set_reinit_steps_conditions(data.reinit_steps_conditions)
	if data.get("events"): set_events(data.events)
	if data.get("force"): set_force(data.force)
	if data.get("next"): set_next(data.next)
	if !main_step: set_next("instant")

func reset() -> void: 
	set_passed(false)
	if force: force.reset()

func apply_force(velocity: Vector2) -> Vector2: 
	if force: return force.apply(velocity)
	return velocity


#### GETTER / SETTER 

func set_passed(value: bool) -> void: passed = value
func is_passed() -> bool: return passed

func set_needs(value: Array) -> void: needs = value
func get_needs() -> Array: return needs

func set_conditions(value: Array) -> void: conditions = value
func get_conditions() -> Array: return conditions

func set_stop_conditions(value: Array) -> void: stop_conditions = value
func get_stop_conditions() -> Array: return stop_conditions

func set_reinit_steps_conditions(value: String) -> void: reinit_steps_conditions = value
func get_reinit_steps_conditions() -> String: return reinit_steps_conditions

func set_events(value: Array) -> void: events = value
func get_events() -> Array: return events

func set_force(value: Dictionary) -> void: force = SkillForce.new(value)
func get_force() -> SkillForce: return force

func set_next(value: String) -> void: next = value
func get_next() -> String: return next
