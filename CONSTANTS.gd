class_name GameConstants
extends Node


const WALL = Vector2i(1,0)
const FLUID = Vector2i(0,0)
const GROUND = Vector2i(2,0)
const STAIRS = Vector2i(0,1)

enum DIRECTION {
	NORTH,
	NORTH_EAST,
	EAST,
	SOUTH_EAST,
	SOUTH,
	SOUTH_WEST,
	WEST,
	NORTH_WEST
}

enum TILE_IDX {
	GROUND = 0, 
	WALL = 1,
	FLUID = 2,
	ITEM = 3,
	TRAP = 4
}
