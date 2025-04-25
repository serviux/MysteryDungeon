extends Resource
class_name Item

# Basic item properties
@export var id: String = ""  # Unique identifier for the item
@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var stackable: bool = false
@export var max_stack_size: int = 1
@export var craftable: bool = false  # Whether the item can be crafted

# Optional properties depending on your game's needs
@export var item_type: String = ""  # Could be "weapon", "consumable", "key_item", etc.
@export var value: int = 0

func _init(p_name: String = "", p_description: String = "") -> void:
	item_name = p_name
	description = p_description

# Method to create a copy of the item
func duplicate_item() -> Item:
	var new_item = Item.new(item_name, description)
	new_item.id = id
	new_item.icon = icon
	new_item.stackable = stackable
	new_item.max_stack_size = max_stack_size
	new_item.item_type = item_type
	new_item.value = value
	new_item.craftable = craftable
	return new_item

# Add any additional methods specific to your item system here 
