extends RigidBody3D

signal toggle_inventory(external_inventory_owner)

@onready var main = get_node("/root/Main")
@onready var pickup: PackedScene = preload("res://item/pick_up/pick_up.tscn")
@export var inventory_data: InventoryData
var jump: bool = true
var outlineVisible: bool = false
var pointOfCollection: Vector3

func player_interact() -> void:
	pointOfCollection = self.global_position
	drop_pickup()

func _on_jump_timer_timeout():
	jump = true

func _physics_process(delta):
	if outlineVisible:
		$Outline.visible = true
	else:
		$Outline.visible = false
	if jump:
		$LocustSound.play()
		apply_impulse(Vector3(0,3,0))
		apply_impulse(global_transform.basis.z * 4)
		$JumpTimer.start()
		jump = false
func drop_pickup():
	var locustPickup = pickup.instantiate()
	locustPickup.slot_data.item_data = preload("res://item/items/desert_locust.tres")
	main.add_child(locustPickup)
	locustPickup.global_position = pointOfCollection
	queue_free()
