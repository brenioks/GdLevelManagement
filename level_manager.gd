extends Node

@export var start_level_number: int = 1
@export_group("References")
@export var levels_dir: String = "res://"

var level_list: Array[PackedScene]
var current_level_number: int = -1
var current_level_node: Node

signal level_loaded(level_number: String)
signal level_ended


func _ready() -> void:
	if not World.player:
		push_error("LevelManager: reference to Player (from World) not found!")
		get_tree().quit()
		breakpoint
		return
	
	# Consertar caminho pra ser um diretório
	if not levels_dir.ends_with("/"):
		levels_dir += "/"
	
	# Cachear níveis numa array
	var scene_files: Array = Array(ResourceLoader.list_directory(levels_dir))
	scene_files = scene_files.filter(file_is_level)	# Filtrar apenas níveis (cenas numeradas)
	level_list.resize(scene_files.size())	# Definir o tamanho da lista de niveis direto
	for scene_name in scene_files:
		var level_number = scene_name.to_int()
		level_list[level_number - 1] = load(levels_dir + scene_name)
	
	# Limpar qualquer coisa que estiver nesse node por algum motivo
	for child in get_children():
		child.queue_free()
	
	start_level(start_level_number)
	level_ended.connect(_on_level_ended)

func file_is_level(file_name: String):
	var regex = RegEx.create_from_string("[0-9]")
	var has_numbers = regex.search(file_name) != null
	
	return file_name.ends_with(".tscn") and has_numbers

func start_level(level_number: int) -> void:
	# Index começa de 0, Number de 1
	var level_index = level_number - 1
	var level_scene = level_list.get(level_index)
	if not level_scene:
		printerr("Level %s not recognized" % level_number)
		return
	
	# Unload last level
	if current_level_node:
		current_level_node.queue_free()
	
	# Load new level
	var level_node = level_scene.instantiate()
	call_deferred("add_child", level_node)
	current_level_number = level_number
	current_level_node = level_node
	
	World.player.velocity = Vector2.ZERO
	await get_tree().create_timer(.1).timeout
	level_loaded.emit()


func _on_level_ended():
	start_level(current_level_number + 1)
