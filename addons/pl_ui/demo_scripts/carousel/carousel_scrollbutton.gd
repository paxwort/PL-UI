#DEMO DISCLAIMER!!
#This is here to demonstrate the functionality of this package
#It works fine, and might be good, but it's not particularly polished and not intended to be used
#Do what you want, but I don't necessarily stand by this code

@tool extends Button
@export var scrollspeed : float = 0
@export var carousel : PLCarouselContainer
func _process(delta):
	if button_pressed:
		carousel.scroll(scrollspeed)
