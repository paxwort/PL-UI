#DEMO DISCLAIMER!!
#This is here to demonstrate the functionality of this package
#It works fine, and might be good, but it's not particularly polished and not intended to be used
#Do what you want, but I don't necessarily stand by this code

extends Node
var index : int

func _ready():
	get_parent().control_changed_index.connect(_on_index_changed)


func _on_index_changed(control : Control, index : int):
	if(control == self):
		self.index = index
		$RichTextLabel.text = "\n[center]" + str(index)
