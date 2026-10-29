class_name ItemData
extends  Resource

@export var id: String = ""
@export var item_name: String = ""
@export var icon: Texture2D = null
@export var mesh_scene: PackedScene
@export var interactable_scene: PackedScene = preload("res://src/items/interactable_item.tscn")
