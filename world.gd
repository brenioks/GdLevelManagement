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
	World.instance.level_manager.level_ended.emit()
