extends KinematicBody2D

var weight = 12
const GRAVITY := 200
var fall_time := 0.0
var on_floor: bool
var velocity = Vector2(0, 0)
var face_off := true

func _physics_process(delta: float) -> void: on_physics_process(delta)

func on_physics_process(delta: float) -> void:
	fall(delta)

func fall(delta: float) -> void: 
	fall_time = (fall_time + delta * 2) if !is_on_floor() else 0
	velocity.y += GRAVITY * fall_time
	move_and_slide(velocity, Vector2.UP)
	
func launch(force: int, weight: int) -> void : velocity.y = -force * weight


func switch_collision(value: bool) -> void: $CollisionShape2D.disabled = value
