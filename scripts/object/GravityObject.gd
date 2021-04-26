extends KinematicBody2D

const ObjectCollisionsScene = preload("res://scenes/utilities/ObjectCollisions.tscn")
const ObjectCollisions = preload("res://scripts/object/ObjectCollisions.gd")
onready var collision: CollisionShape2D = $CollisionShape2D
onready var shape_extents = collision.shape.get_extents()
onready var shape_position = collision.position
onready var body: AnimatedSprite = $Body

var collisions: ObjectCollisions
var move_direction_inverted := false
var weight = 0.92
const GRAVITY := 100
var fall_time := 0.0
var fall_time_reinit: bool
var velocity = Vector2(0, 0)
var face_off := true
var opposite_direction: bool
var stay_down: bool

func _ready() -> void: set_collisions()

func _physics_process(delta: float) -> void: on_physics_process(delta)

func on_physics_process(delta: float) -> void:
	if stay_down:
		stay_down = collisions.top_colliding()
		if !stay_down: reinit_collision_shape()
	fall(delta)

func fall(delta: float) -> void:
	fall_time = (fall_time + delta * weight) if !is_on_floor() else 0
	if fall_time_reinit:
		fall_time = 0
		fall_time_reinit = false
	velocity.y += GRAVITY * fall_time
	var _slide = move_and_slide(velocity, Vector2.UP)

func reinit_fall_time() -> void: fall_time_reinit = true

func launch(force: int) -> void : velocity.y = -force * weight

#### COLLISIONS

func set_collisions() -> void:
	collisions = ObjectCollisionsScene.instance()
	collisions.init(self)
	add_child(collisions)

func get_direction() -> String: return "right" if face_off else "left"

func check_collision(area: String) -> bool: return collisions[area].is_colliding()

func is_on_wall() -> bool:
	return check_collision(get_direction())
	
func is_top_on_wall() -> bool: 
	return check_collision("top_" + get_direction())

func is_top_limit_on_wall() -> bool: 
	return check_collision("top_" + get_direction() + "_limit")


#### COLLISION SHAPE 

func switch_collision(value: bool) -> void: collision.disabled = value

func reduce_collision_shape_y(value: float) -> void:
	var y_difference = shape_extents.y * value / 100
	collision.shape.extents.y = shape_extents.y - y_difference
	collision.position.y = shape_position.y + y_difference

func reinit_collision_shape() -> void:
	if !collisions.top_colliding():
		collision.shape.extents = shape_extents
		collision.position = shape_position
	else: stay_down = true

#### DIRECTION ########################################################

func set_vector_direction(vector: Vector2) -> Vector2: return Vector2(set_x_direction(vector.x), vector.y)

func set_x_direction(value: float) -> float:
	if !value: return value
	return value * (1 if face_off else -1) * (-1 if move_direction_inverted else 1)

func inverse_move_direction() -> void: move_direction_inverted = true

func synchronize_move_direction() -> void: move_direction_inverted = false

func set_right_direction() -> void:
	if opposite_direction && !move_direction_inverted: 
		new_direction() || set_opposite_direction(face_off)

func set_opposite_direction(value: bool) -> void: 
	synchronize_move_direction()
	opposite_direction = value != face_off

func get_opposite_direction() -> bool: return opposite_direction

func new_direction() -> void:
	face_off = !face_off
	body.flip_h = !face_off
