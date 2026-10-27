shader_type spatial;

// Expose colors and split position to the Inspector
uniform vec4 concrete_color : source_color = vec4(0.82, 0.82, 0.82, 1.0); // Concrete light gray
uniform vec4 forest_color : source_color = vec4(0.37, 0.91, 0.76, 1.0);     // Forest green
uniform float split_position : hint_range(0.0, 1.0) = 0.5;                // 50% split point
uniform float smoothness : hint_range(0.0, 0.2) = 0.0;                    // Soft edge blend

void fragment() {
    // Uses UV coordinates to split each face horizontally. 
    // Use UV.y if you want a vertical (top/bottom) split instead.
    float blend = smoothstep(split_position - smoothness, split_position + smoothness, UV.y);
    
    // In 3D spatial shaders, we output to ALBEDO instead of COLOR
    ALBEDO = mix(forest_color.rgb, concrete_color.rgb, blend);
}