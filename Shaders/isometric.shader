shader_type canvas_item;
render_mode unshaded;

uniform sampler2D layers;
uniform bool start_from_top;
uniform vec2 rect_size; //in pixels
uniform int model_height = 1;
uniform bool has_shadow;
uniform float rotation;
uniform int tile_pixels_x;
uniform int tile_pixels_y;
uniform float ppv = 1.0;

vec4 get_voxel(float x, float y, int z){
	ivec2 tex_size = textureSize(layers, 0);
	float uv_x = x / float(tex_size.x);
	int model_depth = tex_size.y / model_height;
	float uv_y = (float(z*model_depth) + y) / float(tex_size.y);
	return texture(layers, vec2(uv_x, uv_y), 0);
}

void fragment(){
	vec4 current_color = vec4(0);
	vec2 pixel_size = vec2(1,1) / rect_size;
	ivec2 current_pixel = ivec2(((vec2(1.0) - UV) * rect_size));
	ivec2 tex_size = textureSize(layers, 0);
	int model_width = tex_size.x;
	int model_depth = tex_size.y / model_height;
	
	float layer_h = (abs(float(model_width) * ppv * sin(rotation)) + abs(float(model_depth) * ppv * cos(rotation)))/2.0;
	
	float x_offset = rect_size.x/2f;
	
	float y_offset = rect_size.y/2f;
	
	float rpx_x = (float(current_pixel.x) - x_offset)/ float(ppv);
	
	for(int z=model_height -1; z>=0; z--){
		for(float i = 0f; i<=ppv; i++){
			float real_y_offset = layer_h/2f + float(model_height-z-1)*ppv  +i;
			float rpx_y = (float(current_pixel.y) - real_y_offset) * (2.0/ppv);
			float idx_x = rpx_x * cos(-rotation) - rpx_y * sin(-rotation) + float(model_width)/2f;
			
			float idx_y = rpx_x * sin(-rotation) + rpx_y * cos(-rotation) + float(model_depth) / 2f;
			if(idx_y >= 0f && idx_y < float(model_depth) && idx_x >= 0f && idx_x < float(model_width)){
				vec4 vox_col = get_voxel(idx_x, idx_y, z);
				if(vox_col.a != 0f){
					current_color = vox_col;
				}
			}
		}
	}
	
	COLOR = current_color;
}

