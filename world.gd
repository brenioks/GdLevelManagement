class_name World
extends Node

static var _instance: World = null


func _ready() -> void:
	World._instance = self


static func get_manager(manager_name: String):
	return _instance.get_node_or_null(manager_name)

static func get_player():
	# Cache player, so we don't keep searching for it every time
	if _player == null:
		_player = _instance.get_node_or_null("Player")
	return _player


# Level related
static func get_current_level() -> int:
	return World.get_manager("LevelManager").current_level_index

static func begin_level(level) -> void:
	var level_manager = World.get_manager("LevelManager")
	level_manager.level_ended.emit()
	# NOTE: Provavelmente fazer algo tipo uma transição aqui
	level_manager.begin_level(level)

static func next_level() -> void:
	World.begin_level(World.get_current_level() + 1)
