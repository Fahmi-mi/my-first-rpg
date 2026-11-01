class_name ItemData
extends  Resource

enum ItemType { WEAPON, HEALING }

@export var id: String = ""
@export var item_name: String = ""
@export var icon: Texture2D = null
@export var mesh_scene: PackedScene
@export var interactable_scene: PackedScene = preload("res://src/items/interactable_item.tscn")

@export var item_type: ItemType = ItemType.WEAPON
@export var damage: int = 20
@export var heal_amount: int = 25
