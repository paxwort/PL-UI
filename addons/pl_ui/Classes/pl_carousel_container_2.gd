class_name PLCarouselContainer2 extends BoxContainer

@export_group("Layout")

@export var separation : int = 0:
	get: return separation
	set(value):
		separation = value
		queue_sort()

@export_group("Behaviour")
@export var scroll_infinitely : bool = false:
	get: return scroll_infinitely
	set(value):
		scroll_infinitely = value
		queue_sort()

@export var dynamic_indices : bool:
	set(value):
		dynamic_indices = value
		notify_property_list_changed()
var max_dynamic_index : int

var _dynamic_indices : Dictionary

var _left : float = 0
var _left_pad : float = 0
var _total_size_of_children : float = 0

func _get_property_list():
	if Engine.is_editor_hint():
		var properties = []
		properties.append({
			"name" : "max_dynamic_index",
			"type" : TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT if dynamic_indices else PROPERTY_USAGE_NO_EDITOR,
		})
		return properties

func _notification(what) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var children = find_children("*", "Control", false, false)
		_layout_children(children)

func _layout_children(children : Array[Node]) -> void:
	_total_size_of_children = 0
	#calculate total size of children
	for child : Node in children:
		var control = child as Control
		if(vertical):
			_total_size_of_children += control.custom_minimum_size.y + separation
	if(vertical):
		_left =  size.y / 2 -(_total_size_of_children / 2.)
	else:
		_left =  size.x / 2 -(_total_size_of_children / 2.)

	var tracked_position : float = _left + _left_pad
	var center_position :float = size.y / 2 if vertical else size.x / 2
	for child : Node in children:
		if(vertical):
			_layout_child_vertical(child, tracked_position)
			tracked_position += (child as Control).custom_minimum_size.y + separation
		else:
			_layout_child_horizontal(child, tracked_position)
			tracked_position += (child as Control).custom_minimum_size.x + separation
	

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	# Restricts size flags when in horizontal mode
	if(vertical):
		return [SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END, SIZE_FILL]
	else:
		return []

func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	# Restricts size flags when in vertical mode
	if(!vertical):
		return [SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END, SIZE_FILL]
	else:
		return []

func _layout_child_horizontal(child : Control, tracked_position : float) -> void:
	# Positions and sizes a child control in horizontal orientation
	child.position.x = tracked_position
	child.size.x = child.custom_minimum_size.x
	match child.size_flags_vertical:
		SIZE_FILL:
			child.size.y = size.y
			child.position.y = 0
		SIZE_SHRINK_BEGIN:
			child.size.y = child.custom_minimum_size.y
			child.position.y = 0
		SIZE_SHRINK_CENTER:
			child.size.y = child.custom_minimum_size.y
			child.position.y = size.y / 2 - child.size.y / 2
		SIZE_SHRINK_END:
			child.size.y = child.custom_minimum_size.y
			child.position.y = size.y - child.size.y
		_:
			child.size.y = child.custom_minimum_size.y
			child.position.y = 0

func _layout_child_vertical(child : Control, tracked_position : float) -> void:
	# Positions and sizes a child control in vertical orientation
	child.position.y = tracked_position
	child.size.y = child.custom_minimum_size.y
	match child.size_flags_horizontal:
		SIZE_FILL:
			child.size.x = size.x
			child.position.x = 0
		SIZE_SHRINK_BEGIN:
			child.size.x = child.custom_minimum_size.x
			child.position.x = 0
		SIZE_SHRINK_CENTER:
			child.size.x = child.custom_minimum_size.x
			child.position.x = size.x / 2 - child.size.x / 2
		SIZE_SHRINK_END:
			child.size.x = child.custom_minimum_size.x
			child.position.x = size.x - child.size.x
		_:
			child.size.x = child.custom_minimum_size.x
			child.position.x = 0
