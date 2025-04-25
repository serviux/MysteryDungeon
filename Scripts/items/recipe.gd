class_name Recipe

# The item ID that this recipe will create
var result_item_id: String = ""

# Dictionary storing the required items and their quantities
# Key: item_id (String), Value: quantity (int)
var required_items: Dictionary = {}

func _init(p_result_id: String = "") -> void:
	result_item_id = p_result_id

# Add a required item to the recipe
func add_requirement(item_id: String, quantity: int) -> void:
	required_items[item_id] = quantity

# Remove a required item from the recipe
func remove_requirement(item_id: String) -> void:
	if required_items.has(item_id):
		required_items.erase(item_id)

# Check if all requirements are met given a dictionary of available items
# available_items should be Dictionary[String, int] where key is item_id and value is quantity
func can_craft(available_items: Dictionary) -> bool:
	for required_id in required_items:
		var required_quantity = required_items[required_id]
		if not available_items.has(required_id) or available_items[required_id] < required_quantity:
			return false
	return true

# Get the list of missing items and their quantities needed to craft
# available_items should be Dictionary[String, int] where key is item_id and value is quantity
func get_missing_requirements(available_items: Dictionary) -> Dictionary:
	var missing_items: Dictionary = {}
	
	for required_id in required_items:
		var required_quantity = required_items[required_id]
		var available_quantity = available_items.get(required_id, 0)
		
		if available_quantity < required_quantity:
			missing_items[required_id] = required_quantity - available_quantity
	
	return missing_items 
