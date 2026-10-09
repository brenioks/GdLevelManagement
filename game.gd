extends Node


func _wait_for_node(parent, _name) -> Node:
	var node: Node = null
	var timer = get_tree().create_timer(1)
	while timer.time_left > 0 and node == null:
		node = parent.get_node_or_null(_name)
	if node == null:
		push_error("Couldn't find any node called '%s'. Timeout" % _name)
	return node

func wait_for_world() -> World:
	var world: World = null
	var timer = get_tree().create_timer(1)
	while timer.time_left > 0 and world is not World:
		world = get_tree().current_scene
	return world
