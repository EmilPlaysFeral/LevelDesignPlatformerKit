shader_type spatial;

uniform vec4 wind_color;  // Color of the wind effect (light blue, semi-transparent)
uniform float wind_strength; // Controls opacity (range from 0.0 to 1.0)

void fragment() {
    // Make the cylinder material semi-transparent and wind-like
    vec4 color = wind_color;
    color.a = wind_strength; // Control the transparency
    ALBEDO = color.rgb;
    ALPHA = color.a;
}
