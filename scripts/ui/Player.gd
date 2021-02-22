extends Node2D

const Character = preload("res://scripts/object/characters/Character.gd")
const JetPackState = preload("res://scenes/ui/JetPackState.tscn")

const INPUTS := ["left", "right", "up", "down", "run", "jump", "dash", "climb", "attack_melee", "attack_distance"]

var robot := preload("res://scenes/characters/friendly/Robot.tscn").instance()
var character: Character

func _ready() -> void:
	change_character(robot)

func change_character(new_character: Character) -> void:
	character = new_character
	add_child(character)

func _process(delta: float) -> void:
	check_input()

# INPUT
func check_input() -> void:
	var direction := check_direction()
	if character.face_off != direction: character.new_direction()
	var actions_call := []
	var actions_released := []
	for input in INPUTS:
		if just_pressed(input): character.instant_action(get_input(input))
		if pressed(input): actions_call.push_back(get_input(input))
		elif just_released(input): actions_released.push_back(get_input(input))
	character.set_action_called(actions_call, actions_released)

func get_input(input: String) -> String: return "move" if input in ["left", "right"] else input

func check_direction() -> bool:
	if just_released("left") && pressed("right"): return true
	elif just_released("right") && pressed("left"): return false
	else: return false if just_pressed("left") else true if just_pressed("right") else character.face_off

func pressed(action: String) -> bool: return Input.is_action_pressed(action)
func just_pressed(action: String) -> bool: return Input.is_action_just_pressed(action)
func just_released(action: String) ->  bool: return Input.is_action_just_released(action)
