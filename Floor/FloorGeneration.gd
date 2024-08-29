extends TileMap

var  floor_map = FastNoiseLite.new()
@export var width = 100
@export var height = 100
@export var world_starting_pos: Vector2i
@export var tileTyper:determineTileType

var starting_point: Marker2D
var end_point: Marker2D



func _ready():
	floor_map.seed = randi()
	generate_floor()

func randomize_start():
	starting_point.position.x = randi_range(0,100)
	starting_point.position.y = randi_range(0,100)
	
func radomize_end():
	end_point.position.x = randi_range(0,100)
	end_point.position.y = randi_range(0,100)

func _process(delta):
	generate_floor()

func generate_floor():
	#converts global position to tile map position
	var start_pos = local_to_map(world_starting_pos)
	for x in range(width):
		for y in range(height):
			var tile = floor_map.get_noise_2d( start_pos.x + x, start_pos.y + y)
			var tile_type = tileTyper.determine_tile_type(tile)
			
			var coords = Vector2i(start_pos.x + x, start_pos.y + y)
			set_cell(0, coords, 0, tile_type)
	
	
	


			
