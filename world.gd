class_name World extends Node

static var instance: World = null
static var player: Player = null
# Para chamar variáveis não-estáticas, é preciso usar o World.instance, que estará se referindo ao ...
# nó World, em vez da classe world. Em resumo, um Singleton.
# Ex.: World.instance._level_manager.level_ended.emit()
@onready var level_manager: Node = $LevelManager


# O _ready e outras funções de Node só rodam no nó, não na classe
func _ready() -> void:
	World.instance = self


# Funções estáticas devem ser usadas com World direto, não World.instance
static func goto_next_level() -> void:
	var _level_manager = World.instance.level_manager
	if _level_manager._type == 1:
		_level_manager.level_ended.emit()
	else:
		print("No next level to go")

static func begin_level(level) -> void:
	var _level_manager = World.instance.level_manager
	_level_manager.level_ended.emit()
	# NOTE: Provavelmente fazer algo tipo uma transição aqui
	_level_manager.begin_level(level)
