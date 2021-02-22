extends Node2D

onready var camera := $Camera
var current_world : Node2D


func _ready() -> void: 
	current_world = $Forest
	set_camera_limits()


func set_camera_limits() -> void:
	var limit = current_world.get_node("Limit")
	camera.limit_top = limit.get_node("TopLeft").position.y
	camera.limit_left = limit.get_node("TopLeft").position.x
	camera.limit_bottom = limit.get_node("BottomRight").position.y
	camera.limit_right = limit.get_node("BottomRight").position.x
