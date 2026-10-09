class_name World
extends Node

##   For a quick clarification, the Player ALWAYS exists and is active while
## this scene is loaded, so if you need to modify anything of their properties
## just use World.get_player() and you are ready to go.
##   The only bad thing that can potentially happen is that they don't exist for
## some reason, which, is probably just a question of time, until they get
## created or you straight up forgot to add it to the scene. So it's totally
## fine and expected behaviour for the game to crash when it calls for the
## Player where there is no failsafe for them and they don't exist. The only
## problem would be if you need it so early they still don't indeed, so you can
## use wait_for_player(), which does exactly what you think

static var _instance: World = null
static var _player: Player = null


func _ready() -> void:
	World._instance = self


static func get_manager(manager_name: String):
	return _instance.get_node_or_null(manager_name)

static func get_player():
	# Cache player, so we don't keep searching for it every time
	if _player == null:
		_player = _instance.get_node_or_null("Player")
	return _player

## Don't use this function unless you are still waiting for the player to be 
## added into the tree. This should also be used with await, as it's asynchronous
static func wait_for_player():
	var player: Player = null
	var timer = _instance.get_tree().create_timer(1)
	while timer.time_left > 0 and player == null:
		player = _instance.get_node_or_null("Player")
		await _instance.get_tree().create_timer(.1).timeout
	await player.ready
	return player


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
