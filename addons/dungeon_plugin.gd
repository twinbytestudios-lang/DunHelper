@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("DungeonGen2D", "Node2D", preload("generator_node.gd"), null)

func _exit_tree():
	remove_custom_type("DungeonGen2D")
