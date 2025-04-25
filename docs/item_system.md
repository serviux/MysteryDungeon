# Item System Documentation

## Overview
The item system consists of several interconnected classes that handle items, weapons, recipes, and inventory management in the game.

## Core Classes

### Item (`Scripts/items/item.gd`)
Base class for all items in the game.

```gdscript
class_name Item
extends Resource

@export var id: String = ""
@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var stackable: bool = false
@export var max_stack_size: int = 1
@export var craftable: bool = false
@export var item_type: String = ""
@export var value: int = 0
```

### Weapon (`Scripts/items/weapon.gd`)
Extends the base Item class with combat-specific properties.

```gdscript
class_name Weapon
extends Item

@export var damage: float = 0.0
```

### RangedWeapon (`Scripts/items/ranged_weapon.gd`)
Specialized weapon class for ranged combat.

```gdscript
class_name RangedWeapon
extends Weapon

enum ATTACK_PATTERN {
    STRAIGHT,
    ARC,
    WAVE
}

@export var range: int = 1
@export var attack_pattern: ATTACK_PATTERN = ATTACK_PATTERN.STRAIGHT
```

### Recipe (`Scripts/items/recipe.gd`)
Handles crafting recipes for items.

```gdscript
class_name Recipe

var result_item_id: String = ""
var number_of_turns: int = 1
var required_items: Dictionary = {}
```

### PlayerInventoryEntry (`Scripts/Player/player_inventory_entry.gd`)
Represents a single slot in the player's inventory.

```gdscript
class_name PlayerInventoryEntry

var item: Item
var quantity: int
```

### PlayerInventory (`Scripts/Player/player_inventory.gd`)
Manages the player's inventory system.

```gdscript
class_name PlayerInventory

signal inventory_changed
signal inventory_full

var entries: Array[PlayerInventoryEntry] = []
var max_size: int = 20
```

## Usage Examples

### Creating Basic Items
```gdscript
# Create a basic item
var potion = Item.new("Health Potion", "Restores health")
potion.id = "health_potion"
potion.stackable = true
potion.max_stack_size = 5
potion.craftable = true
potion.item_type = "consumable"
potion.value = 10
```

### Creating Weapons
```gdscript
# Create a basic weapon
var sword = Weapon.new("Iron Sword", "A basic sword")
sword.id = "iron_sword"
sword.damage = 10.0

# Create a ranged weapon
var bow = RangedWeapon.new("Wooden Bow", "A simple bow")
bow.id = "wooden_bow"
bow.damage = 8.0
bow.range = 5
bow.attack_pattern = RangedWeapon.ATTACK_PATTERN.ARC
```

### Working with Recipes
```gdscript
# Create a recipe
var wooden_sword_recipe = Recipe.new("wooden_sword", 2)  # Takes 2 turns to craft
wooden_sword_recipe.add_requirement("wood", 3)
wooden_sword_recipe.add_requirement("string", 1)
```

### Managing Inventory
```gdscript
# Create an inventory
var inventory = PlayerInventory.new(20)  # 20 slots

# Add items
inventory.add_item(potion, 3)  # Add 3 potions

# Check inventory
var has_potions = inventory.has_item("health_potion", 2)  # Check if we have 2 potions
var potion_count = inventory.get_item_quantity("health_potion")  # Get total potion count

# Remove items
inventory.remove_item("health_potion", 1)  # Remove 1 potion

# Find items
var potion_index = inventory.find("health_potion")  # Find first stack of potions
```

## Key Features

### Items
- Unique ID system
- Stackable items with maximum stack sizes
- Support for different item types
- Built-in crafting flags
- Value system for economy

### Weapons
- Base damage system
- Specialized ranged weapon support
- Multiple attack patterns for ranged weapons

### Recipes
- Turn-based crafting system
- Multiple ingredient support
- Quantity requirements

### Inventory
- Slot-based system
- Stack management
- Item type filtering
- Signals for inventory changes
- Space management

## Best Practices

1. Always set unique IDs for items
2. Use appropriate item types for filtering
3. Set reasonable stack sizes for stackable items
4. Implement proper error handling for inventory operations
5. Listen to inventory signals for UI updates 