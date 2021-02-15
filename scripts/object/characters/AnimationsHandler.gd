extends Node

var object: AnimatedSprite
var animations: Array = []


func set_animations(new_animations: Array):
	for n in range(new_animations.size()):
		animations.push_back({
			"priority": n,
			"name": new_animations[n],
			"active": false
		})

func activate_animation(index: int) -> void: animations[index]["active"] = true

	
func reactivate_animation(index: int) -> void:
	if object.animation == animations[index]["name"]: object.frame = 0
	activate_animation(index)

func stop_animation(index: int) -> void: animations[index]["active"] = false

func play_wanted_animation() -> void:
	var index_to_play := 0
	for n in range(animations.size()):
		if(animations[n]["active"]):
			index_to_play = n
	object.play(animations[index_to_play]["name"])
