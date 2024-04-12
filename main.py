import sys
from array import array

import pygame
import moderngl

pygame.init()

screen = pygame.display.set_mode((800, 600), pygame.OPENGL | pygame.DOUBLEBUF)
display = pygame.Surface((800, 600))
ctx = moderngl.create_context()
clock = pygame.time.Clock()
img = pygame.image.load('random2.jpg')
quad_buffer = ctx.buffer(data=array('f', [
    # position (x, y), uv coords (x, y)
    -1.0, 1.0, 0.0, 0.0,  # topleft
    1.0, 1.0, 1.0, 0.0,  # topright
    -1.0, -1.0, 0.0, 1.0,  # bottomleft
    1.0, -1.0, 1.0, 1.0,  # bottomright
]))
font = pygame.font.SysFont('Arial', 64)
x = 1
y = 0
xv = 0
yv = 0


with open ('Assets/Shaders/Vert.glsl', 'r') as f:
    vert_shader = f.read()
with open ('Assets/Shaders/Frag.glsl', 'r') as f:
    frag_shader = f.read()

program = ctx.program(vertex_shader=vert_shader, fragment_shader=frag_shader)
render_object = ctx.vertex_array(program, [(quad_buffer, '2f 2f', 'vert', 'texcoord')])


def surf_to_texture(surf):
    tex = ctx.texture(surf.get_size(), 4)
    tex.filter = (moderngl.NEAREST, moderngl.NEAREST)
    tex.swizzle = 'BGRA'
    tex.write(surf.get_view('1'))
    return tex


t = 0

while True:
    display.fill((0, 0, 0))
    display.blit(img, (0, 0))

    t += 1

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_UP:
                yv -= 1
            if event.key == pygame.K_DOWN:
                yv += 1
            if event.key == pygame.K_LEFT:
                xv -= 1
            if event.key == pygame.K_RIGHT:
                xv += 1

    x += xv
    y += yv
    xv *= 0.9
    yv *= 0.9

    mouse_pos = pygame.mouse.get_pos()

    pygame.draw.rect(display, (0, 0, 255), (x, y, 100, 100), 1)
    text = font.render(str(int(clock.get_fps())), True, (255, 255, 255))
    display.blit(text, (0, 0))
    frame_tex = surf_to_texture(display)
    frame_tex.use(0)
    program['tex'] = 0
    program['threshold'] = (800 - mouse_pos[0]) / 800
    program['exposure'] = mouse_pos[1] / 200
    program['width'] = 800
    program['height'] = 600
    render_object.render(mode=moderngl.TRIANGLE_STRIP)

    pygame.display.flip()
    frame_tex.release()
    clock.tick()
