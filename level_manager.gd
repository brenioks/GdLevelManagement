class_name LevelManager
extends Node

@export var start_level: PackedScene
@export_group("References")
@export var levels_dir: String = "res://"

var level_list: Array[PackedScene]
var levelname_list: Array[String]
var current_level_index: int = -1
var current_level_name: StringName
var current_level_node: Node2D

signal level_loaded(level_name: StringName, level_index: int)
signal level_unloaded(level_name: StringName, level_index: int)
signal level_begun(level_name: StringName, level_index: int)
signal level_ended(level_name: StringName, level_index: int)

var debug_label: Label
var _first_level := true


func _ready() -> void:
	# Erase anything that is inside this node for some reason
	for child in get_children():
		child.queue_free()
	
	debug_label = Label.new()
	debug_label.z_index = 1
	add_child(debug_label)
	
	_setup_level_lists()
	
	begin_level(start_level)

func _setup_level_lists() -> void:
	var scene_files: Array = ResourceLoader.list_directory(levels_dir)
	scene_files = scene_files.filter(file_is_level)
	# Set the lists' sizes 
	level_list.resize(scene_files.size())
	levelname_list.resize(scene_files.size())
	# Add level scenes and names to their respectiive lists, at the same index
	for i in range(scene_files.size()):
		var scene_name: String = scene_files[i]
		var level_name: StringName = scene_name.get_file().get_slice('.', 0)
		levelname_list[i] = level_name
	
	print_text_level_table()

func is_level_loaded(level_index: int) -> bool:
	return level_list[level_index] != null

func file_is_level(file_path: String) -> bool:
	var file_name = file_path.get_file()
	return file_name.ends_with(".tscn")

func load_level(level_index: int) -> void:
	var level_name = levelname_list[level_index] + ".tscn"
	level_list[level_index] = load(levels_dir.path_join(level_name))
	print_text_level_table()
	level_loaded.emit(level_name, level_index)

func unload_level(level_index: int) -> void:
	var level_name = levelname_list[level_index] + ".tscn"
	level_list[level_index] = null
	print_text_level_table()
	level_unloaded.emit(level_name, level_index)

## Begins a new level.[br]
## The [code]level[/code] parameter can be a level [b]Index[/b] ([code]int[/code]) 
## or a level [b]Name[/b] ([code]StringName[/code])
func begin_level(level: Variant) -> void:
	var level_index: int
	var level_name: String
	
	if level is PackedScene:
		level_index = level_list.find(level)
		if level_index == -1:
			level_name = level.resource_path.get_file().get_slice(".", 0)
			level_index = levelname_list.find(level_name)
	elif level is StringName:
		level_index = levelname_list.find(level)
		level_name = level
	elif level is int:
		level_index = level
		level_name = levelname_list[level_index]
	else:
		_print_error("Expected level type int, StringName or PackedScene, but got %s" % type_string(typeof(level)))
		return
	if level_index == -1:
		_print_error("Level '%s' not recognized from directory '%s'" % [level, levels_dir])
		return
	
	if not _first_level:
		level_ended.emit(level_name, level_index)
		await get_tree().process_frame
	else:
		_first_level = false
	
	# Load level
	if not is_level_loaded(level_index):
		push_warning("Begun level without having it loaded previously. Loading it now. " +
			"Make sure to load levels before beginning them to avoid loading screens")
		load_level(level_index)
	
	var level_scene = level_list.get(level_index)
	if not level_scene:
		_print_error("Level %s not recognized" % level)
		return
	
	# Begin level for real
	if current_level_node:
		current_level_node.hide()
		remove_child(current_level_node)
		current_level_node.queue_free()
	
	var level_node = level_scene.instantiate()
	add_child.call_deferred(level_node)
	current_level_index = level_index
	current_level_node = level_node
	
	await level_node.ready
	# Teleport Player to spawn
	var player_spawner: Marker2D = current_level_node.get_node("PlayerSpawner")
	if not player_spawner and not World.get_player():
		level_begun.emit(level_name, level_index)
		return
	World.get_player().global_position = player_spawner.global_position
	player_spawner.hide()
	player_spawner.queue_free()
	
	level_loaded.emit(level_name)

func print_text_level_table():
	print(_get_text_level_table())
	debug_label.text = _get_text_level_table()

func _get_text_level_table() -> String:
	var longest_level_name: String = levelname_list.reduce(func(longest: String, _name: String): 
		return longest if longest.length() > _name.length() else _name
	, "")
	# Print a list of levels, showing their index, name and scene ( index  : 'name'  = PackedScene)
	var text_table := "-- Cached levels --\n"
	text_table += "index : name%s    = PackedScene\n" % " ".repeat(longest_level_name.length() - 4)
	for i in range(level_list.size()):
		var level_name = levelname_list[i]
		text_table += "  %-*s: '%s'%s  = %s\n" % [4, i, level_name, " ".repeat(longest_level_name.length() - level_name.length()), level_list[i]]
	text_table += "-- end of cached levels --\n"
	return text_table

func _print_error(message: String):
	var stack = get_stack()
	var caller = stack[2]
	if stack.size() == 4:
		caller = stack[3]
	var line_code = FileAccess.get_file_as_string(caller.source).split("\n")[caller.line-1].strip_edges()
	printerr(message + "\n At: %s:%d:%s() -    %s" % [caller.source.get_file(), caller.line, caller.function, line_code])
