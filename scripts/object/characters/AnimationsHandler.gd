extends Node

var object: AnimatedSprite
var animations: Dictionary
var animation_to_stop: String

func play_animation(skills: Array, on_floor: bool, top_colliding: bool) -> void:
	if !skills.size(): 
		if on_floor: object.play("down" if top_colliding else "idle")
		else: object.play("fall")
	elif !animation_to_stop:
		skills.sort()
		var animation = skills[0]
		for i in range(1, skills.size()): animation += "_" + skills[i]
		if animation != object.animation:
			if !on_floor && animation in ["run", "move"]: animation = "fall"
			if object.animation != animation: 
				var frame = object.frame  if same_animation(animation) else 0
				object.play(animation)
				object.frame = frame

func same_animation(animation: String) -> bool:
	return animation in object.animation || object.animation in animation

func play_until_the_end(animation: String) -> void:
	animation_to_stop = animation

#func set_animations(new_animations: Array):
#	for n in range(new_animations.size()):
#		var combined_with = []
#		if new_animations[n].size() > 1: combined_with = new_animations[n][1]
#		animations[new_animations[n][0]]= {
#			"priority": n,
#			"active": false,
#			"combined_with": combined_with
#		}
#
#func activate_animation(animation: String) -> void: animations[animation].active = true
#
#func force_activate_animation(animation: String) -> void:
#	animation_finished()
#	activate_animation(animation)
#
#func reactivate_animation(animation: String) -> void:
#	if animation in object.animation: object.frame = 0
#	activate_animation(animation)
#

#

#
#func stop_animation(animation: String) -> void: animations[animation].active = false
#
#func play_wanted_animation() -> void:
#	var animation_to_play := "idle"
#	var frame = 0
#	for key in animations: 
#		if animations[key].active: 
#			animation_to_play = key
#			if animations[key].combined_with.size():
#				var new_key = ""
#				for n in range(animations[key].combined_with.size()):
#					if animations[animations[key].combined_with[n]].active:
#						new_key += animations[key].combined_with[n] + "_"
#						if animations[key].combined_with[n] in object.animation:
#							frame = object.frame
#				animation_to_play = new_key + key
#	object.play(animation_to_play)
#	if frame: object.frame = frame
