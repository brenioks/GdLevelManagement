class_name World
extends Node

static var instance: World = null
static var player: Player = null
# Para chamar variáveis não-estáticas, é preciso usar o World.instance, que estará se referindo ao ...
# nó World, em vez da classe world. Em resumo, um Singleton.
# Ex.: World.instance._level_manager.level_ended.emit()
@onready var level_manager: LevelManager = $LevelManager


# O _ready e outras funções de Node só rodam no nó, não na classe
func _ready() -> void:
	World.instance = self


# Funções estáticas devem ser usadas com World direto, não World.instance
static func get_current_level() -> int:
	return World.instance.level_manager.current_level_index

static func begin_level(level) -> void:
	var _level_manager = World.instance.level_manager
	_level_manager.level_ended.emit()
	# NOTE: Provavelmente fazer algo tipo uma transição aqui
	_level_manager.begin_level(level)

static func next_level() -> void:
	World.begin_level(World.get_current_level() + 1)
