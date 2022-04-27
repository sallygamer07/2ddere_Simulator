extends Node2D

onready var tex_rect = $TextureRect

var item_name
var item_quantity

func _ready():
	if item_name != null:
		tex_rect.texture = load("res://graphics/objects/" + item_name + ".png")
		var stack_size = int(JsonData.item_data[item_name]["StackSize"])
		item_quantity = randi() % stack_size + 1

		
func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	tex_rect.texture = load("res://graphics/objects/" + item_name + ".png")
	tex_rect.rect_min_size = Vector2(64, 64)
	tex_rect.rect_size = tex_rect.rect_min_size
	
	var _stack_size = int(JsonData.item_data[item_name]["StackSize"])

		
	#tex_rect.hint_tooltip = JsonData.item_data[item_name]["Description"]
		
		
#func add_item_quantity(amount_to_add):
#	item_quantity += amount_to_add
#	label.text = String(item_quantity)
#
#func decrease_item_quantity(amount_to_remove):
#	item_quantity -= amount_to_remove
#	label.text = String(item_quantity)
