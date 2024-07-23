@tool
class_name RadialContainer extends Container
enum RadialContainerMode{
	FIT_RECT = 0,
	DIRECT_RADIUS = 1
}
@export_group("Radius")
@export var mode : RadialContainerMode :
	get:
		return mode
	set(value):
		mode = value
		queue_sort()
@export var radius : int :
	get:
		return radius
	set(value):
		radius = value
		queue_sort()
@export var start : float :
	get:
		return start
	set(value):
		start = value
		queue_sort()
@export var end : float :
	get:
		return end
	set(value):
		end = value
		queue_sort()
		
var radius_internal : int :
	get:
		match(mode):
			RadialContainerMode.DIRECT_RADIUS:
				return radius
			RadialContainerMode.FIT_RECT:
				return min(size.x, size.y)/2
		return radius


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		var children = find_children("*", "Control", false)
		for n in range(0,children.size(), 1):
			children[n].position = get_child_position(n, children.size()) + (size / 2) - (children[n].size/2)

func get_child_position(index : int, num_children : int) -> Vector2:
	var theta_per_index = ((end-start) as float / (num_children) as float) * 2. * PI
	var child_theta = (index + 0.5) * theta_per_index + (start * 2. * PI)
	return Vector2(-sin(child_theta), cos(child_theta)) * radius_internal
