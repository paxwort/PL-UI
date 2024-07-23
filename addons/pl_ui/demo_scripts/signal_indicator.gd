@tool extends Label

var signal_color_waiting : Color = Color.LIGHT_GREEN
var signal_color_activated : Color = Color.GREEN_YELLOW
var tween : Tween

func _ready():
	label_settings.font_color = signal_color_waiting

func recieve_signal(arg : Variant = null, arg2 : Variant = null):
	_activate()
	
func _activate():
	if(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(label_settings, "font_color", signal_color_activated, 0.05)
	tween.tween_callback(self._release)
	
func _release():
	if(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(label_settings, "font_color", signal_color_waiting, 0.5)
