class_name World extends Node

static var instance: World = null
static var player: Player = null

func _ready() -> void:
	World.instance = self
