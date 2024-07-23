class_name PLDragDummyCarousel extends PLDragDummy

func _get_configuration_warnings():
	if !_container is PLCarouselContainer:
		return ["Parent container must be PLCarouselContainer!"]
	return []
	
	
func find_best_index(position : Vector2) -> int:
	if _get_configuration_warnings().size() > 0:
		return 0
	var best_control : Control = null
	var best_dist : float = INF
	var best_difference : Vector2 = Vector2(INF, INF)
	for child : Control in _container.find_children("*", "Control", false, false):
		if(child == self):
			continue
		var center = child.get_rect().get_center()
		var dist = (position - child.position).length_squared()
		if(dist < best_dist):
			best_dist = dist
			best_difference = position - center
			best_control = child
	if best_control == null:
		return 0
	var dist_in_container = best_difference.y if (_container as PLCarouselContainer).orientation == PLCarouselContainer.CarouselOrientation.VERTICAL else best_difference.x
	var index_offset = 0
	if best_control.is_layout_rtl():
		index_offset = clamp(-sign(dist_in_container), 0, 1)
	else:
		index_offset = clamp(sign(dist_in_container), 0, 1)
	var best_index = best_control.get_index() + index_offset
	if(best_index > self.get_index()):
		return best_index - 1
	return best_index
