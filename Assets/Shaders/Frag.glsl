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
    vec3 color2;
    for(int i=0;i<3;++i) {
        for(int j=0;j<3;++j) {
            color2 += texture(tex, vec2(uvs.x+((i-1)/width), uvs.y+((j-1)/height))).rgb;
        }
    }
    color2.r /= 9;
    color2.g /= 9;
    color2.b /= 9;
    f_color = vec4(
    /*
    color.r + (smoothstep(threshold, exposure + 1.0, color.r) * exposure),
    color.g + (smoothstep(threshold, exposure + 1.0, color.g) * exposure),
    color.b + (smoothstep(threshold, exposure + 1.0, color.b) * exposure),
    */
    color2.r,
    color2.g,
    color2.b,
    1.0);
}