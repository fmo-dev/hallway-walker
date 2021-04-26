extends Node2D

const Character = preload("res://scripts/object/characters/Character.gd")
const CreditState = preload("res://scenes/ui/CreditState.tscn")
const SkillCredit = preload("res://scripts/skills/SkillCredit.gd")

const INPUTS := ["move", "run", "jump", "dash", "climb", "down", "attack_melee", "attack_distance"]

var credit_displayed = []

var robot := preload("res://scenes/characters/friendly/Robot.tscn").instance()
var character: Character

var last_direction_pressed: String

func _ready() -> void:
	change_character(robot)
	display_credits()

func change_character(new_character: Character) -> void:
	character = new_character
	add_child(character)

func _physics_process(_delta: float) -> void: check_input()

##### INPUT ###################################################################################################
func _input(event: InputEvent) -> void: check_direction("joystick_" if event is InputEventJoypadMotion else "")

func check_input() -> void:
	for input in INPUTS:
		if input == 'move':
			var joystick_pressed = pressed("joystick_right") || pressed("joystick_left")
			var keyboard_pressed = pressed("right") || pressed("left")
			character.set_skill("move", joystick_pressed || keyboard_pressed)
		else: character.set_skill(input, pressed(input), just_pressed(input))

func check_direction(prefix: String) -> void:
	character.set_opposite_direction(check_facing(prefix))
	for direction in ["up", "down"]: character.set_skill(direction, get_strength(prefix + direction))
		
func check_facing(prefix: String) -> bool:
	set_last_direction_pressed() || check_last_direction_pressed()
	var left = get_strength(prefix + "left")
	var right = get_strength(prefix + "right")
	if last_direction_pressed: return last_direction_pressed == "right"
	return left < right if left || right else character.face_off

func set_last_direction_pressed() -> void:
	for direction in ["right", "left"]: if just_pressed(direction): last_direction_pressed = direction

func check_last_direction_pressed() -> void:
	if just_released(last_direction_pressed): last_direction_pressed = ""
	
func pressed(input: String) -> bool: return Input.is_action_pressed(input)

func just_pressed(input: String) -> bool: return Input.is_action_just_pressed(input)

func just_released(input: String) -> bool: return Input.is_action_just_released(input)

func get_strength(input: String) -> float: return Input.get_action_strength(input)


##### GUI #####################################################################################################

func display_credits() -> void:
	var skills = character.skills_table.skills
	for skill in skills:
		if skills[skill].credit && skills[skill].credit.display_type:
			display_credit(skill)

func display_credit(skill: String) -> void:
	var skill_credit: SkillCredit = character.skills_table.get_skill_credit(skill)
	var credit_state = CreditState.instance()
	credit_state.init(skill_credit)
	credit_state.position = Vector2(0, 0)
	add_child(credit_state)
