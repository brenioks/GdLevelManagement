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
	
	# Limpar qualquer coisa que estiver nesse node por algum motivo
	for child in get_children():
		child.queue_free()
	
	begin_level(start_level)
	level_ended.connect(_on_level_ended)

func cache_levels() -> void:
	var scene_files: Array = ResourceLoader.list_directory(levels_dir)
	scene_files = scene_files.filter(file_is_level)
	level_list.resize(scene_files.size())
	levelname_list.resize(scene_files.size())
	for i in range(scene_files.size()):
		var scene_name: String = scene_files[i]
		var level_name: StringName = scene_name.get_file().get_slice('.', 0)
		level_list[i] = load(levels_dir.path_join(scene_name))
		levelname_list[i] = level_name
	print(level_list)
	print(levelname_list)

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
			var stack = get_stack()
			var caller = stack[2]
			printerr("Level '%s' not recognized (%s, line: %d)" % [level, caller.source.get_file(), caller.line])
			return
	# Mas também o indice do nível
	elif level is int:
		level_index = level
	# Tipo de nível desconhecido (!int && !StringName)
	else:
		var stack = get_stack()
		var caller = stack[2]
		printerr("Level type '%s' not recognized (%s, line: %d)" % [type_string(typeof(level)), caller.source.get_file(), caller.line])
		return
	
	# Iniciar nível de verdadde
	
	var level_scene = level_list.get(level_index)
	if not level_scene:
		printerr("Level %s not recognized" % level)
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


func _on_level_ended() -> void:
	pass
