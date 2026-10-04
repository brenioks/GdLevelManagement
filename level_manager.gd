class_name LevelManager extends Node

@export var start_level: Variant
@export_group("References")
@export var levels_dir: String = "res://"

var level_list: Array[PackedScene]
var levelname_list: Array[String]
var current_level_index: int = -1
var current_level_name: StringName
var current_level_node: Node

signal level_loaded(level_name: StringName)
signal level_ended


func _ready() -> void:
	if not World.player:
		push_error("LevelManager: reference to Player (from World) not found!")
		get_tree().quit()
		breakpoint
		return
	
	cache_levels()
	
	# Erase anything that is inside this node for some reason
	for child in get_children():
		child.queue_free()
	
	begin_level(start_level)
	level_ended.connect(_on_level_ended)

func cache_levels() -> void:
	var scene_files: Array = ResourceLoader.list_directory(levels_dir)
	scene_files = scene_files.filter(file_is_level)
	# Set the lists' sizes 
	level_list.resize(scene_files.size())
	levelname_list.resize(scene_files.size())
	# Add level scenes and names to their respectiive lists, at the same index
	for i in range(scene_files.size()):
		var scene_name: String = scene_files[i]
		var level_name: StringName = scene_name.get_file().get_slice('.', 0)
		level_list[i] = load(levels_dir.path_join(scene_name))
		levelname_list[i] = level_name
	# Print a list of levels, showing their index, name and scene ( index  : 'name'  = PackedScene)
	print("-- Cached levels --")
	print("index :  name            = PackedScene")
	for i in range(level_list.size()):
		print("  %-*s: '%s'  = %s" % [4, i, levelname_list[i], level_list[i]])
	print("-- end of cached levels --")

func file_is_level(file_path: String):
	var file_name = file_path.get_file()
	return file_name.ends_with(".tscn")

## Loads and Begins a new level.[br]
## The [code]level[/code] parameter can be a level [b]Index[/b] ([code]int[/code]) or a level [b]Name[/b] ([code]StringName[/code])
func begin_level(level: Variant) -> void:
	var level_index: int
	# Podemos usar o nome do nível
	if level is StringName:
		level_index = levelname_list.find(level)
		if level_index == -1:
			_print_error("Level '%s' not recognized from directory '%s'" % [level, levels_dir])
			return
	# Mas também o indice do nível
	elif level is int:
		level_index = level
	# Tipo de nível desconhecido (!int && !StringName)
	else:
		_print_error("Level type '%s' should be 'int' or 'StringName'" % type_string(typeof(level)))
		return
	
	# Iniciar nível de verdadde
	
	var level_scene = level_list.get(level_index)
	if not level_scene:
		_print_error("Level %s not recognized" % level)
		return
	
	# Descarregar nível anterior
	if current_level_node:
		current_level_node.queue_free()
	
	# Carregar nível novo
	var level_node = level_scene.instantiate()
	call_deferred("add_child", level_node)
	current_level_index = level_index
	current_level_node = level_node
	
	await level_node.ready
	var level_name = levelname_list[level_index]
	level_loaded.emit(level_name)

func _print_error(message: String):
	var stack = get_stack()
	var caller = stack[2]
	if stack.size() == 4:
		caller = stack[3]
	var line_code = FileAccess.get_file_as_string(caller.source).split("\n")[caller.line-1].strip_edges()
	printerr(message + "\n At: %s:%d:%s() -    %s" % [caller.source.get_file(), caller.line, caller.function, line_code])


func _on_level_ended() -> void:
	pass
