class_name PlayerInventory

signal inventory_changed
signal inventory_full

# Array of inventory entries
var entries: Array[PlayerInventoryEntry] = []
var max_size: int = 20

func _init(p_max_size: int = 20) -> void:
	max_size = p_max_size

# Add an item to the inventory
# Returns true if successful, false if failed
func add_item(item: Item, quantity: int = 1) -> bool:
	# Try to find existing stack for stackable items
	if item.stackable:
		var index = find_entry(item.id)
		while index != -1:
			var entry = entries[index]
			var space_left = item.max_stack_size - entry.quantity
			if space_left > 0:
				var amount_to_add = min(space_left, quantity)
				entry.quantity += amount_to_add
				quantity -= amount_to_add
				emit_signal("inventory_changed")
				
				# If we still have items to add, look for another stack
				if quantity <= 0:
					return true
			index = find_entry_at(item.id, index + 1)  # Look for next stack
	
	# If we still have items to add, create new stacks
	while quantity > 0:
		if entries.size() >= max_size:
			emit_signal("inventory_full")
			return false
			
		var stack_size = min(quantity, item.max_stack_size if item.stackable else 1)
		var new_item = item.duplicate_item()
		entries.append(PlayerInventoryEntry.new(new_item, stack_size))
		quantity -= stack_size
		emit_signal("inventory_changed")
	
	return true

# Remove an item from the inventory
# Returns true if successful, false if failed
func remove_item(item_id: String, quantity: int = 1) -> bool:
	var remaining = quantity
	var indices_to_remove: Array[int] = []
	
	# First pass: try to remove from existing stacks
	var index = find_entry(item_id)
	while index != -1:
		var entry = entries[index]
		if entry.quantity <= remaining:
			remaining -= entry.quantity
			indices_to_remove.append(index)
		else:
			entry.quantity -= remaining
			remaining = 0
			emit_signal("inventory_changed")
			return true
		index = find_entry_at(item_id, index + 1)
	
	# If we found all items to remove
	if remaining == 0:
		# Remove from highest index to lowest to avoid shifting issues
		indices_to_remove.sort()
		indices_to_remove.reverse()
		for idx in indices_to_remove:
			entries.remove_at(idx)
		emit_signal("inventory_changed")
		return true
	
	return false

# Get the total quantity of an item in the inventory
func get_item_quantity(item_id: String) -> int:
	var total = 0
	var index = find_entry(item_id)
	while index != -1:
		total += entries[index].quantity
		index = find_entry_at(item_id, index + 1)
	return total

# Check if we have enough of an item
func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_quantity(item_id) >= quantity

# Get current number of slots used in inventory
func get_used_slots() -> int:
	return entries.size()

# Check if inventory has space
func has_space() -> bool:
	return entries.size() < max_size

# Get remaining space in inventory
func get_remaining_space() -> int:
	return max_size - entries.size()

# Clear the inventory
func clear() -> void:
	entries.clear()
	emit_signal("inventory_changed")

# Get all items of a specific type
func get_items_by_type(item_type: String) -> Array[PlayerInventoryEntry]:
	var result: Array[PlayerInventoryEntry] = []
	for entry in entries:
		if entry.item.item_type == item_type:
			result.append(entry)
	return result

# Find an entry by item ID
# Returns null if not found
func find_entry(item_id: String) -> int:
	for i in range(entries.size()):
		if entries[i].item.id == item_id:
			return i
	return -1

# Overloaded version of find that starts searching from a specific index
# Useful for finding multiple stacks of the same item
func find_entry_at(item_id: String, start_index: int = 0) -> int:
	for i in range(start_index, entries.size()):
		if entries[i].item.id == item_id:
			return i
	return -1 
