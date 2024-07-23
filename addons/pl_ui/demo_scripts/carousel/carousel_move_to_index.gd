#DEMO DISCLAIMER!!
#This is here to demonstrate the functionality of this package
#It works fine, and might be good, but it's not particularly polished and not intended to be used
#Do what you want, but I don't necessarily stand by this code

extends Node

@export var duration : float = 0.5
@export var smoothing : float = 0.1  # Smoothing factor (0.0 to 1.0)
var target : int
var moving : bool
@export var carousel : PLCarouselContainer
var current_movement : float = 0.0  # New variable to track current movement
var start_distance : float = 0.0  # Track starting distance
var progress : float = 0.0

func _ready():
	for child in get_children():
		if child is carousel_index_selector:
			child.index_selected.connect(set_target)

func set_target(index : int):
	target = index
	moving = true
	start_distance = carousel.get_index_distance_to_center(target)
	progress = 0.0

func _process(delta):
	if moving:
		progress += delta / duration
		var current_distance = carousel.get_index_distance_to_center(target)
		var desired_distance = lerp(start_distance, 0.0, progress)
		var move = current_distance - desired_distance
		carousel.scroll(sign(current_distance) * min(abs(move), abs(current_distance)))
		if abs(current_distance) <= abs(move):
			moving = false
			current_movement = 0.0 
