@icon("res://addons/pl_ui/Icons/PLDragTarget.svg")
@tool class_name PLDragTarget extends Control
var _container : Container
var _dummy = PLDragDummy

@export var item_limit : int = 0
signal control_dragged_added(node : Node)
signal control_dragged_removed(node : Node)

func _get_configuration_warnings():
	var containers = find_children("*", "Container", false, false)
	if(containers.size() != 1):
		return ["Drag Target requires a single container!"]
	var dummies = containers[0].find_children("*", "PLDragDummy", false, false)
	if dummies.size() == 0:
		return ["Drag Target requires a single container with a DragDummy!"]
	return []
	
func _notification(what) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		update_configuration_warnings()

func _ready():
	mouse_exited.connect(_on_mouse_exited)
	update_configuration_warnings()
	if _get_configuration_warnings().size() > 0:
		return
	if Engine.is_editor_hint():
		return
	var containers = find_children("*", "Container", false, false)
	_container = containers[0]
	var dummies = containers[0].find_children("*", "PLDragDummy", false, false)
	_dummy = dummies[0]
	for draggable in _container.find_children("*", "PLDraggable"):
		draggable.completed_drag.connect(_draggable_completed_drag.bind(draggable))

func _on_mouse_exited():
	if _dummy != null:
		_dummy.visible = false

func _can_drop_data(at_position : Vector2, data:Variant) -> bool:
	if(_container.get_children().size() - 1 >= item_limit) and (item_limit > 0):
		return false
	if data is Control:
		_dummy.visible = true
		var index = _dummy.find_best_index(_container.get_transform() * at_position)
		_container.move_child(_dummy, max(0, index))
		return true
	else:
		return false

func _drop_data(at_position, data):
	data.reparent(_container)
	var index = _dummy.find_best_index(_container.get_transform() * at_position)
	_dummy.visible = false
	_container.move_child(data, index)
	if data as PLDraggable != null:
		data.completed_drag.emit()
		data.completed_drag.connect(_draggable_completed_drag.bind(data))
	control_dragged_added.emit(data)

func _draggable_completed_drag(node : Node):
	if !_container.get_children().has(node):
		if node as PLDraggable != null:
			node.completed_drag.disconnect(_draggable_completed_drag)
		control_dragged_removed.emit(node)
		
	
