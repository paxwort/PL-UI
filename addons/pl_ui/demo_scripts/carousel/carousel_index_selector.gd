#DEMO DISCLAIMER!!
#This is here to demonstrate the functionality of this package
#It works fine, and might be good, but it's not particularly polished and not intended to be used
#Do what you want, but I don't necessarily stand by this code

class_name carousel_index_selector extends Button
@onready var index = get_index()
@export var carousel : PLCarouselContainer
signal index_selected(index : int)

func _ready():
	carousel.node_reached_center.connect(_on_node_at_center_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_node_at_center_changed(node : Node):
	if(node == self):
		disabled = true
	else:
		disabled = false

func _pressed():
	index_selected.emit(index)
