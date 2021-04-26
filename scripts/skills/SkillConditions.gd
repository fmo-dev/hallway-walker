extends Node

const Skill = preload("res://scripts/skills/Skill.gd")

var character

func _init(new_character):
	self.character = new_character

func on_floor() -> bool: return character.is_on_floor()

func not_on_floor() -> bool: return !on_floor()

func on_wall() -> bool: return character.is_on_wall()

func not_on_wall() -> bool: return !on_wall()

func top_on_wall() -> bool: return character.is_top_on_wall()

func not_top_on_wall() -> bool: return !top_on_wall()

func not_top_limit_on_wall() -> bool: return !top_limit_on_wall()

func top_limit_on_wall() -> bool: return character.is_top_limit_on_wall()

func on_ceiling() -> bool: return character.is_on_ceiling()

func not_on_ceiling() -> bool: return !on_ceiling()

func opposite_direction() -> bool: return character.get_opposite_direction()
