width  = 500
height = 500

# Create empty scene and render context
scene = new seen.Scene
  model    : seen.Models.default()
  viewport : seen.Viewports.center(width, height)
  cullBackfaces : false
  camera   : new seen.Camera
          projection : seen.Projections.ortho()
#scene.shader = seen.Shaders["flat"]()

context = seen.Context('seen-canvas', scene).render()

# Enable drag-to-rotate on the canvas
dragger = new seen.Drag('seen-canvas', {inertia : false})
dragger.on('drag.rotate', (e) ->
  xform = seen.Quaternion.xyToTransform(e.offsetRelative...)
  scene.model.transform(xform)
  context.render()
)

#MBB beam
W=document.getElementById("mbb_width").value
H=document.getElementById("mbb_height").value
L=document.getElementById("mbb_length").value
P = [seen.P(-W/2,-H/2,-L/2),seen.P(W/2,-H/2,-L/2),seen.P(W/2,H/2,-L/2),seen.P(-W/2,H/2,-L/2),
seen.P(-W/2,-H/2,L/2),seen.P(W/2,-H/2,L/2),seen.P(W/2,H/2,L/2),seen.P(-W/2,H/2,L/2)]
shape = new seen.Shape('my shape',
[new seen.Surface([P[0],P[1],P[2],P[3]]),
new seen.Surface([P[4],P[5],P[6],P[7]]),
new seen.Surface([P[0],P[1],P[5],P[4]]),
new seen.Surface([P[3],P[2],P[6],P[7]]),
new seen.Surface([P[0],P[3],P[7],P[4]]),
new seen.Surface([P[1],P[2],P[6],P[5]])])
scene.model.scale(4)
scene.model.rotx(0.4)
scene.model.roty(-0.5)
scene.model.rotz(-0.2)

#Colors
for surf in shape.surfaces
   surf.fillMaterial.color = seen.Colors.hsl(0.5, 0.9, 0.8)
   surf.fillMaterial.specularColor = surf.fillMaterial.color
   surf.fillMaterial.specularExponent = 1
   surf.fillMaterial.metallic = true
   surf.dirty = true

scene.model.add(shape)
context.render()

root = exports ? this
root.updateShape = ->
    old_diagonal = Math.sqrt(W**2+H**2+L**2)
    W = document.getElementById("mbb_width").value
    H = document.getElementById("mbb_height").value
    L = document.getElementById("mbb_length").value
    P[0].x = -W/2
    P[0].y = -H/2
    P[0].z = -L/2
    P[1].x = W/2
    P[1].y = -H/2
    P[1].z = -L/2
    P[2].x = W/2
    P[2].y = H/2
    P[2].z = -L/2
    P[3].x = -W/2
    P[3].y = H/2
    P[3].z = -L/2
    P[4].x = -W/2
    P[4].y = -H/2
    P[4].z = L/2
    P[5].x = W/2
    P[5].y = -H/2
    P[5].z = L/2
    P[6].x = W/2
    P[6].y = H/2
    P[6].z = L/2
    P[7].x = -W/2
    P[7].y = H/2
    P[7].z = L/2
    for surf in shape.surfaces
       surf.dirty = true
    xform = seen.M().scale(old_diagonal/Math.sqrt(W**2+H**2+L**2))
    scene.model.transform(xform)
    context.render()

root.updateColor = (r,g,b) ->
    #Colors
    for surf in shape.surfaces
       surf.fillMaterial.color = seen.Colors.hsl(r, g, b)
       surf.fillMaterial.specularColor = surf.fillMaterial.color
       surf.dirty = true
    context.render()

Nodes = seen.Models.default()
scene.model.add(Nodes)
root.nodesCreation = (ele_size) ->
    ele_size = (Number) ele_size
    W = document.getElementById("mbb_width").value
    H = document.getElementById("mbb_height").value
    L = document.getElementById("mbb_length").value
    x = -W/2
    y = -H/2
    z = -L/2
    scene.model.remove(Nodes)
    Nodes = seen.Models.default()
    scene.model.add(Nodes)
    while z <= L/2
        while y <= H/2
            while x <= W/2
                #point = new seen.P(x,y,z,5)
                Nodes.add(seen.Shapes.cube()
                    .scale(1)
                    .translate(x,y,z)
                    .fill('#000000')
                )
                x = x + ele_size
            x = -W/2
            y = y + ele_size
        x = -W/2
        y = -H/2
        z = z + ele_size
    context.render()

