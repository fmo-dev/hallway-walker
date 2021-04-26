extends Node


var current: int
var max_credit: int
var refill_condition: String
var refill_with_time := false
var total_use_per_step: int
var total_refill_per_step: int

# @Temp
var display_type: String

func refill(character_ref) -> void:
	if current < max_credit:
		if refill_with_time:
			current += total_refill_per_step
			if current > max_credit:
				current = max_credit
		elif character_ref.call(refill_condition): current = max_credit

func _init(data: Dictionary) -> void:
	current = data.current
	max_credit = data.max_credit
	total_refill_per_step = data.total_refill_per_step
	total_use_per_step = data.total_use_per_step
	if "display_type" in data: display_type = data.display_type
	if data.refill_condition == "time": refill_with_time = true
	refill_condition = data.refill_condition


func use() -> void: current -= total_use_per_step
