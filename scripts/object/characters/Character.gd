extends "res://scripts/object/GravityObject.gd"

var animationHandler := preload("res://scripts/object/characters/AnimationsHandler.gd").new()

var skills_table = load("res://scripts/skills/SkillsTable.gd").new(self)

func _ready() -> void:
	animationHandler.object = body

func _physics_process(delta: float) -> void:
	skills_table.refill_skill_credits(self)
	if skills_table.skills.move.is_in_use(): if is_on_floor(): synchronize_move_direction()
	skills_table.stop_skills()
	var skills_in_progress = skills_table.do_all_skills(velocity)
	velocity = set_vector_direction(skills_in_progress.vector)
#	if skills_in_progress.same_x: velocity = set_vector_direction(skills_in_progress.vector)
	animationHandler.play_animation(skills_in_progress.names, is_on_floor())
	.on_physics_process(delta)

func _on_OLD_AnimatedSprite_animation_finished(): skills_table.animation_finish()


#### Skills #####################################################################

func set_skill(input: String, pressed: bool, just_pressed := false) -> void:
	if input == "down" && stay_down: pressed = true
	if !pressed: skills_table.release_skill(input)
	else: skills_table.set_doable_skill(input, just_pressed)
