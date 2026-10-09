extends CanvasLayer

@onready var level_manager: LevelManager = $".."
@onready var label: Label = $Label

func _ready() -> void:
	await level_manager.ready
	_on_level_changed(null, null)
	
	level_manager.level_loaded.connect(_on_level_changed)
	level_manager.level_unloaded.connect(_on_level_changed)

func _on_level_changed(_a, _b):
	var level_table = get_text_level_table()
	print(level_table)
	label.text = level_table

func get_text_level_table() -> String:
	var level_list = level_manager.level_list
	var levelname_list = level_manager.levelname_list
	
	var longest_level_name: String = levelname_list.reduce(func(longest: String, _name: String): 
		return longest if longest.length() > _name.length() else _name
	, "")
	# Print a list of levels, showing their index, name and scene ( index  : 'name'  = PackedScene)
	var text_table := "-- Cached levels --\n"
	text_table += "index : name%s    = PackedScene\n" % " ".repeat(longest_level_name.length() - 4)
	for i in range(level_list.size()):
		var level_name = levelname_list[i]
		text_table += "  %-*s: '%s'%s  = %s\n" % [
			4, i, 
			level_name, " ".repeat(longest_level_name.length() - level_name.length()), 
			level_list[i]
		]
	text_table += "-- end of cached levels --\n"
	return text_table
