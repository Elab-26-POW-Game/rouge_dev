// 版权 - https://www.bilibili.com/video/BV1Wi42127Mp

shader_type canvas_item;

uniform bool graph_switch = false; // 图形开关

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity: hint_range(0.0, 1, 0.01) = 1.0; // 整体强度
uniform float blur: hint_range(0.0, 5.0) = 3.0; // 模糊强度
uniform float diffusion = 0.4; // 暗角强度
uniform float zoom: hint_range(0.0, 1.0, 0.01) = 1.0; // 缩放强度
// 动画参数
group_uniforms animation;
uniform int graph_type: hint_range(0, 10, 1) = 0; // 数量
uniform float number: hint_range(0.0, 100.0, 1.0) = 8.0; // 数量
uniform float size: hint_range(0.0, 1.0, 0.01) = 0.1; // 大小
uniform float rotate_speed: hint_range(0.0, 1.0, 0.01)  = 0.1; // 偏移速度
uniform float offset_speed: hint_range(0.0, 1.0, 0.01)  = 0.1; // 偏移速度
uniform float angle = 0.7854; // 旋转角度
uniform float alpha: hint_range(0.0, 1.0, 0.01) = 0.1; // 透明度
uniform sampler2D pattern_sampler : filter_linear_mipmap; // 图片

// 计算暗角
float vignette(vec2 uv){
	uv *= 1.0 - uv.xy; // 取反再相乘，获得中间大边缘小的过度
	float vignette = uv.x * uv.y * 16.0; // 转为浮点，然后归一化
	return pow(vignette, diffusion); // 强度控制
}

void fragment(){
	// 模糊/缩放
	vec4 pixel = texture(SCREEN_TEXTURE, (SCREEN_UV - 0.5) * mix(zoom, 1.0, intensity) + 0.5, mix(blur, 0.0, intensity)); // 获取屏幕颜色
	// 黑白
	vec3 grayscale_value = mix(vec3(dot(pixel.rgb, vec3(0.299, 0.587, 0.114))), pixel.rgb, intensity); // 计算灰度值（加权平均法）
	// 暗角
	float get_vignette = mix(vignette(UV), 1.0, intensity);
	//if (graph_switch) {
	COLOR.rgb = grayscale_value * get_vignette; // 综合应用
	//} else {

	// 旋转动画
	//float rotate = angle + (rotate_speed * TIME);
//
	//// 生成条纹
	////float uv = cos(rotate) * UV.x + sin(rotate) * UV.y - offset_speed * TIME; // 旋转偏移 UV
	////float strip = round(mod(uv * number, 1.0)); // 计算条带
	////COLOR.rgb = grayscale_value * get_vignette + (strip * (1.0 - get_vignette) * alpha); // 综合应用
//
	//// 生成图形
	//vec2 screen_uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE.x; // 无拉伸屏幕 UV
    //vec2 rotated_uv = vec2(
        //cos(rotate) * screen_uv.x - sin(rotate) * screen_uv.y,
        //sin(rotate) * screen_uv.x + cos(rotate) * screen_uv.y
    //) - offset_speed * TIME; // 旋转偏移 U
	//vec2 tile = mod((rotated_uv) * number, 1.0); // 瓷砖切割
	//// 请选择其中一个效果
	//float get_graph;
	//switch (graph_type) {
		//case 0:
			//// 生成条纹
			//get_graph = round(mod(tile.x * number, 1.0)); // 计算条带
			//break;
		//case 1:
			//// 计算扇形
			//get_graph = round(clamp(tile.x * tile.y / size, 0, 1));
			//break;
		//case 2:
			//// 计算方形
			//vec2 get_square = round(clamp(tile / (size * 2.0), 0, 1));
			//get_graph = get_square.x * get_square.y;
			//break;
		//case 3:
			//// 计算斑点
			//tile = tile - 0.5;
			//get_graph = round(1.0 - clamp(length(tile) / size, 0, 1));
			//break;
		//case 4:
			//// 计算棋盘
			//tile = tile - 0.5;
			//get_graph = round(clamp(tile.x * tile.y / size, 0, 1));
			//break;
		//case 5:
			//// 图片平铺
			//get_graph = texture(pattern_sampler, tile / size).x;
	//};
	//COLOR.rgb = grayscale_value * get_vignette - (get_graph * (1.0 - get_vignette) * alpha); // 综合应用
	//COLOR.rgb = vec3(1.0 - get_graph); // 测试效果使用
	//}
}
