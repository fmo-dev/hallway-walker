extends Node2D

const SkillCredit = preload("res://scripts/skills/SkillCredit.gd")

var skill_credit: SkillCredit
var value_container

func init(data: SkillCredit) -> void:
	skill_credit = data
	if skill_credit.display_type == "text":
		$TextState.visible = true
		value_container = $TextState
		value_container.text =  String(skill_credit.current)
	elif skill_credit.display_type == "bar":
		$BarState.visible = true
		value_container = $BarState/HBoxContainer/TextureProgress
		value_container.max_value =  skill_credit.max_credit
		value_container.value = skill_credit.current

func _process(_delta: float) -> void:
	if skill_credit.display_type == "bar" : value_container.value = skill_credit.current
	elif skill_credit.display_type == "text" : value_container.text = String(skill_credit.current)
