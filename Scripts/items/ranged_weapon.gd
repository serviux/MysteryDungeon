extends Weapon
class_name RangedWeapon

enum ATTACK_PATTERN {
	STRAIGHT,
	ARC,
	WAVE
}

@export var range: int = 1
@export var attack_pattern: ATTACK_PATTERN = ATTACK_PATTERN.STRAIGHT

func _init(p_name: String = "", p_description: String = "") -> void:
	super._init(p_name, p_description)
	item_type = "ranged_weapon"

# Override duplicate to include ranged weapon-specific properties
func duplicate_item() -> RangedWeapon:
	var new_weapon = super.duplicate_item() as RangedWeapon
	new_weapon.range = range
	new_weapon.attack_pattern = attack_pattern
	return new_weapon 
