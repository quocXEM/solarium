extends Node
## Soft fades between scenes — international casual polish.


func go(path: String, fade := 0.28) -> void:
	var tree := get_tree()
	var layer := CanvasLayer.new()
	layer.layer = 100
	tree.root.add_child(layer)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.03, 0.02, 0.05, 0.0)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(dim)
	var tw := tree.create_tween()
	tw.tween_property(dim, "color:a", 1.0, fade)
	await tw.finished
	tree.change_scene_to_file(path)
	await tree.process_frame
	# New scene — fade out on a fresh overlay
	var layer2 := CanvasLayer.new()
	layer2.layer = 100
	tree.root.add_child(layer2)
	var dim2 := ColorRect.new()
	dim2.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim2.color = Color(0.03, 0.02, 0.05, 1.0)
	dim2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer2.add_child(dim2)
	layer.queue_free()
	var tw2 := tree.create_tween()
	tw2.tween_property(dim2, "color:a", 0.0, fade)
	await tw2.finished
	layer2.queue_free()
