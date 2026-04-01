@tool
extends Resource
class_name SpawnData

@export var name: String = "Entity"
@export var scene: PackedScene
## Higher weight = more likely to spawn (e.g., Slime: 10, Boss: 1)
@export var weight: float = 1.0
