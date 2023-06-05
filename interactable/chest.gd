extends StaticBody3D

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData
var outlineVisible = false

func player_interact() -> void:
	toggle_inventory.emit(self)

func _process(delta):
	if outlineVisible:
		$Outline.visible = true
	else:
		$Outline.visible = false
