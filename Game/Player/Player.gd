extends Node

const PLAYER_TEXTURES = {
	"Red": preload("res://Assets/Players/Player-Red.png"),
	"Blue": preload("res://Assets/Players/Player-Blue.png"),
	"Green": preload("res://Assets/Players/Player-Green.png"),
	"Yellow": preload("res://Assets/Players/Player-Yellow.png")
}

onready var tile = get_parent().get_parent()
onready var grid = tile.grid

var controller_id
var texture

func _unhandled_input(event):
	if GameManager.cur_phase == GameManager.TurnPhases.MovePlayer and GameManager.active_player_id == Network.my_player_id:
		if controller_id == Network.my_player_id:
			if event is InputEventKey:
				if event.pressed and event.scancode == KEY_UP:
					rpc("move", grid.Directions.UP)
				elif event.pressed and event.scancode == KEY_RIGHT:
					rpc("move", grid.Directions.RIGHT)
				elif event.pressed and event.scancode == KEY_DOWN:
					rpc("move", grid.Directions.DOWN)
				elif event.pressed and event.scancode == KEY_LEFT:
					rpc("move", grid.Directions.LEFT)

remotesync func move(direction):
	var player_clone = tile.player_scene.instance()
	player_clone.name = name
	player_clone.controller_id = controller_id
	player_clone.texture = texture
	
	var next_y
	var next_x
	var opp_dir
	match direction:
		grid.Directions.UP:
			next_y = tile.grid_pos.y - 1
			next_x = tile.grid_pos.x
			opp_dir = grid.Directions.DOWN
		grid.Directions.RIGHT:
			next_y = tile.grid_pos.y
			next_x = tile.grid_pos.x + 1
			opp_dir = grid.Directions.LEFT
		grid.Directions.DOWN:
			next_y = tile.grid_pos.y + 1
			next_x = tile.grid_pos.x
			opp_dir = grid.Directions.UP
		grid.Directions.LEFT:
			next_y = tile.grid_pos.y
			next_x = tile.grid_pos.x - 1
			opp_dir = grid.Directions.RIGHT
	if (next_y == 7 or next_y == -1) or (next_x == 7 or next_x == -1): return
	
	var next_tile = grid.get_child(next_y).get_child(next_x)
	if tile.directions[direction] == 0 or next_tile.directions[opp_dir] == 0: return
	
	next_tile.players.add_child(player_clone)
	next_tile.update_objects()
	tile.players.remove_child(self)
	tile.update_objects()