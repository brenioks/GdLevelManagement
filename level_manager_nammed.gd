extends Node

@export var start_level: StringName
@export_group("References")
@export var levels_dir: String = "res://"

var level_list: Dictionary[StringName, PackedScene]
var current_level_name: StringName
var current_level_node: Node

signal level_loaded(level_name: StringName)
signal level_ended

const _type: int = 0


func _ready() -> void:
	if not World.player:
		push_error("LevelManager: reference to Player (from World) not found!")
		get_tree().quit()
		breakpoint
		return
	
	# Cachear níveis num dicionário, para ser mais fácil de ler-los
	var scene_files = ResourceLoader.list_directory(levels_dir)
	for i in range(scene_files.size()):
		var scene_name: String = scene_files[i]
		# Filtrar apenas níveis
		if not file_is_level(levels_dir.path_join(scene_name)):
			continue
		# Adicionar nível no Cache (Ex.: { "cool_level" })
		var level_name: StringName = scene_name.get_file().get_slice('.', 0)
		level_list[level_name] = load(levels_dir.path_join(scene_name))
	print(level_list)
	
	# Limpar qualquer coisa que estiver nesse node por algum motivo
	for child in get_children():
		child.queue_free()
	
	begin_level(start_level)
	level_ended.connect(_on_level_ended)

func file_is_level(file_path: String):
	var file_name = file_path.get_file()
	return file_name.ends_with(".tscn")

func begin_level(level_name: StringName) -> void:
	var level_scene = level_list.get(level_name)
	if not level_scene:
		printerr("Level '%s' not recognized" % level_name)
		return
	
	# Unload last level
	if current_level_node:
		current_level_node.queue_free()
	
	# Load new level
	var level_node = level_scene.instantiate()
	call_deferred("add_child", level_node)
	current_level_name = level_name
	current_level_node = level_node
	
	await level_node.ready
	level_loaded.emit(level_name)


func _on_level_ended() -> void:
	pass
