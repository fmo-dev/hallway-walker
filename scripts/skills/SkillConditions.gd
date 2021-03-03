extends Node

const Character = preload("res://scripts/object/characters/Character.gd")
const Skill = preload("res://scripts/skills/Skill.gd")

var character: Character

func _init(character: Character):
	self.character = character

func on_floor() -> bool: return character.is_on_floor()

func not_on_floor() -> bool: return !on_floor()

func on_wall() -> bool: return character.is_on_wall()

func not_on_wall() -> bool: return !on_wall()

func on_ceiling() -> bool: return character.is_on_ceiling()

func opposite_direction() -> bool: return character.get_opposite_direction()
