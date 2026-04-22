shader_type canvas_item;
uniform bool look_right = true;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

void vertex() {
    // 最简单的版本，避免任何可能导致闪烁的变换
    VERTEX.x = VERTEX.x * (look_right ? 1.0 : -1.0);
    VERTEX.y = VERTEX.y * 0.5;  // 简单的压缩和偏移
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = vec4(shadow_color.rgb, tex.a * shadow_color.a);
}