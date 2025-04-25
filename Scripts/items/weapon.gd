extends Item
class_name Weapon

@export var damage: float = 0.0

func _init(p_name: String = "", p_description: String = "") -> void:
	super._init(p_name, p_description)
	item_type = "weapon"

# Override duplicate to include weapon-specific properties
func duplicate_item() -> Weapon:
	var new_weapon = super.duplicate_item() as Weapon
	new_weapon.damage = damage
	return new_weapon 
