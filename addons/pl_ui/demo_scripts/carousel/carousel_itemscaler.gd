#DEMO DISCLAIMER!!
#This is here to demonstrate the functionality of this package
#It works fine, and might be good, but it's not particularly polished and not intended to be used
#Do what you want, but I don't necessarily stand by this code

extends Control
@export var size_curve : Curve
@export var max_distance : float


func _process(delta):
	var dist = get_parent().get_distance_to_center(self)
	var scale : float = size_curve.sample(abs(dist) / max_distance)
	$Child.custom_minimum_size = Vector2(scale, scale)
	$Child.size = Vector2(scale, scale)
	$Child.position = size / 2 - $Child.size / 2
