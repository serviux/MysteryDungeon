extends determineTileType

func determine_tile_type(tile:float):
		tile = int(abs(tile) * 100)
		var tile_type = CONSTANTS.WALL
		if(tile < 20):
			tile_type = CONSTANTS.WALL
		elif(tile > 20 and tile < 60):
			tile_type = CONSTANTS.GROUND
		elif(tile > 60):
			tile_type = CONSTANTS.FLUID
		return tile_type
