shader_type spatial;

render_mode cull_disabled, unshaded, blend_add;

instance uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
instance uniform float intensity = 10.0;
uniform sampler2D alpha : filter_linear, repeat_disable;

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = texture(alpha, UV).a;
	EMISSION = vec3(intensity * ALBEDO);
}
