extends KinematicBody2D

var move_direction_inverted := false
var weight = 0.92
const GRAVITY := 100
var fall_time := 0.0
var velocity = Vector2(0, 0)
var face_off := true

func _physics_process(delta: float) -> void: on_physics_process(delta)

func on_physics_process(delta: float) -> void:
	fall(delta)

func fall(delta: float) -> void: 
	fall_time = (fall_time + delta * weight) if !is_on_floor() else 0
	velocity.y += GRAVITY * fall_time
	move_and_slide(velocity, Vector2.UP)

func reinit_fall_time() -> void: fall_time = 0

func set_vector_direction(vector: Vector2) -> Vector2: return Vector2(set_x_direction(vector.x), vector.y)

func set_x_direction(value: float) -> float: 
	if move_direction_inverted: return value * (-1 if face_off else 1)
	else: return value * (1 if face_off else -1)

func launch(force: int, weight: int) -> void : velocity.y = -force * weight

func switch_collision(value: bool) -> void: $CollisionShape2D.disabled = value

func inverse_move_direction() -> void: move_direction_inverted = true

func synchronize_move_direction() -> void: move_direction_inverted = false
