extends "res://scripts/object/projectiles/Projectiles.gd"


export var directionX: int

func _ready(): speed = Vector2(1500 * directionX, 0)

func _on_Robot_Bullet_body_entered(body): 
	speed = Vector2.ZERO
	$AnimatedSprite.play("destroy")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "destroy":
		queue_free()
