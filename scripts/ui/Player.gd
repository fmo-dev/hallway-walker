extends Node2D

const Character = preload("res://scripts/object/characters/Character.gd")
const JetPackState = preload("res://scenes/ui/JetPackState.tscn")
const last_pressed = "right"


const ACTIONS := [
	{ "name": "ui_right", "start": "start_moving", "end": "stop_moving", "instant": false },
	{ "name": "ui_left", "start": "start_moving", "end": "stop_moving", "instant": false },
	{ "name": "ui_select", "start": "start_jumping", "end": "interrupt_jump", "instant": true},
	{ "name": "ui_shift", "start": "start_jetpacking", "end": "stop_jetpacking", "instant": true}
]

var robot := preload("res://scenes/characters/friendly/Robot.tscn").instance()
var character: Character

# BAR
var jetpack_state

func _ready() -> void:
	character = robot
	character.scale = Vector2(.35, .35)
	add_child(character)
	
func _process(delta): 
	check_input()
	if jetpack_state:  jetpack_state.get_child(0).get_child(0).value = character.get_jetpack_current_fuel()

func add_jetpack_state_bar(): 
	character.activate_jetpack_ability()
	jetpack_state = JetPackState.instance()
	add_child(jetpack_state)

# INPUT
func check_input() -> void:
	if just_pressed("ui_accept"): add_jetpack_state_bar()
	character.face_off = check_direction()
	for action in ACTIONS:
		if just_pressed(action.name) if action.instant else pressed(action.name): character.call(action.start)
		elif action.end && just_released(action.name): character.call(action.end)

func check_direction() -> bool:
	if just_released("ui_left") && pressed("ui_right"): return true
	elif just_released("ui_right") && pressed("ui_left"): return false
	else: return false if just_pressed("ui_left") else true if just_pressed("ui_right") else character.face_off

func pressed(action: String) -> bool: return Input.is_action_pressed(action)
func just_pressed(action: String) -> bool: return Input.is_action_just_pressed(action)
func just_released(action: String) ->  bool: return Input.is_action_just_released(action)
