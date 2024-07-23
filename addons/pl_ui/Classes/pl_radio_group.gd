@icon("res://addons/pl_ui/Icons/PLRadioGroup.svg")
@tool class_name PLRadioGroup extends Control
var _container : Container
var _radio_buttons : Array[BaseButton]

@export var selected_index : int
signal selection_changed(index)

func _get_configuration_warnings():
	var containers = find_children("*", "Container", false, false)
	if(containers.size() == 0):
		return ["Radio group requires a container child to hold its buttons!"]	
	
func _notification(what) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		update_configuration_warnings()

func _ready():
	update_configuration_warnings()
	var containers = find_children("*", "Container", false, false)
	_container = containers[0]
	_get_button_children()
	child_order_changed.connect(_get_button_children)
	_container.child_order_changed.connect(_get_button_children)
	_resolve_pressed_buttons(selected_index)

func _get_button_children():
	if(_radio_buttons != null):
		for button in _radio_buttons:
			button.pressed.disconnect(_on_button_pressed)
		
	_radio_buttons = []
	for button in _container.find_children("*", "BaseButton", false, false):
		_radio_buttons.append(button)
		button.pressed.connect(_on_button_pressed.bind(button.get_index()))

func _on_button_pressed(index : int):
	_resolve_pressed_buttons(index)
	selection_changed.emit(index)

func _resolve_pressed_buttons(index : int):
	if(_radio_buttons != null):
		for button in _radio_buttons:
			if(button.get_index() != index):
				button.button_pressed = false
			else:
				button.button_pressed = true
