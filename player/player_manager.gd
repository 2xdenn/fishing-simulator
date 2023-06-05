extends Node

var player
var rod
var bobber
var fishing_line

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)
	
func equip_slot_data(slot_data: SlotData) -> void:
	#slot_data.item_data.use(player)
	pass
func equip_rod_slot_data() -> void:
	#print("equip it")
	
	rod.visible = not rod.visible
	bobber.visible = not bobber.visible
	bobber.global_position = Vector3(0,20,0)
	fishing_line.visible = not fishing_line.visible
	rod.active = not rod.active
	
	#bobber.remove_child
	
	#rod.visible = true
func play_pickup_noise() -> void:
	player.pickup_sound.play()

func get_global_position() -> Vector3:
	return player.global_position
