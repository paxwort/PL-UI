@icon("res://addons/pl_ui/Icons/PLDraggable.svg")
class_name PLDraggable extends Control

signal begun_drag
signal completed_drag

func _get_drag_data(at_position : Vector2) -> Variant:
	set_drag_preview(self.duplicate())
	begun_drag.emit()
	return self
