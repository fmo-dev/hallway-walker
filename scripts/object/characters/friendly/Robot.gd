extends "res://scripts/object/characters/Character.gd"

#func shooting() -> void:
#	if skills_table.shooting():
#		$Bullet.scale.x = 1 if face_off else -1
#		$Bullet/Muzzle.visible = true
#		$Bullet/Muzzle.play("default")
#		var bullet_instance = BulletScene.instance()
#		bullet_instance.directionX = $Bullet.scale.x 
#		bullet_instance.get_node("AnimatedSprite").flip_h = !face_off
#		bullet_instance.position = $Bullet/BulletZone.global_position
#		get_parent().add_child(bullet_instance)
#		animationHandler.reactivate_animation("shoot")
 
#func _on_Muzzle_animation_finished():
#	$Bullet/Muzzle.frame = 0
#	$Bullet/Muzzle.stop()
#	$Bullet/Muzzle.visible = false
#
#func meleeing() -> void: 
#	$Melee.scale.x = 1 if face_off else -1
#	$Melee.visible = true
#	animationHandler.play_until_the_end("melee")
#
#func stop_meleeing() -> void: 
#	skills_table.stop_meleeing()
#	$Melee.visible = false

