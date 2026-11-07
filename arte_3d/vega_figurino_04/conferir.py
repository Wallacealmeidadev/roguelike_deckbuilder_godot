"""Reabre o arquivo final; confere base, pesos e deformacao sem salvar alteracoes."""
from pathlib import Path
import hashlib
import json
import math
import bpy
from mathutils import Vector

out=Path(__file__).resolve().parent
source=out.parent/'vega_base_03/vega_cintura_abdomen_03.blend'
dest=out/'vega_figurino_04.blend'
body_name='Base_feminina_TREINO_nao_rosto_Vega'

def signature(body):
    h=hashlib.sha256()
    for key in body.data.shape_keys.key_blocks:
        h.update(key.name.encode('utf-8'))
        h.update(float(key.value).hex().encode())
        for v in key.data:
            for c in v.co:
                h.update(float(c).hex().encode())
    for p in body.data.polygons:
        h.update(str(tuple(p.vertices)).encode())
    return h.hexdigest()

bpy.ops.wm.open_mainfile(filepath=str(source))
original=signature(bpy.data.objects[body_name])
bpy.ops.wm.open_mainfile(filepath=str(dest))
scene=bpy.context.scene
body=bpy.data.objects[body_name]
rig=bpy.data.objects['Vega_CONTROLES']
assert signature(body)==original, 'Geometria ou shape keys da base foram alterados'
assert hashlib.sha256(source.read_bytes()).hexdigest()==scene['FONTE_03_SHA256']
outfit=list(bpy.data.collections['04_FIGURINO | pecas editaveis'].objects)
assert len(outfit)==31
assert len(rig.data.bones)==930
assert scene.frame_start==1 and scene.frame_end==60
assert bpy.context.mode=='OBJECT'
for obj in outfit:
    assert obj.type=='MESH'
    assert any(m.type=='ARMATURE' and m.object==rig for m in obj.modifiers)
    for v in obj.data.vertices:
        assert all(math.isfinite(c) for c in v.co)
        total=sum(g.weight for g in v.groups if obj.vertex_groups[g.group].name.startswith('DEF-'))
        assert .98<total<1.02, (obj.name,v.index,total)

def positions(obj):
    bpy.context.view_layer.update()
    ev=obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
    mesh=ev.to_mesh()
    result=[v.co.copy() for v in mesh.vertices]
    ev.to_mesh_clear()
    assert all(math.isfinite(c) for p in result for c in p)
    return result

scene.frame_set(1)
rest=positions(body)
for obj in outfit:
    positions(obj)
scene.frame_set(30)
bent=positions(body)
for obj in outfit:
    positions(obj)
elbow_moved=sum((a-b).length>.001 for a,b in zip(rest,bent))
assert elbow_moved>50
assert abs(rig.pose.bones['forearm_fk.L'].rotation_euler.x-math.radians(65))<.001
scene.frame_set(1)

# One small leg pose, isolated in memory, checks that cloth actually follows
# the leg rather than simply having an Armature modifier assigned.
pants=bpy.data.objects['02_CALCA | corte solto']
boot=bpy.data.objects['04_BOTA.L | cano e peito']
controls=[b.name for b in rig.pose.bones if b.name.startswith('foot_ik.')]
assert 'foot_ik.L' in controls
pants_before=positions(pants)
boot_before=positions(boot)
control=rig.pose.bones['foot_ik.L']
old=control.matrix.copy()
pose=old.copy()
pose.translation+=Vector((.015,-.03,.075))
control.matrix=pose
bpy.context.view_layer.update()
pants_after=positions(pants)
boot_after=positions(boot)
leg_moved=sum((a-b).length>.001 for a,b in zip(pants_before,pants_after))
boot_moved=sum((a-b).length>.001 for a,b in zip(boot_before,boot_after))
assert leg_moved>50 and boot_moved>20
scene.render.resolution_x=880
scene.render.resolution_y=1000
scene.render.filepath=str(out/'teste_perna.png')
bpy.ops.render.render(write_still=True)
control.matrix=old
report={'blender':bpy.app.version_string,'assinatura_corpo_igual':True,'pecas':len(outfit),
        'vertices_corpo_flexao_maior_1mm':elbow_moved,'vertices_calca_teste_perna_maior_1mm':leg_moved,
        'vertices_bota_teste_perna_maior_1mm':boot_moved,'sha256_blend':hashlib.sha256(dest.read_bytes()).hexdigest(),
        'limitacao':'Teste de cotovelo e um deslocamento pequeno de pe; nao certifica guarda, soco, poses extremas ou simulacao de tecido.'}
(out/'verificacao.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('REABERTURA_FIGURINO_OK',json.dumps(report,ensure_ascii=False))
