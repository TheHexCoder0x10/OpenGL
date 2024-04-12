#version 330 core

uniform sampler2D tex;
uniform float threshold;
uniform float exposure;
uniform float width;
uniform float height;

in vec2 uvs;
out vec4 f_color;

void main() {
    vec2 sample_pos = vec2(uvs.x, uvs.y);
    vec3 color = texture(tex, sample_pos).rgb;
    vec3 bloom_color;
    vec2 coords;
    for(int i = 0; i < 3; ++i) {
        for(int j = 0; j < 3; ++j) {
            coords = vec2(clamp(uvs.x + ((float(i) - 1) / width), 0, 1), clamp(uvs.y + ((float(j) - 1) / height), 0, 1));
            bloom_color += texture(tex, coords).rgb;
        }
    }
    bloom_color.r /= 9;
    bloom_color.g /= 9;
    bloom_color.b /= 9;
    f_color = vec4(
        color.r + (smoothstep(threshold, exposure + 1.0, color.r) * exposure),
        color.g + (smoothstep(threshold, exposure + 1.0, color.g) * exposure),
        color.b + (smoothstep(threshold, exposure + 1.0, color.b) * exposure),
        1.0
    );
}