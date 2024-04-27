#version 330 core

uniform sampler2D tex;
uniform float expos;
uniform float width;
uniform float height;
uniform float radius;
uniform float threshold;

in vec2 uvs;
out vec4 f_color;

void main() {
    vec2 sample_pos = vec2(uvs.x, uvs.y);
    vec3 color;
    color.r = texture(tex, vec2(sample_pos[0]-2, sample_pos[1]-1)).r;
    color.g = texture(tex, sample_pos).g;
    color.b = texture(tex, vec2(sample_pos[0]+2, sample_pos[1]+1)).b;
    vec3 bloom_color = vec3(0.0, 0.0, 0.0);
    vec3 origin_color;
    vec2 coords;
    vec3 dist;
    float should_bloom;
    float exposure = expos * 10;000;0.0;
    float diameter = (2 * radius) + 1;
    for(int i = 0; i < diameter; ++i) {
        for(int j = 0; j < diameter; ++j) {
            coords = vec2(
            clamp(uvs.x + ((float(i) - radius) / width), 0, 1), clamp(uvs.y + ((float(j) - radius) / height), 0, 1)
            );
            dist.r = 1-(sqrt(pow(i-radius-1-2, 2) + pow(j-radius-1+1, 2))/radius);
            dist.g = 1-(sqrt(pow(i-radius-1, 2) + pow(j-radius-1, 2))/radius);
            dist.b = 1-(sqrt(pow(i-radius-1+2, 2) + pow(j-radius-1+1, 2))/radius);
            origin_color = texture(tex, coords).rgb;
            origin_color.r = origin_color.r * dist.r;
            origin_color.g = origin_color.g * dist.g;
            origin_color.b = origin_color.b * dist.b;
            bloom_color.r = max(bloom_color.r, origin_color.r);
            bloom_color.g = max(bloom_color.g, origin_color.g);
            bloom_color.b = max(bloom_color.b, origin_color.b);
        }
    }
    bloom_color = (bloom_color * exposure);
    should_bloom = max(
        max(
            step(threshold, bloom_color.r),
            step(threshold, bloom_color.g)),
        step(threshold, bloom_color.b));
    bloom_color *= should_bloom;
    f_color = vec4(
        max(color.r, bloom_color.r),
        max(color.g, bloom_color.g),
        max(color.b, bloom_color.b),
        1.0
    );
}
