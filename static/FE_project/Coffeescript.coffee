#!!!No class for materials. Must be implemented in future versions

width  = parseInt(document.getElementById("seen-canvas").width.baseVal.value)
height = parseInt(document.getElementById("seen-canvas").height.baseVal.value)

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

#Initiating
CurrentColorR = 160
CurrentColorG = 200
CurrentColorB = 250
scale_coef = 4.5
scene.model.scale(scale_coef)
scene.model.rotx(0.4)
scene.model.roty(-0.5)
scene.model.rotz(-0.2)
W=document.getElementById("mbb_width").value
H=document.getElementById("mbb_height").value
L=document.getElementById("mbb_length").value
Nodes=null
Loads = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
Loads_model = scene.model.append()
Loads_model.translate(-W/2,-H/2,-L/2)
Boundaries = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
Boundaries_model = scene.model.append()
Boundaries_model.translate(-W/2,-H/2,-L/2)
bc_size = 0.1*(Math.min(W, H, L))
MaxDisplacement = null
Displacements = null
VMMises = null
DeformationEnergyField = null
VMises = null
MaxVM = null
MinVM = null
MaxDE = null
MinDE = null
DisplacementON = null
FieldOutputON = null

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
    for id in [1..document.getElementById("load_frame").contentWindow.document.body.children.length - 2]
        updateLoads("ff" + id)

    Boundaries_model.translate((W_old/2)-(W/2),(H_old/2)-(H/2),(L_old/2)-(L/2))
    for id in [1..document.getElementById("boundary_frame").contentWindow.document.body.children.length - 2]
        updateBoundaries("ff" + id)

    xform = seen.M().scale(Math.sqrt(W_old**2+H_old**2+L_old**2)/Math.sqrt(W**2+H**2+L**2))
    scene.model.transform(xform)
    updateColor(CurrentColorR, CurrentColorG, CurrentColorB)
    context.render()

    $("#outputBar").addClass("w3-hide")
    $("#text_results").addClass("w3-hide")
    $("#run_button").removeClass("w3-disabled")
    document.getElementById("run_button").addEventListener("click",run_cs)

root.updateColor = (r,g,b) ->
    CurrentColorR = r
    CurrentColorG = g
    CurrentColorB = b
    #Colors
    for shape in submodel.children
        for surf in shape.surfaces
           surf.fillMaterial.color = seen.Colors.rgb(CurrentColorR, CurrentColorG, CurrentColorB)
           surf.fillMaterial.specularColor = surf.fillMaterial.color
           surf.fillMaterial.specularExponent = 60
           surf.fillMaterial.metallic = true
           surf.dirty = true
    context.render()

root.updateLoads = (id) ->
    i = String(id).substr(2,1)
    x_f = document.getElementById("load_frame").contentWindow.document.getElementById("xf" + i).value
    y_f = document.getElementById("load_frame").contentWindow.document.getElementById("yf" + i).value
    z_f = document.getElementById("load_frame").contentWindow.document.getElementById("zf" + i).value
    fx = document.getElementById("load_frame").contentWindow.document.getElementById("Fx" + i).value
    fy = document.getElementById("load_frame").contentWindow.document.getElementById("Fy" + i).value
    fz = document.getElementById("load_frame").contentWindow.document.getElementById("Fz" + i).value

    Loads_model.remove(Loads[i - 1])
    Loads[i - 1] = null

    c = 1/(1+(fx))
    norm = Math.sqrt((fx**2) + (fy**2) + (fz**2))
    c = 1/(1+(fx/norm))

    if ("=" in x_f) | (">" in x_f) | ("<" in x_f)
        func_x = (x) -> eval("x".concat(x_f))
    else
        func_x = (x) -> x == parseInt(x_f)
    if ("=" in y_f) | (">" in y_f) | ("<" in y_f)
        func_y = (y) -> eval("y".concat(y_f))
    else
        func_y = (y) -> y == parseInt(y_f)
    if ("=" in z_f) | (">" in z_f) | ("<" in z_f)
        func_z = (z) -> eval("z".concat(z_f))
    else
        func_z = (z) -> z == parseInt(z_f)

    load_group = Loads_model.append()
    func = (x,y,z) -> func_x(x) & func_y(y) & func_z(z)
    count = 0
    for n in Nodes #Counting nodes to ajust size of th arrow
        if func(n.x,n.y,n.z)
            count++
    for n in Nodes
        if func(n.x,n.y,n.z)
            load_group.add(new seen.Shapes.arrow(1,(norm/(8*count)) + 2,1,3)
                   .fill('#000000')
                   .translate(-((norm/(8*count)) + 2)-3,0,0)
                   .rotz(Math.PI)
                   .matrix([((norm**2)+c*(-(fy**2)-(fz**2)))/(norm**2), -fy/(norm), -fz/(norm),  0,
                            fy/(norm) , ((norm**2)-c*(fy**2))/(norm**2) , (-c*fy*fz)/(norm**2) , 0,
                            fz/(norm) , (-c*fy*fz)/(norm**2) , ((norm**2)-c*(fz**2))/(norm**2) , 0,
                            0,0,0,1])
                   .translate(n.x,n.y,n.z))
    Loads[i - 1] = load_group
    context.render()

root.removeLoads = ->
    n_loads = document.getElementById("load_frame").contentWindow.document.body.children.length - 2
    for count in [1..Loads.length]
        if count > n_loads
            Loads_model.remove(Loads[count-1])
            Loads[count-1] = null
    context.render()

root.updateBoundaries = (id) ->
    i = String(id).substr(2,1)
    x_b = document.getElementById("boundary_frame").contentWindow.document.getElementById("xb" + i).value
    y_b = document.getElementById("boundary_frame").contentWindow.document.getElementById("yb" + i).value
    z_b = document.getElementById("boundary_frame").contentWindow.document.getElementById("zb" + i).value
    b_x = document.getElementById("boundary_frame").contentWindow.document.getElementById("Bx" + i).value #0 or 1
    b_y = document.getElementById("boundary_frame").contentWindow.document.getElementById("By" + i).value
    b_z = document.getElementById("boundary_frame").contentWindow.document.getElementById("Bz" + i).value

    Boundaries_model.remove(Boundaries[i - 1])
    Boundaries[i - 1] = null

    if ("=" in x_b) | (">" in x_b) | ("<" in x_b)    #'Differencing between pure value and inequation
        func_x = (x) -> eval("x".concat(x_b))
    else
        func_x = (x) -> x == parseInt(x_b)
    if ("=" in y_b) | (">" in y_b) | ("<" in y_b)
        func_y = (y) -> eval("y".concat(y_b))
    else
        func_y = (y) -> y == parseInt(y_b)
    if ("=" in z_b) | (">" in z_b) | ("<" in z_b)
        func_z = (z) -> eval("z".concat(z_b))
    else
        func_z = (z) -> z == parseInt(z_b)

    boundaries_group = Boundaries_model.append()     #Group created for 1 BC made by inequations (many nodes)
    func = (x,y,z) -> func_x(x) & func_y(y) & func_z(z)
    for n in Nodes
        if func(n.x,n.y,n.z)
            if b_x == "1"
                boundaries_group.add(new seen.Shapes.pyramid().translate(-0.5,-1,-0.5)
                                        .rotz(Math.PI/2).fill('#A52A2A').scale(bc_size).translate(n.x,n.y,n.z))
                boundaries_group.add(new seen.Shapes.pyramid().translate(-0.5,-1,-0.5).rotx(Math.PI)
                                        .rotz(Math.PI/2).fill('#A52A2A').scale(bc_size).translate(n.x,n.y,n.z))
            if b_y == "1"
                boundaries_group.add(new seen.Shapes.pyramid().translate(-0.5,-1,-0.5)
                                        .fill('#A52A2A').scale(bc_size).translate(n.x,n.y,n.z))
                boundaries_group.add(new seen.Shapes.pyramid().translate(-0.5,-1,-0.5).rotx(Math.PI)
                                        .fill('#A52A2A').scale(bc_size).translate(n.x,n.y,n.z))
            if b_z == "1"
                boundaries_group.add(new seen.Shapes.pyramid().translate(-0.5,-1,-0.5)
                                        .rotx(Math.PI/2).fill('#A52A2A').scale(bc_size).translate(n.x,n.y,n.z))
                boundaries_group.add(new seen.Shapes.pyramid().translate(-0.5,-1,-0.5).rotx(Math.PI)
                                        .rotx(Math.PI/2).fill('#A52A2A').scale(bc_size).translate(n.x,n.y,n.z))

    Boundaries[i - 1] = boundaries_group
    context.render()


root.removeBoundaries = ->
    n_boundaries = document.getElementById("boundary_frame").contentWindow.document.body.children.length - 2
    for count in [1..Boundaries.length]
        if count > n_boundaries
            Boundaries_model.remove(Boundaries[count-1])
            Boundaries[count-1] = null
    context.render()

root.run_cs = ->
    $("#loadingSpan").removeClass("w3-hide")
    submit_obj =
        'Emodul' : document.getElementById("Emodul").value
        'Poisson' : document.getElementById("Poisson").value
        'mbb_width' : document.getElementById("mbb_width").value
        'mbb_height' : document.getElementById("mbb_height").value
        'mbb_length' : document.getElementById("mbb_length").value
        'eleSize' : document.getElementById("eleSize").value
    forces = {}
    for l in [1..document.getElementById("load_frame").contentWindow.document.body.children.length - 3]
        force =
            x_f : document.getElementById("load_frame").contentWindow.document.getElementById("xf" + l).value
            y_f : document.getElementById("load_frame").contentWindow.document.getElementById("yf" + l).value
            z_f : document.getElementById("load_frame").contentWindow.document.getElementById("zf" + l).value
            fx : document.getElementById("load_frame").contentWindow.document.getElementById("Fx" + l).value
            fy : document.getElementById("load_frame").contentWindow.document.getElementById("Fy" + l).value
            fz : document.getElementById("load_frame").contentWindow.document.getElementById("Fz" + l).value
        forces["Force" + l] = JSON.stringify(force)
    submit_obj["Forces"] = JSON.stringify(forces)
    boundaries = {}
    for i in [1..document.getElementById("boundary_frame").contentWindow.document.body.children.length - 3]
         boundary =
            x_b : document.getElementById("boundary_frame").contentWindow.document.getElementById("xb" + i).value
            y_b : document.getElementById("boundary_frame").contentWindow.document.getElementById("yb" + i).value
            z_b : document.getElementById("boundary_frame").contentWindow.document.getElementById("zb" + i).value
            b_x : document.getElementById("boundary_frame").contentWindow.document.getElementById("Bx" + i).value #0 or 1
            b_y : document.getElementById("boundary_frame").contentWindow.document.getElementById("By" + i).value
            b_z : document.getElementById("boundary_frame").contentWindow.document.getElementById("Bz" + i).value
         boundaries["Boundary" + i] = JSON.stringify(boundary)
    submit_obj["Boundaries"] = JSON.stringify(boundaries)
    jQuery.post('run',submit_obj, (obj_out) ->
        MaxDisplacement = obj_out.content.MaxDisplacement
        Displacements = obj_out.content.Displacements

        VMises = obj_out.content.VMises
        MaxVM = obj_out.content.MaxVM
        MinVM = obj_out.content.MinVM
        DeformationEnergyField = obj_out.content.DeformationEnergyField
        MaxDE = obj_out.content.MaxDE
        MinDE = obj_out.content.MinDE

        for l in Loads
            Loads_model.remove(l)
        for b in Boundaries
            Boundaries_model.remove(b)

        DisplacementON = 1
        FieldOutputON = 1

        updateDisplacement()
        updateFieldOutput()

        $("#outputBar").removeClass("w3-hide")
        $("#text_results").removeClass("w3-hide")
        $("#text_results").html("Max. stress: " + MaxVM.toFixed(3) + "<br>Max. displacement: " + MaxDisplacement.toFixed(3))
        $("#run_button").addClass("w3-disabled")
        document.getElementById("run_button").removeEventListener("click",run_cs)
        $("#loadingSpan").addClass("w3-hide")
        )


root.updateDisplacement = ->
    if DisplacementON == 1
        sign = 1
        DisplacementON = 0
        $("#displacement").text("Displacement ON")
    else
        sign = -1
        DisplacementON = 1
        $("#displacement").text("Displacement OFF")
    scale_factor = 0.15*Math.max(W, H, L)/MaxDisplacement
    #Displacements
    i = 0
    for n in Nodes
        n.x = n.x + sign*Displacements[i][0]*scale_factor
        n.y = n.y + sign*Displacements[i][1]*scale_factor
        n.z = n.z + sign*Displacements[i][2]*scale_factor
        i++
    for shape in submodel.children
        for surf in shape.surfaces
           surf.dirty = true
    context.render()

root.updateFieldOutput = ->
    if FieldOutputON == 1 #Von Mises
        Field = VMises
        MaxField = MaxVM
        MinField = MinVM
        $("#fieldOutput").text("Von Mises stress")
        FieldOutputON = 2
    else if FieldOutputON == 2 #Energy
        Field = DeformationEnergyField
        MaxField = MaxDE
        MinField = MinDE
        $("#fieldOutput").text("Deformation energy")
        FieldOutputON = 0
    else         #No field
        $("#fieldOutput").text("No field output")
        FieldOutputON = 1
    #Colors
    for shape, value in submodel.children
        if FieldOutputON == 1
            R = CurrentColorR
            G = CurrentColorG
            B = CurrentColorB
            A = 255
        else
            stress_ratio = (Field[value] - MinField)/(MaxField - MinField)
            R = stress_ratio * 255
            G = 0
            B = (1 - stress_ratio) * 255
            A = 150
        for surf in shape.surfaces
            surf.fillMaterial = new seen.Material()
            surf.fillMaterial.color = seen.Colors.rgb(R, G, B, A)
            surf.fillMaterial.specularColor = surf.fillMaterial.color
            surf.dirty = true
    context.render()

root.onload = ->
    document.getElementById('load_frame').contentWindow.updateLoads = updateLoads;
    document.getElementById('load_frame').contentWindow.removeLoads = removeLoads;
    document.getElementById('load_frame').contentWindow.updateShape = updateShape;
    document.getElementById('boundary_frame').contentWindow.updateBoundaries = updateBoundaries;
    document.getElementById('boundary_frame').contentWindow.removeBoundaries = removeBoundaries;
    document.getElementById('boundary_frame').contentWindow.updateShape = updateShape;
    updateShape()