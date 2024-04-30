extends TileMap

var  floor_map = FastNoiseLite.new()
@export var width = 100
@export var height = 100
@export var world_starting_pos: Vector2i


const WALL = Vector2i(1,0)
const FLUID = Vector2i(0,0)
const GROUND = Vector2i(2,0)

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
			tile = int(abs(tile) * 10)
				
			var tile_type = WALL
			if(tile == 0):
				tile_type = FLUID
			elif(tile == 1):
				tile_type = GROUND
			elif(tile == 2):
				tile_type = WALL
			
			print("Raw tile value: %s, tile_type: %s" % [tile, tile_type] )
			
			var coords = Vector2i(start_pos.x + x, start_pos.y + y)
			set_cell(0, coords, 0, tile_type)

