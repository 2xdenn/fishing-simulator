extends RayCast3D

@onready var point_1 = get_node("%Point_1")
@onready var point_2 = get_node("%Point_2")
@onready var line = get_node("%Line")

func _ready():
	visible = false

func _process(_delta):
	self.look_at_from_position((point_1.global_position + point_2.global_position) / 2, point_2.global_position, Vector3.UP)
	line.mesh.height = point_1.global_position.distance_to(point_2.global_position)
