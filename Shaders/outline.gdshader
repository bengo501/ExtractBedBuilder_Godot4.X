shader_type spatial;
render_mode unshaded, depth_prepass_alpha, cull_back;

uniform vec4 outline_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 0.1) = 0.02;
uniform float transparency : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec3 normal = NORMAL;
    float rim = 1.0 - max(0.0, dot(normal, VIEW));
    rim = pow(rim, 3.0);
    
    vec4 base_color = vec4(0.8, 0.8, 0.8, transparency);
    vec4 final_color = mix(base_color, outline_color, rim * step(0.5, rim));
    
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
} 