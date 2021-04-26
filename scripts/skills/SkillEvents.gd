extends Node

var character

func _init(new_character):
	character = new_character

### FALL

func reinit_fall_time() -> void: character.reinit_fall_time()


### DIRECTION 

func inverse_move_direction() -> void: character.inverse_move_direction()

func synchronize_move_direction() -> void: character.synchronize_move_direction()

func set_right_direction() -> void: character.set_right_direction()

func reinit_x() -> void: character.velocity.x = 0

func flip() -> void: 
	character.set_opposite_direction(!character.face_off)
	character.set_right_direction()

### COLLISION 

func reduce_collision_shape_y_by_25() -> void: character.reduce_collision_shape_y(25)

func reduce_collision_shape_y_by_50() -> void: character.reduce_collision_shape_y(50)

func reinit_collision_shape() -> void: character.reinit_collision_shape()
