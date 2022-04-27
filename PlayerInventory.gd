extends Node

signal get_item_label(item_name)

signal active_item_updated

const SlotClass = preload("res://Player/Slot.gd")
const ItemClass = preload("res://Player/Item.gd")
const NUM_HOTBAR_SLOTS = 8

var hotbar = {}

var active_item_slot = 0


func get_item(item_name : String):
	for item in hotbar:
		if hotbar[item][0] == item_name:
			return hotbar[item][1]

			
func update_slot_visual(slot_index : int, item_name, new_quantity):
	var slot = get_tree().root.get_node("/root/" + str(Global.player.data["level"]) + "/CanvasLayer/UI/HotBar/HotBarSlots/HotBarSlot" + str(slot_index + 1))
	if slot != null and slot.item != null:
		slot.item.set_item(item_name, new_quantity)

func remove_item(slot : SlotClass):
	if slot != null:
		hotbar.erase(slot.slot_index)
		

		
	
func add_item_to_empty_slot(item : ItemClass, slot : SlotClass):
	hotbar[slot.slot_index] = [item.item_name, item.item_quantity]
	
	
func add_item_quantity(slot : SlotClass, quantity_to_add : int):
	hotbar[slot.slot_index][1] += quantity_to_add
	
func remove_item_quest(type : String, amount : int):
	for item in hotbar:
		if hotbar[item][0] == type and hotbar[item][1] >= amount:
			hotbar[item][1] -= amount
			if hotbar[item][1] == 0:
				hotbar.erase(type)
			update_slot_visual(item, hotbar[item][0], hotbar[item][1])
			return true
			
func active_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	Global.player.switch_weapon()
	emit_signal("active_item_updated")
	
func active_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	Global.player.switch_weapon()
	emit_signal("active_item_updated")
	
func quest_succ() -> bool:
	return true
