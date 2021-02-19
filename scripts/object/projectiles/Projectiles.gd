extends Area2D

var weight: int
var speed: Vector2

func _process(delta): position += speed * delta

