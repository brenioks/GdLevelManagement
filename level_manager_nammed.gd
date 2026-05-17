extends SeqLevelManager

var levelname_list: Array[String]
var current_level_name: StringName


# Override
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

# Override
func file_is_level(file_path: String):
	var file_name = file_path.get_file()
	return file_name.ends_with(".tscn")

func begin_level(level: Variant) -> void:
	# Ainda podemos usar os indice do nível
	if level is int:
		super.begin_level(level)
	# Mas tambem podemos usar o nome do nível
	elif level is StringName:
		var level_index = levelname_list.find(level)
		if level_index == -1:
			var stack = get_stack()
			var caller = stack[2]
			printerr("Level '%s' not recognized (%s, line: %d)" % [level, caller.source.get_file(), caller.line])
			return
		super.begin_level(level_index + 1)
	else:
		var stack = get_stack()
		var caller = stack[2]
		printerr("Level type '%s' not recognized (%s, line: %d)" % [type_string(typeof(level)), caller.source.get_file(), caller.line])


func _on_level_ended() -> void:
	pass
