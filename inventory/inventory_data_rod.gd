extends InventoryData
class_name InventoryDataRod

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataRod:
		return grabbed_slot_data
	
	print("equip fishing rod")
	PlayerManager.equip_rod_slot_data()
	
	return super.drop_slot_data(grabbed_slot_data, index)
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if not grabbed_slot_data.item_data is ItemDataRod:
		return grabbed_slot_data
		
	return super.drop_single_slot_data(grabbed_slot_data, index)

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	if slot_data:
		print("unequip fishing rod")
		PlayerManager.equip_rod_slot_data()
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null
