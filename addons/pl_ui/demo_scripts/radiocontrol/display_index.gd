extends RichTextLabel
var index : int

func _on_index_changed(index : int):
	self.index = index
	text = "[center]Selection:\n[font_size=24][color=goldenrod]" + str(index)
