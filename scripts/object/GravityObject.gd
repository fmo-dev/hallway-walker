extends KinematicBody2D

onready var collision: CollisionShape2D = $CollisionShape2D
onready var shape_extents = collision.shape.get_extents()
onready var shape_position = collision.position
onready var body: AnimatedSprite = $Body
onready var back = load("res://scenes/utilities/collisions/BackCollision.tscn").instance()
var move_direction_inverted := false
var weight = 0.92
const GRAVITY := 100
var fall_time := 0.0
var fall_time_reinit: bool
var velocity = Vector2(0, 0)
var face_off := true
var opposite_direction: bool

func _ready() -> void: set_back()

func set_back() -> void: 
	back.position.y = shape_position.y / 2
	back.cast_to.x = shape_extents.x / 2
	body.add_child(back)

func _physics_process(delta: float) -> void: on_physics_process(delta)

func on_physics_process(delta: float) -> void: fall(delta)

func fall(delta: float) -> void: 
	fall_time = (fall_time + delta * weight) if !is_on_floor() else 0
	if fall_time_reinit: 
		fall_time = 0
		fall_time_reinit = false
	velocity.y += GRAVITY * fall_time
	move_and_slide(velocity, Vector2.UP)

func reinit_fall_time() -> void: fall_time_reinit = true

func launch(force: int) -> void : velocity.y = -force * weight


#### COLLISION SHAPE 

func switch_collision(value: bool) -> void: collision.disabled = value

func reduce_collision_shape_y(value: float) -> void: 
	var y_difference = shape_extents.y * value / 100
	collision.shape.extents.y -= y_difference
	collision.position.y -= y_difference


func reinit_collision_shape() -> void:
	collision.shape.extents = shape_extents
	collision.position = shape_position

#### DIRECTION ########################################################

func set_vector_direction(vector: Vector2) -> Vector2: return Vector2(set_x_direction(vector.x), vector.y)

func set_x_direction(value: float) -> float: 
	if !value: return value
	return value * (1 if face_off else -1) * (-1 if move_direction_inverted else 1)

func inverse_move_direction() -> void: move_direction_inverted = true

func synchronize_move_direction() -> void: move_direction_inverted = false

func set_right_direction() -> void: 
	if opposite_direction: new_direction() || set_opposite_direction(face_off)

func set_opposite_direction(value: bool) -> void: opposite_direction = value != face_off

func get_opposite_direction() -> bool: return opposite_direction

func new_direction() -> void:
	back.scale.x *= -1
	face_off = !face_off
	body.flip_h = !face_off

