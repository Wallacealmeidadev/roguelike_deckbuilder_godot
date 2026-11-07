"""Inspecao somente leitura da base aceita, dentro do Blender."""
from pathlib import Path
import bpy
from mathutils import Vector
source = Path(__file__).resolve().parent.parent / 'vega_base_03/vega_cintura_abdomen_03.blend'
bpy.ops.wm.open_mainfile(filepath=str(source))
bpy.context.scene.frame_set(1)
body = bpy.data.objects['Base_feminina_TREINO_nao_rosto_Vega']
rig = bpy.data.objects['Vega_CONTROLES']
print('VERSION', bpy.app.version_string)
print('TRANSFORM', body.matrix_world)
print('MODIFIERS', [(m.name,m.type) for m in body.modifiers])
ev = body.evaluated_get(bpy.context.evaluated_depsgraph_get())
mesh = ev.to_mesh()
print('SURFACE',len(mesh.vertices),len(mesh.polygons))
for z in (.1,.2,.3,.5,.75,.85,.95,1.0,1.05,1.1,1.15,1.2,1.25,1.3,1.35,1.4,1.45,1.5,1.55):
    vs = [v.co for v in mesh.vertices if abs(v.co.z-z)<.015 and abs(v.co.x)<.25]
    if vs:
        print('SLICE',z,'X',round(min(v.x for v in vs),3),round(max(v.x for v in vs),3),'Y',round(min(v.y for v in vs),3),round(max(v.y for v in vs),3))
print('BONES', [(b.name,tuple(round(x,3) for x in b.head_local)) for b in rig.data.bones if b.name in ['DEF-spine','DEF-spine.001','DEF-spine.002','DEF-spine.003','DEF-thigh.L','DEF-shin.L','DEF-foot.L','DEF-toe.L']])
for pt in [(0,-.1,1.1),(.1,-.12,1.35),(.16,0,.2)]:
    v=min(mesh.vertices,key=lambda v:(v.co-Vector(pt)).length)
    print('WEIGHTS',tuple(v.co),[(body.vertex_groups[g.group].name,round(g.weight,3)) for g in v.groups if g.weight>.01])
ev.to_mesh_clear()
