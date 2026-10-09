class_name Demo
extends Node

static func unload_current_level():
	(World.get_manager("LevelManager") as LevelManager)\
		.unload_level(World.get_current_level())
