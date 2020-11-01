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

submodel = scene.model.append()
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
ms=document.getElementById("eleSize").value
ne_w = Math.round(W / ms)  # Calculating number of elements on each side
ne_h = Math.round(H / ms)
ne_l = Math.round(L / ms)
ms_w = W / ne_w
ms_h = H / ne_h
ms_d = L / ne_l  # calculating element sizes
Nodes = []
for k in [0..ne_l]
    for j in [0..ne_h]
        for i in [0..ne_w]
            Nodes.push seen.P(i * ms_w, j * ms_h, k * ms_d)  # Assigning coordinates
Elements_connectivity = []
for k in [0..ne_l - 1]  # Constructing connectivity vertor and each MeshElement object
    for j in [0..ne_h - 1]
        for i in [0..ne_w - 1]
            connectivity = []  # By the iterator, not the label
            for kk in [0, 1]
                for jj in [0, 1]
                    for ii in [0, 1]
                        connectivity.push ((ne_h + 1) * (ne_w + 1) * (k + kk) +
                                         (ne_w + 1) * (j + jj) + i + ii)
            Elements_connectivity.push connectivity
            count++
Elements = []
count=0
for e in Elements_connectivity
    submodel.add(new seen.Shape(count,[new seen.Surface([Nodes[e[0]],Nodes[e[1]],Nodes[e[3]],Nodes[e[2]]]),
                      new seen.Surface([Nodes[e[2]],Nodes[e[3]],Nodes[e[7]],Nodes[e[6]]]),
                      new seen.Surface([Nodes[e[6]],Nodes[e[7]],Nodes[e[5]],Nodes[e[4]]]),
                      new seen.Surface([Nodes[e[4]],Nodes[e[5]],Nodes[e[1]],Nodes[e[0]]]),
                      new seen.Surface([Nodes[e[0]],Nodes[e[2]],Nodes[e[6]],Nodes[e[4]]]),
                      new seen.Surface([Nodes[e[1]],Nodes[e[3]],Nodes[e[7]],Nodes[e[5]]])])
    )
    count++

#Colors
for shape in submodel.children
    for surf in shape.surfaces
       surf.fillMaterial.color = seen.Colors.hsl(0.5, 0.9, 0.8)
       surf.fillMaterial.specularColor = surf.fillMaterial.color
       surf.fillMaterial.specularExponent = 60
       surf.fillMaterial.metallic = true
       surf.dirty = true

submodel.translate(-W/2,-H/2,-L/2)
scale_coef = 4
scene.model.scale(scale_coef)
scene.model.rotx(0.4)
scene.model.roty(-0.5)
scene.model.rotz(-0.2)

context.render()

root = exports ? this
root.updateShape = ->
    W_old = W
    H_old = H
    L_old = L
    scene.model.remove(submodel)
    submodel = scene.model.append()
    #MBB beam
    W=document.getElementById("mbb_width").value
    H=document.getElementById("mbb_height").value
    L=document.getElementById("mbb_length").value
    ms=document.getElementById("eleSize").value
    ne_w = Math.round(W / ms)  # Calculating number of elements on each side
    ne_h = Math.round(H / ms)
    ne_l = Math.round(L / ms)
    ms_w = W / ne_w
    ms_h = H / ne_h
    ms_d = L / ne_l  # calculating element sizes
    Nodes = []
    for k in [0..ne_l]
        for j in [0..ne_h]
            for i in [0..ne_w]
                Nodes.push seen.P(i * ms_w, j * ms_h, k * ms_d)  # Assigning coordinates
    Elements_connectivity = []
    for k in [0..ne_l - 1]  # Constructing connectivity vertor and each MeshElement object
        for j in [0..ne_h - 1]
            for i in [0..ne_w - 1]
                connectivity = []  # By the iterator, not the label
                for kk in [0, 1]
                    for jj in [0, 1]
                        for ii in [0, 1]
                            connectivity.push ((ne_h + 1) * (ne_w + 1) * (k + kk) +
                                             (ne_w + 1) * (j + jj) + i + ii)
                Elements_connectivity.push connectivity
                count++
    Elements = []
    count=0
    for e in Elements_connectivity
        submodel.add(new seen.Shape(count,[new seen.Surface([Nodes[e[0]],Nodes[e[1]],Nodes[e[3]],Nodes[e[2]]]),
                          new seen.Surface([Nodes[e[2]],Nodes[e[3]],Nodes[e[7]],Nodes[e[6]]]),
                          new seen.Surface([Nodes[e[6]],Nodes[e[7]],Nodes[e[5]],Nodes[e[4]]]),
                          new seen.Surface([Nodes[e[4]],Nodes[e[5]],Nodes[e[1]],Nodes[e[0]]]),
                          new seen.Surface([Nodes[e[0]],Nodes[e[2]],Nodes[e[6]],Nodes[e[4]]]),
                          new seen.Surface([Nodes[e[1]],Nodes[e[3]],Nodes[e[7]],Nodes[e[5]]])])
        )
        count++
    for shape in submodel.children
        for surf in shape.surfaces
           surf.dirty = true
    submodel.translate(-W/2,-H/2,-L/2)
    Loads_model.translate((W_old/2)-(W/2),(H_old/2)-(H/2),(L_old/2)-(L/2))

    xform = seen.M().scale(Math.sqrt(W_old**2+H_old**2+L_old**2)/Math.sqrt(W**2+H**2+L**2))
    scene.model.transform(xform)
    context.render()

root.updateColor = (r,g,b) ->
    #Colors
    for shape in submodel.children
        for surf in shape.surfaces
           surf.fillMaterial.color = seen.Colors.hsl(r, g, b)
           surf.fillMaterial.specularColor = surf.fillMaterial.color
           surf.dirty = true
    context.render()

Loads = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
Loads_model = scene.model.append()
Loads_model.translate(-W/2,-H/2,-L/2)

arrows_scale_factor = 1

root.updateLoads = (id) ->
    i = String(id).substr(2,1)
    Ff = document.getElementById("load_frame").contentWindow.document.getElementById("FF" + i).value
    fx = document.getElementById("load_frame").contentWindow.document.getElementById("Fx" + i).value
    fy = document.getElementById("load_frame").contentWindow.document.getElementById("Fy" + i).value
    fz = document.getElementById("load_frame").contentWindow.document.getElementById("Fz" + i).value

    Loads_model.remove(Loads[i - 1])
    Loads[i - 1] = null

    Loads[i - 1] = new seen.Shapes.arrow(2,30,1,10).fill('#000000').translate(-30-10,0,0).rotz(Math.PI).myRotation([parseInt(fx,10),0,0,0,parseInt(fy,10),0,0,0,parseInt(fz,10),0,0,0])

    if Ff.indexOf(",") > 0
        coord = Ff.split(",")
        Loads[i - 1].translate(coord[0],coord[1],coord[2])

    Loads_model.add(Loads[i - 1])

    context.render()
