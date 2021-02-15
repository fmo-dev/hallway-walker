extends "res://scripts/object/GravityObject.gd"

# MAIN


### ANIMATIONS
var animationHandler := preload("res://scripts/object/characters/AnimationsHandler.gd").new()
const ANIMATIONS = ["idle", "run", "jump"]

#### INVENTORY
var skills_table := preload("res://scripts/inventory/SkillsTable.gd").new(self)

func _ready() -> void: 
	animationHandler.object = $AnimatedSprite as AnimatedSprite
	animationHandler.set_animations(ANIMATIONS)

func on_physics_process(delta: float) -> void:
	$AnimatedSprite.flip_h = !face_off
	if skills_table.is_moving(): move()
	else: velocity.x = 0
	if skills_table.is_jetpacking(): jetpack()
	if skills_table.is_jumping(): jump()
	animationHandler.play_wanted_animation()
	.on_physics_process(delta)

func set_vector_direction(vector: Vector2) -> Vector2: return Vector2(set_x_direction(vector.x), vector.y)
func set_x_direction(value: float) -> float: return value * (1 if face_off else -1)

# MOVE
func start_moving() -> void: 
	skills_table.start_moving()
	animationHandler.activate_animation(1)

func move() -> void: velocity.x = set_x_direction(skills_table.move())

func stop_moving() -> void: 
	skills_table.stop_moving()
	animationHandler.stop_animation(1)
	
	

# JUMP
func start_jumping() -> void: 
	if skills_table.can_jump(): 
		animationHandler.reactivate_animation(2)
		skills_table.start_jumping()

func jump() -> void: 
	if skills_table.jump_ended(): 
		animationHandler.stop_animation(2)
		skills_table.stop_jumping()
	else: 
		velocity = skills_table.jump()
		print(velocity)

func interrupt_jump() -> void: skills_table.interrupt_jump()

# JET PACK
func activate_jetpack_ability() -> void: skills_table.activate_jetpack_ability()

func get_jetpack_current_fuel() -> float: return skills_table.get_jetpack_current_fuel()

func start_jetpacking() -> void: if skills_table.can_jetpacking(): skills_table.start_jetpacking()

func jetpack() -> void: velocity = set_vector_direction(skills_table.jetpacking())

func stop_jetpacking() -> void: skills_table.stop_jetpacking()
