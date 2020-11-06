import json

from django.shortcuts import render
from django_ajax.decorators import ajax
from django.views.decorators.csrf import csrf_exempt
from .backend_FE import FE_classes, FE_Plots
import time

def fe_project(request):
    context = {}
    return render(request,'FE_project/index.html',context)

def loads(request):
    return render(request,'FE_project/loads.html')

def boundaries(request):
    return render(request,'FE_project/boundaries.html')

@ajax
@csrf_exempt
def run_FE_project(request):
    obj = dict(request.POST)
    Emodul = float(obj['Emodul'][0])
    Poisson = float(obj['Poisson'][0])
    mbb_width = float(obj['mbb_width'][0])
    mbb_height = float(obj['mbb_height'][0])
    mbb_length = float(obj['mbb_length'][0])
    eleSize = float(obj['eleSize'][0])
    Forces = json.loads(obj['Forces'][0])
    Boundaries = json.loads(obj['Boundaries'][0])

    #------------------------------------------------------

    # MODEL CREATION
    mdb = FE_classes.Mdb()

    # Model geometry and properties
    mdl = mdb.models['Model-1']
    part = mdl.Part('Part-1')

    mdl.Material('Material-1').Elastic(table=((Emodul, Poisson,),))
    mdl.HomogeneousSolidSection('Section-1', 'Material-1')

    part.uniformHexMesh(mbb_width, mbb_height, mbb_length, eleSize)  # MBB beam

    part.SectionAssignment(part.Set('Set-1', part.elements), 'Section-1')

    # Step and outputs
    step = mdl.StaticStep('Step-1')
    mdl.FieldOutputRequest('FieldOut-1', 'Step-1', variables=('MISESMAX', 'ESEDEN', 'EVOL', ))
    mdl.HistoryOutputRequest('FieldOut-1', 'Step-1', variables=('ALLWK',))

    # Load conditions
    count = 1
    for Force in Forces.values():
        F = json.loads(Force)
        if ("=" in F['x_f']) or (">" in F['x_f']) or ("<" in F['x_f']):
            func_x = lambda x: eval("x" + F['x_f'], {"x": x})
        else:
            func_x = lambda x: x == float(F['x_f'])
        if ("=" in F['y_f']) or (">" in F['y_f']) or ("<" in F['y_f']):
            func_y = lambda y: eval("y" + F['y_f'], {"y": y})
        else:
            func_y = lambda y: y == float(F['y_f'])
        if ("=" in F['z_f']) or (">" in F['z_f']) or ("<" in F['z_f']):
            func_z = lambda z: eval("z" + F['z_f'], {"z": z})
        else:
            func_z = lambda z: z == float(F['z_f'])

        regL = part.NodeRegionFromFunction(lambda x, y, z: func_x(x) and func_y(y) and func_z(z))
        mdl.ConcentratedForce('Load-' + str(count), 'Step-1', region=regL, cf1=float(F['fx'] if F['fx']!="" else 0), cf2=float(F['fy'] if F['fy']!="" else 0), cf3=float(F['fz'] if F['fz']!="" else 0))
        count += 1

    #Boundary conditions
    count = 1
    for Boundary in Boundaries.values():
        B = json.loads(Boundary)
        if ("=" in B['x_b']) or (">" in B['x_b']) or ("<" in B['x_b']):
            func_x = lambda x: eval("x" + B['x_b'], {"x": x})
        else:
            func_x = lambda x: x == float(B['x_b'])
        if ("=" in B['y_b']) or (">" in B['y_b']) or ("<" in B['y_b']):
            func_y = lambda y: eval("y" + B['y_b'], {"y": y})
        else:
            func_y = lambda y: y == float(B['y_b'])
        if ("=" in B['z_b']) or (">" in B['z_b']) or ("<" in B['z_b']):
            func_z = lambda z: eval("z" + B['z_b'], {"z": z})
        else:
            func_z = lambda z: z == float(B['z_b'])
        regBC = part.NodeRegionFromFunction(lambda x, y, z: func_x(x) and func_y(y) and func_z(z))
        mdl.DisplacementBC('BC-1', 'Step-1', region=regBC, u1=0 if B['b_x']=="1" else None, u2=0 if B['b_y']=="1" else None, u3=0 if B['b_z']=="1" else None)
        count += 1


    #mdb.saveAs('Example_model')
    # t_i = time.time()
    #
    # # Job
    mdb.Job('Job-1', 'Model-1').submit()
    mdb.jobs['Job-1'].waitForCompletion()
    odb = FE_classes.openOdb('FE_project\\backend_FE\\Output_files\\' + 'Job-1.odb')
    #
    # # PLOTS
    # # FE_Plots.undeformedNodePlot(mdl, part, step)
    # # FE_Plots.deformedNodePlot(mdl, part, step, odb, scale_factor=1)
    # # FE_Plots.FieldOutputHexMeshPlot(part, step, odb, 'MISESMAX')
    # FE_Plots.FieldOutputHexMeshPlot(part, step, odb, 'ESEDEN')
    # # FE_Plots.HistoryOutputPlot(odb, step, ['ALLWK'])
    #
    # # print(time.time() - t_i)

    max_u = 0
    for u in odb.steps['STEP-1'].frames[-1].fieldOutputs['U'].values.original_data:
        for c in u:
            max_u = max(max_u,abs(c))



    return {'MaxDisplacement': max_u,
            'Displacements': odb.steps['STEP-1'].frames[-1].fieldOutputs['U'].values.original_data,
            'VMises': odb.steps['STEP-1'].frames[-1].fieldOutputs['MISESMAX'].values.original_data,
            'MaxVM': max(odb.steps['STEP-1'].frames[-1].fieldOutputs['MISESMAX'].values.original_data),
            'MinVM': min(odb.steps['STEP-1'].frames[-1].fieldOutputs['MISESMAX'].values.original_data),
            'DeformationEnergyField': odb.steps['STEP-1'].frames[-1].fieldOutputs['ESEDEN'].values.original_data,
            'MaxDE': max(odb.steps['STEP-1'].frames[-1].fieldOutputs['ESEDEN'].values.original_data),
            'MinDE': min(odb.steps['STEP-1'].frames[-1].fieldOutputs['ESEDEN'].values.original_data),
            'TotalEnergy': odb.steps['STEP-1'].historyRegions['Assembly ASSEMBLY'].historyOutputs['ALLWK'].data[-1][1],
            }

