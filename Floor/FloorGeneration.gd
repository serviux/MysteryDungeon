extends TileMap

var  floor_map = FastNoiseLite.new()
@export var width = 100
@export var height = 100
@export var world_starting_pos: Vector2i
@export var tileTyper:determineTileType




func _ready():
	floor_map.seed = randi()
	generate_floor()



func _process(delta):
	pass

func generate_floor():
	#converts global position to tile map position
	var start_pos = local_to_map(world_starting_pos)
	for x in range(width):
		for y in range(height):
			var tile = floor_map.get_noise_2d( start_pos.x + x, start_pos.y + y)
			var tile_type = tileTyper.determine_tile_type(tile)
			
			var coords = Vector2i(start_pos.x + x, start_pos.y + y)
			set_cell(0, coords, 0, tile_type)
			


