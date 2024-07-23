class_name PLDragDummyGrid extends PLDragDummy

func _get_configuration_warnings():
	if !_container is GridContainer:
		return ["Parent container must be grid container!"]
	return []
	
	
func find_best_index(position : Vector2) -> int:
	if _get_configuration_warnings().size() > 0:
		return 0
	var grid_container = _container as GridContainer
	var column_width = grid_container.size.x / (grid_container.columns as float)
	var column_idx : int = min(grid_container.columns - 1, (position.x / column_width))
	var row_idx : int = position.y / column_width
	var idx = row_idx * grid_container.columns + column_idx
	return min(grid_container.get_child_count() - 1, idx)
