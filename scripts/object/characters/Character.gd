extends "res://scripts/object/GravityObject.gd"

# MAIN
var bottom_front: RayCast2D
var bottom_back: RayCast2D
const Projectile = preload("res://scripts/object/projectiles/Projectiles.gd")
var projectile: Projectile

# STATE
var displayed_state: Array = []

### ANIMATIONS
var animationHandler := preload("res://scripts/object/characters/AnimationsHandler.gd").new()
const ANIMATIONS = [
	["walk"], ["run"], ["fall"], ["jetpack"], ["wall_hook"], ["wall_climb"], ["wall_climb_finish"], ["jump"], ["shoot", ["walk", "run", "jump"]],
	["melee", ["walk", "run", "jump"], true]]

#### INVENTORY
var skills_table = load("res://scripts/inventory/SkillsTable.gd").new(self)

func _ready() -> void:
	bottom_front = $AnimatedSprite/bottom_front as RayCast2D
	bottom_back = $AnimatedSprite/bottom_back as RayCast2D
	animationHandler.object = $AnimatedSprite as AnimatedSprite
	animationHandler.set_animations(ANIMATIONS)

func _on_AnimatedSprite_animation_finished():
	if "melee" in $AnimatedSprite.animation: stop_meleeing()
	if $AnimatedSprite.animation == "wall_climb_finish": stop_wall_climb_finish()
	animationHandler.animation_finished()

func on_physics_process(delta: float) -> void:
	$AnimatedSprite.flip_h = !face_off
	if skills_table.is_walking(): walk()
	else: velocity.x = 0
	if skills_table.is_jumping(): jump()
	if skills_table.is_jetpacking(): jetpack()
	if skills_table.is_wall_hooking(): wall_hook()
	if skills_table.is_shooting(): shooting()
	if skills_table.is_meleeing(): meleeing()
	if !is_on_floor(): animationHandler.activate_animation("fall")
	else: animationHandler.stop_animation("fall")
	animationHandler.play_wanted_animation()
	.on_physics_process(delta)

func set_vector_direction(vector: Vector2) -> Vector2: return Vector2(set_x_direction(vector.x), vector.y)
func set_x_direction(value: float) -> float: return value * (1 if face_off else -1)

func activate_skill(skill: String) -> void: skills_table.activate_skill(skill)


func new_direction() -> void:
	face_off = !face_off
	bottom_front.rotation_degrees = -90 if face_off else 90
	bottom_back.rotation_degrees = 90 if face_off else -90
	if skills_table.is_wall_hooking(): stop_wall_hooking()

# MOVE
func start_walking() -> void:
	if skills_table.can_do_action("walk"):
		skills_table.start_walking()
		animationHandler.activate_animation("walk")

func walk() -> void: velocity.x = set_x_direction(skills_table.walk())

func stop_walking() -> void:
	skills_table.stop_walking()
	animationHandler.stop_animation("walk")
	stop_running()

func start_running() -> void:
	if skills_table.can_do_action("run"):
		skills_table.start_running()
		animationHandler.stop_animation("walk")
		animationHandler.activate_animation("run")

func stop_running() -> void:
	skills_table.stop_running()
	animationHandler.stop_animation("run")
	if skills_table.is_walking():
		animationHandler.activate_animation("walk")


# JUMP
func start_jumping() -> void:
	if skills_table.can_do_action("jump"):
		animationHandler.reactivate_animation("jump")
		animationHandler.play_until_the_end("jump")
		skills_table.start_jumping()

func jump() -> void:
	if skills_table.jump_ended():
		animationHandler.stop_animation("jump")
		skills_table.stop_jumping()
	else: velocity = skills_table.jump()

func interrupt_jump() -> void: skills_table.interrupt_jump()


# JET PACK
func get_jetpack_current_fuel() -> float: return skills_table.get_jetpack_current_fuel()

func start_jetpacking() -> void:
	if skills_table.can_do_action("jetpack"):
		skills_table.start_jetpacking()
		animationHandler.force_activate_animation("jetpack")

func jetpack() -> void:
	velocity = set_vector_direction(skills_table.jetpacking())
	if get_jetpack_current_fuel() < 0: stop_jetpacking()

func stop_jetpacking() -> void:
	animationHandler.stop_animation("jetpack")
	skills_table.stop_jetpacking()


# SHOOT
func start_shooting() -> void:
	if skills_table.can_do_action("shoot"):
		skills_table.start_shooting()
		animationHandler.stop_animation("melee")

func shooting() -> void: pass

func stop_shooting() -> void:
	if skills_table.is_shooting():
		animationHandler.stop_animation("shoot")
		skills_table.stop_shooting()


# MELEE
func start_meleeing() -> void:
	if skills_table.can_do_action("melee"):
		skills_table.start_meleeing()
		animationHandler.stop_animation("shoot")
		

func meleeing() -> void: pass

func stop_meleeing() -> void: pass


# WALL HOOK

func start_wall_hooking() -> void:
	if skills_table.can_do_action("wall_hook"):
		skills_table.start_wall_hooking()
		animationHandler.activate_animation("wall_hook")
		animationHandler.stop_animation("jump")

func wall_hook() -> void:
	velocity = set_vector_direction(skills_table.wall_hook())
	if !skills_table.is_finishing_climbing():
		if is_on_floor():
			velocity = set_vector_direction(skills_table.finish_wall_lowering())
			stop_wall_climbing()
			stop_wall_hooking()
		elif !bottom_front.is_colliding():
			skills_table.finish_wall_climbing()
			animationHandler.play_until_the_end("wall_climb_finish")

func stop_wall_climb_finish() -> void:
	skills_table.stop_wall_climb_finish()
	stop_wall_climbing()
	stop_wall_hooking()

func stop_wall_hooking() -> void:
	skills_table.stop_wall_hooking()
	animationHandler.stop_animation("wall_hook")


# WALL CLIMB

func start_wall_climbing() -> void:
	if skills_table.can_do_action("wall_climb"):
		skills_table.start_wall_climbing()
		animationHandler.activate_animation("wall_climb")

func stop_wall_climbing() -> void:
	skills_table.stop_wall_climbing()
	animationHandler.stop_animation("wall_climb")

func start_wall_lowering() -> void:
	if skills_table.can_do_action("wall_lower"):
		skills_table.start_wall_lowering()
		animationHandler.activate_animation("wall_climb")
		
func stop_wall_lowering() -> void:
	skills_table.stop_wall_lowering()
	animationHandler.stop_animation("wall_climb")
