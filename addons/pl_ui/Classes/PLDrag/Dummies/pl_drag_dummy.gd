@icon("res://addons/pl_ui/Icons/PLDragDummy.svg")
class_name PLDragDummy extends Control
@onready var _container : Container = get_parent() as Container:
	set(value) :
		_container = value
		update_configuration_warnings()

func _ready():
	visible = false

func _get_configuration_warnings():
	return []

func find_best_index(position : Vector2) -> int:
	return _container.get_child_count()
