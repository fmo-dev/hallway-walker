extends Node2D

const ObjectCollision = preload("res://scenes/utilities/ObjectCollision.tscn")

var right: RayCast2D
var left: RayCast2D
var bottom_x_0: RayCast2D
var bottom_x_max: RayCast2D
var top_right: RayCast2D
var top_left: RayCast2D
var top_left_limit: RayCast2D
var top_right_limit: RayCast2D
var top_x_0: RayCast2D
var top_x_max: RayCast2D

var object

func init(data):
	self.object = data

	bottom_x_0 = set_direction_collision(Vector2(0, 1), -1)
	bottom_x_max = set_direction_collision(Vector2(0, 1), 1)
	top_x_0 = set_direction_collision(Vector2(0, -1.01), -1)
	top_x_max = set_direction_collision(Vector2(0, -1.01), 1)
	
	right = set_direction_collision(Vector2(1.005, 0))
	top_right = set_direction_collision(Vector2(1.005, 0), -0.5)
	top_right_limit = set_direction_collision(Vector2(1.005, 0), -0.5, 15)
	
	left = set_direction_collision(Vector2(-1.01, 0))
	top_left = set_direction_collision(Vector2(-1.01, 0), -0.5)
	top_left_limit = set_direction_collision(Vector2(-1.01, 0), -0.5, 15)
	
func set_direction_collision(direction: Vector2, other_axe = null, variation = 0):
	var collision = ObjectCollision.instance()
	collision.position = object.shape_position
	collision.cast_to = Vector2.ZERO
	collision.enabled = true
	if direction.y != 0:
		collision.cast_to.y = object.shape_extents.y * direction.y
		if other_axe != null: 
			collision.cast_to.x = object.shape_extents.x * other_axe + variation
	else:
		collision.cast_to.x = object.shape_extents.x * direction.x
		if other_axe != null: 
			collision.cast_to.y = object.shape_extents.y * other_axe + variation
	add_child(collision)
	return collision

func top_colliding(): return top_x_0.is_colliding() || top_x_max.is_colliding()

func bottom_colliding(): return bottom_x_0.is_colliding() || bottom_x_max.is_colliding()
