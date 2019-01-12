tool
extends ColorRect

#helper script for the isometric shader

export(Texture) var vox_layer_texture setget set_layer_texture
export(bool) var has_shadow = false
export(int) var model_height = 1 setget set_model_height
export(float) var model_rotation_degrees = 0 setget set_model_rot_deg
export(Vector3) var centre_voxel = Vector3() setget set_centre_voxel
export(Vector2) var reference_pos = Vector2() setget set_reference_position
export(float) var ppv = 1.0 setget set_ppv

var layer_dimensions setget ,get_layer_dimensions


var centre_pos = Vector2()

func _ready():
	update_dimensions()

func _process(delta):
	
	pass
	if !Engine.editor_hint:
		pass

func get_layer_dimensions():
	var retval = vox_layer_texture.get_size()
	if has_shadow:
		retval.y /= (model_height-1)
	else:
		retval.y /= model_height
		
	return retval
	
func look_towards(from, target):
	set_model_rot_deg(rad2deg((target - from).normalized().angle())+90)
	
func set_reference_position(new_val):
	reference_pos = new_val
	update_dimensions()
	
func set_model_height(new_val):
	model_height = new_val
	update_dimensions()
	
func set_ppv(new_val):
	ppv = new_val
	update_dimensions()
	
func set_centre_voxel(new_val):
	centre_voxel = new_val
	update_dimensions()
	
func set_model_rot_deg(new_val):
	model_rotation_degrees = new_val
	update_dimensions()
	
func set_layer_texture(new_val):
	vox_layer_texture = new_val
	update_dimensions()
	
func _draw():
	
	draw_circle(centre_pos, 1, Color.red)
	
func update_dimensions():
	var dim = get_layer_dimensions()
	var angle = deg2rad(model_rotation_degrees)
	
	var ang_c = cos(angle)
	var ang_s = sin(angle)
	var img_w = (abs(float(dim.x * ppv)* cos(angle)) + abs(float(dim.y * ppv)* sin(angle)))
	var layer_h = (abs(float(dim.x * ppv)* sin(angle)) + abs(float(dim.y * ppv) * cos(angle)))/2.0
	var img_h = layer_h + (model_height) * ppv# *ppv
	
	# centre around centre voxel
	var offset_layer = Vector2(dim.x / 2.0, dim.y / 2.0)
	var offset_final = Vector2(img_w / 2.0, layer_h / 2.0)
	offset_final.y += float(model_height -centre_voxel.z) * ppv
	
	rect_size = Vector2(img_w, img_h)
	
	var centre_translated = Vector2(centre_voxel.x, centre_voxel.y) - offset_layer
	var centre_rotated = Vector2((centre_translated.x) * ang_c - (centre_translated.y) * ang_s,
		(centre_translated.x * ang_s + centre_translated.y * ang_c))
		
	centre_rotated.y /= 2.0
	centre_rotated *= ppv
	centre_rotated += offset_final
	
	centre_pos = centre_rotated
	
	rect_position = (reference_pos - centre_rotated)
	
	
	material.set_shader_param("layers", vox_layer_texture)
	material.set_shader_param("rotation", angle)
	material.set_shader_param("rect_size", rect_size)
	material.set_shader_param("model_height", model_height)
	material.set_shader_param("ppv", ppv)
