import math
import sys
from array import array
import time
import pygame
import moderngl

pygame.init()

screen = pygame.display.set_mode((800, 600), pygame.OPENGL | pygame.DOUBLEBUF)#vsync=1)
display = pygame.Surface((800, 600))
ctx = moderngl.create_context()
clock = pygame.time.Clock()
quad_buffer = ctx.buffer(data=array('f', [
    # position (x, y), uv coords (x, y)
    -1.0, 1.0, 0.0, 0.0,  # topleft
    1.0, 1.0, 1.0, 0.0,  # topright
    -1.0, -1.0, 0.0, 1.0,  # bottomleft
    1.0, -1.0, 1.0, 1.0,  # bottomright
]))
font = pygame.font.SysFont('Arial', 64)
x = 100
y = 100
oldx = x
oldy = y
xv = 0
yv = 0
keys = [False] * 4
last_tick = 0


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

def render_main():
    global display
    frame_tex = surf_to_texture(display)
    frame_tex.use(0)
    program['tex'] = 0
    program['expos'] = 0.14#mouse_pos[1] / 200
    program['threshold'] = mouse_pos[0] / 8000
    program['width'] = 800
    program['height'] = 600
    program['radius'] = 5#round(mouse_pos[0] / 30)
    #print(mouse_pos[1] / 200, mouse_pos[0] / 8000)
    render_object.render(mode=moderngl.TRIANGLE_STRIP)
    pygame.display.flip()
    frame_tex.release()

def interpolate(start, end, t):
    time = t*20
    return start + (end - start) * time

def update():
    global xv, yv, keys, x, y, oldx, oldy
    oldx = x
    oldy = y
    if keys[0]:
        yv = -50
    if keys[1]:
        yv += 10
    if keys[2]:
        xv -= 10
    if keys[3]:
        xv += 10

    x += xv
    y += yv
    xv *= 0.9
    yv *= 0.9
    yv += 9

t = 0
start_time = time.time()
while True:
    display.fill((0, 0, 0, 255))
    if time.time() - last_tick >  50 / 1000:
        last_tick = time.time()
        pygame.event.post(pygame.event.Event(pygame.USEREVENT, {'event_type': 'game_tick'}))
    #else:
        #print('time', time.time() - last_tick, time.time(), last_tick)
    t += 1

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_UP:
                keys[0] = True
            if event.key == pygame.K_DOWN:
                keys[1] = True
            if event.key == pygame.K_LEFT:
                keys[2] = True
            if event.key == pygame.K_RIGHT:
                keys[3] = True
        if event.type == pygame.KEYUP:
            if event.key == pygame.K_UP:
                keys[0] = False
            if event.key == pygame.K_DOWN:
                keys[1] = False
            if event.key == pygame.K_LEFT:
                keys[2] = False
            if event.key == pygame.K_RIGHT:
                keys[3] = False
        if event.type == pygame.USEREVENT:
            if event.event_type == 'game_tick':
                update()
                print('update', t)


    mouse_pos = pygame.mouse.get_pos()

    intrp_x = interpolate(oldx, x, time.time()-last_tick)
    intrp_y = interpolate(oldy, y, time.time()-last_tick)
    pygame.draw.rect(display, (255, 255, 255), (intrp_x, intrp_y, 100, 100), 10)
    pygame.draw.rect(display, (0, 0, 255), (intrp_x, intrp_y, 100, 100), 2)
    text = font.render(str(int(clock.get_fps())), True, (255, 255, 255))
    display.blit(text, (0, 0))

    render_main()
    clock.tick()
    #print(time.time())
    if time.time() - start_time > 10:
        pygame.quit()
        sys.exit()
