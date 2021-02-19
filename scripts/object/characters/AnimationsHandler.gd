extends Node

var object: AnimatedSprite
var animations: Dictionary
var animation_to_stop: String

func set_animations(new_animations: Array):
	for n in range(new_animations.size()):
		var combined_with = []
		if new_animations[n].size() > 1: combined_with = new_animations[n][1]
		animations[new_animations[n][0]]= {
			"priority": n,
			"active": false,
			"combined_with": combined_with
		}

func activate_animation(animation: String) -> void: animations[animation].active = true

func force_activate_animation(animation: String) -> void:
	animation_finished()
	activate_animation(animation)

func reactivate_animation(animation: String) -> void:
	if animation in object.animation: object.frame = 0
	activate_animation(animation)

func play_until_the_end(animation: String) -> void: 
	animations[animation].active = true
	animation_to_stop = animation

func animation_finished() -> void: 
	if animation_to_stop && animations[animation_to_stop].active:
		animations[animation_to_stop].active = false
		animation_to_stop = ""

func stop_animation(animation: String) -> void: animations[animation].active = false

func play_wanted_animation() -> void:
	var animation_to_play := "idle"
	var frame = 0
	for key in animations: 
		if animations[key].active: 
			animation_to_play = key
			if animations[key].combined_with.size():
				var new_key = ""
				for n in range(animations[key].combined_with.size()):
					if animations[animations[key].combined_with[n]].active:
						new_key += animations[key].combined_with[n] + "_"
						if animations[key].combined_with[n] in object.animation:
							frame = object.frame
				animation_to_play = new_key + key
	object.play(animation_to_play)
	if frame: object.frame = frame
