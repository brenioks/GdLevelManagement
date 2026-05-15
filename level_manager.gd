extends Node

@export var start_level_number: int = 1
@export_group("References")
@export var levels_dir: String = "res://"

var level_list: Array[PackedScene]
var current_level_index: int = 0
var current_level_node: Node

signal level_loaded(level_number: String)
signal level_ended


func _ready() -> void:
	if not World.player:
		push_error("LevelManager: reference to Player (from World) not found!")
		get_tree().quit()
		breakpoint
		return

	# Cache levels in array
	var scene_files = ResourceLoader.list_directory(levels_dir)
	for scene_name in scene_files:
		# Skip non-levels
		if not scene_name.ends_with(".tscn"): continue
		var level_number = scene_name.to_int()

		level_list.resize(level_number + 1)
		level_list[level_number] = load(levels_dir + scene_name)

	# Clear whatever gibberish that is inside this node
	for child in get_children():
		child.queue_free()

	start_level(start_level_number)
	level_ended.connect(_on_level_ended)

func start_level(level_number: int) -> void:
	var levelScene = level_list.get(level_number)
	if not levelScene:
		printerr("Level %s not recognized" % level_number)
		return

	# Unload last level
	if current_level_node:
		current_level_node.queue_free()

	# Load new level
	var level_node = levelScene.instantiate()
	call_deferred("add_child", level_node)
	current_level_index = level_number
	current_level_node = level_node

	World.player.velocity = Vector2.ZERO
	await get_tree().create_timer(.1).timeout
	level_loaded.emit()


func _on_level_ended():
	start_level(current_level_index + 1)
