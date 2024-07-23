@icon("res://addons/pl_ui/Icons/PLCarouselContainer.svg")
@tool
class_name PLCarouselContainer extends Container
enum CarouselOrientation{
	HORIZONTAL,
	VERTICAL
}
@export_group("Layout")
@export var orientation : CarouselOrientation = CarouselOrientation.HORIZONTAL :
	get: return orientation
	set(value):
		orientation = value
		queue_sort()
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
var dynamic_max_index : int


signal control_changed_index(control : Control, index : int)
var _node_at_center : Node :
	set(value):
		if(value != _node_at_center):
			_node_at_center = value
			node_reached_center.emit(value)
signal node_reached_center(node : Node)

var _left : float = 0
var _left_pad : float = 0
var _total_size_of_children : float = 0

class CarouselItem extends RefCounted:
	# Stores the control, its index, and its size
	var control : Control
	var dynamic_index : int
	var size : float
	func _init(control : Control, dynamic_index : int, size : float):
		self.control = control
		self.dynamic_index = dynamic_index
		self.size = size

var _items : Array[CarouselItem] = []

# Dynamic property handling for editor
func _get_property_list():
	if Engine.is_editor_hint():
		var properties = []
		properties.append({
			"name" : "dynamic_max_index",
			"type" : TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT if dynamic_indices else PROPERTY_USAGE_NO_EDITOR,
		})
		return properties

func _notification(what) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var children = find_children("*", "Control", false, false)
		_layout_children(children)

func _layout_children(children : Array[Node]) -> void:
	# Main layout function to position child controls
	# Calculates total size and creates CarouselItem instances
	if(children.size() == 0):
		return
	_total_size_of_children = 0
	var index = 0
	_items = []
	for child : Node in children:
		var child_size = child.custom_minimum_size.x if orientation == CarouselOrientation.HORIZONTAL else child.custom_minimum_size.y
		if !(child as Control).visible:
			child_size = 0
		_items.push_back(CarouselItem.new(child as Control, index, child_size))
		_total_size_of_children += child_size
		if not Engine.is_editor_hint():
			control_changed_index.emit(_items[index].control, _items[index].dynamic_index)
		index += 1
	_total_size_of_children += (children.size() - 1) * separation	
	
	if(orientation == CarouselOrientation.HORIZONTAL):
		_left =  size.x / 2 -(_total_size_of_children / 2.)
	else:
		_left =  size.y / 2 -(_total_size_of_children / 2.)
	var center_position :float = size.x / 2 if orientation == CarouselOrientation.HORIZONTAL else size.y / 2
	var tracked_position : float = _left + _left_pad
	var passed_center :bool = false

	for item in _items:
		if(orientation == CarouselOrientation.HORIZONTAL):
			_layout_child_horizontal(item.control, tracked_position)
		else:
			_layout_child_vertical(item.control, tracked_position)
		tracked_position += item.size + separation
		if (tracked_position > center_position) and !passed_center:
			passed_center = true
			_node_at_center = item.control

func shift_children() -> void:
	# Repositions children without full layout recalculation
	# Used for scrolling operations
	var tracked_position : float = _left + _left_pad
	var center_position :float = size.x / 2 if orientation == CarouselOrientation.HORIZONTAL else size.y / 2
	var passed_center :bool = false
	for item in _items:
		if(orientation == CarouselOrientation.HORIZONTAL):
			item.control.position.x = tracked_position
		else:
			item.control.position.y = tracked_position
		tracked_position += item.size + separation
		if (tracked_position > center_position) and !passed_center:
				passed_center = true
				_node_at_center = item.control

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	# Restricts size flags when in horizontal mode
	if(orientation == CarouselOrientation.VERTICAL):
		return [SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END, SIZE_FILL]
	else:
		return []

func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	# Restricts size flags when in vertical mode
	if(orientation == CarouselOrientation.HORIZONTAL):
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

func scroll(distance: float):
	# Implements scrolling logic
	# Handles infinite scrolling by wrapping items
	# Updates indices for dynamic indexing
	
	# If there are no items or only one item, scrolling has no effect
	if (_items == null) or (_items.size() < 2):
		return
	
	# Adjust the left padding by the scroll distance
	_left_pad += distance
	
	# Handle non-infinite scrolling
	if(!scroll_infinitely):
		var size_l = _items.back().size
		var size_r = _items.front().size
		_left_pad = clampf(_left_pad, (-_total_size_of_children + size_l) / 2, (_total_size_of_children - size_r) / 2)
		shift_children()
		return
	
	# Infinite scrolling logic starts here
	# Wrap the left padding around the total size of children
	_left_pad = fmod(_left_pad, _total_size_of_children / 2)
	
	var size = _items.back().size
	# Move items from the back to the front if we've scrolled past them
	while _left_pad > size / 2:
		var item = _items.pop_back()
		_items.push_front(item)
		_left_pad -= size + separation
		size = _items.back().size
		
		# Update indices for dynamic indexing
		if dynamic_indices and dynamic_max_index > 0:
			item.dynamic_index = (item.dynamic_index - _items.size()) % dynamic_max_index
			if item.dynamic_index < 0 : item.dynamic_index = dynamic_max_index + item.dynamic_index
			control_changed_index.emit(item.control, item.dynamic_index)
		
	size = _items.front().size
	# Move items from the front to the back if we've scrolled past them
	while _left_pad < -size / 2:
		var item = _items.pop_front()
		_items.push_back(item)
		_left_pad += size + separation
		size = _items.front().size
		
		# Update indices for dynamic indexing
		if dynamic_indices and dynamic_max_index > 0:
			item.dynamic_index = (item.dynamic_index + _items.size()) % dynamic_max_index
			if item.dynamic_index < 0 : item.dynamic_index = dynamic_max_index + item.dynamic_index
			control_changed_index.emit(item.control, item.dynamic_index)
	shift_children()

func get_distance_to_center(control : Control) -> float:
	# Calculates the distance from a control to the center of the carousel
	if(!get_children().has(control)):
		printerr("get_distance_to_center is not intended for use by any controls that aren't direct children of PLCarouselContainer")
		return 0
	match orientation:
		CarouselOrientation.HORIZONTAL:
			return (size.x / 2) - (control.size.x / 2) - control.position.x
		CarouselOrientation.VERTICAL:
			return (size.y / 2) - (control.size.y / 2) - control.position.y
	return 0

func get_control_at_index(index : int) -> Control:
	# Retrieves the control at a specific index
	for item in _items:
		if(item.dynamic_index == index):
			return item.control
	return null

func get_index_distance_to_center(index : int) -> float:
	# Calculates the distance from an indexed item to the center of the carousel
	return get_distance_to_center(get_control_at_index(index))
