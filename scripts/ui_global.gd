extends Node

var dragging_frame := false :
	set(value):
		dragging_frame = value
		player_dragging_frame.emit(value)

var ableToDragFrame := true

signal player_dragging_frame
