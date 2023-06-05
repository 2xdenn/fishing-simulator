extends Node3D

@onready var fish_bubbles = preload("res://scenes/fish_bubbles.tscn")
var bubbles

# Called when the node enters the scene tree for the first time.
func _ready():
	bubbles = fish_bubbles.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
