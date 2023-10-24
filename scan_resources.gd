@tool
extends EditorScript

func _run():
	get_editor_interface().get_resource_filesystem().scan()
