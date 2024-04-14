#version 330 core

uniform sampler2D tex;
uniform float expos;
uniform float width;
uniform float height;
uniform float radius;

in vec2 uvs;
out vec4 f_color;

void main() {
    vec2 sample_pos = vec2(uvs.x, uvs.y);
    vec3 color = texture(tex, sample_pos).rgb;
    vec3 bloom_color = vec3(0.0, 0.0, 0.0);
    vec3 origin_color;
    vec3 add_color;
    vec2 coords;
    float dist;
    float should_bloom;
    float exposure = expos * 1.0;000;0.0;
    float diameter = (2 * radius) + 1;
    for(int i = 0; i < diameter; ++i) {
        for(int j = 0; j < diameter; ++j) {
            coords = vec2(
            clamp(uvs.x + ((float(i) - radius) / width), 0, 1), clamp(uvs.y + ((float(j) - radius) / height), 0, 1)
            );
            dist = 1-(sqrt(pow(i-radius-1, 2) + pow(j-radius-1, 2))/radius);
            origin_color = texture(tex, coords).rgb;
            origin_color = origin_color * dist;
            bloom_color.r = max(bloom_color.r, origin_color.r);
            bloom_color.g = max(bloom_color.g, origin_color.g);
            bloom_color.b = max(bloom_color.b, origin_color.b);
        }
    }
    float divi = 6.6341712215 * pow(radius, 2.718281828459045235360287);
    bloom_color /= divi;
    should_bloom = max(
        max(
            step(0.0, bloom_color.r),
            step(0.0, bloom_color.g)),
        step(0.0, bloom_color.b));
    bloom_color = bloom_color * divi * exposure;
    f_color = vec4(
        max(color.r, bloom_color.r),
        max(color.g, bloom_color.g),
        max(color.b, bloom_color.b),
        1.0
    );
}