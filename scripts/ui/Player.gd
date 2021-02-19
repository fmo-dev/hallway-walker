extends Node2D

const Character = preload("res://scripts/object/characters/Character.gd")
const JetPackState = preload("res://scenes/ui/JetPackState.tscn")
const last_pressed := "right"
var camera_init := false

const ACTIONS := [
	{ "name": "ui_right", "start": "start_walking", "end": "stop_walking", "instant": false },
	{ "name": "ui_left", "start": "start_walking", "end": "stop_walking", "instant": false },
	{ "name": "ui_shift", "start": "start_running", "end": "stop_running", "instant": false },
	{ "name": "ui_select", "start": "start_jumping", "end": "interrupt_jump", "instant": true},
	{ "name": "ui_wheel", "start": "start_jetpacking", "end": "stop_jetpacking", "instant": true},
	{ "name": "ui_mouse_left", "start": "start_shooting", "end": "stop_shooting", "instant": false},
	{ "name": "ui_mouse_right", "start": "start_meleeing", "end": null, "instant": true},
	{ "name": "ui_ctrl", "start": "start_wall_hooking", "end": "stop_wall_hooking", "instant": false},
	{ "name": "ui_up", "start": "start_wall_climbing", "end": "stop_wall_climbing", "instant": false},
	{ "name": "ui_down", "start": "start_wall_lowering", "end": "stop_wall_lowering", "instant": false}
]

var robot := preload("res://scenes/characters/friendly/Robot.tscn").instance()
var character: Character
var camera: Camera2D

# BAR
var jetpack_state

func _ready() -> void:
	change_character(robot)
	
	
## TODO NEXT ######################################
	add_jetpack_state_bar()
func add_jetpack_state_bar():
	character.activate_skill("jetpack")
	jetpack_state = JetPackState.instance()
	$GUI.add_child(jetpack_state)
####################################################






func change_character(new_character: Character) -> void:
	character = new_character
	add_child(character)
	add_camera()

func add_camera():
	if camera_init: character.remove_child(camera)
	else: camera_init = true
	camera = Camera2D.new()
	camera.current = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 0
	character.add_child(camera)

func _process(delta):
	check_input()
	if jetpack_state: jetpack_state.get_child(0).get_child(0).value = character.get_jetpack_current_fuel()



# INPUT
func check_input() -> void:
	var direction = check_direction()
	if character.face_off != direction: character.new_direction()
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
