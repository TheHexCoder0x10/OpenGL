#version 330 core

uniform sampler2D tex;
//uniform float threshold;
//uniform float exposure;
//uniform float width;
//uniform float height;

in vec2 uvs;
out vec4 f_color;

float threshold = 0.0;
float exposure = 1.5;
float width = 800;
float height = 600;
float radius = 3;

void main() {
    vec2 sample_pos = vec2(uvs.x, uvs.y);
    vec3 color = texture(tex, sample_pos).rgb;
    vec3 bloom_color;
    vec3 add_color;
    vec2 coords;
    float should_bloom;
    float diameter = (2 * radius) + 1;
    for(int i = 0; i < diameter; ++i) {
        for(int j = 0; j < diameter; ++j) {
            coords = vec2(clamp(uvs.x + ((float(i) - radius) / width), 0, 1), clamp(uvs.y + ((float(j) - radius) / height), 0, 1));
            bloom_color += texture(tex, coords).rgb;
        }
    }
    bloom_color.r /= (diameter * diameter);
    bloom_color.g /= (diameter * diameter);
    bloom_color.b /= (diameter * diameter);
    should_bloom = max(
        max(
            step(threshold, color.r),
            step(threshold, color.g)),
        step(threshold, color.b));
    add_color.r = clamp((should_bloom * bloom_color.r * exposure) + ((1.0 - should_bloom) * color.r), 0.0, 1.0);
    add_color.g = clamp((should_bloom * bloom_color.g * exposure) + ((1.0 - should_bloom) * color.g), 0.0, 1.0);
    add_color.b = clamp((should_bloom * bloom_color.b * exposure) + ((1.0 - should_bloom) * color.b), 0.0, 1.0);
    f_color = vec4(
        (color.r+add_color.r)/2.0,
        (color.g+add_color.g)/2.0,
        (color.b+add_color.b)/2.0,
        1.0
    );
}