"""Revisão localizada da base 01. Executar no Blender em background."""
from pathlib import Path
import hashlib
import importlib
import json
import math
import bpy
import addon_utils
from mathutils import Vector

OUT = Path(__file__).resolve().parent
SOURCE = OUT.parent / 'vega_base_01' / 'vega_base_treino_01.blend'
DEST = OUT / 'vega_proporcoes_02.blend'
assert not DEST.exists(), 'Revisão já existe; não sobrescrever trabalho do usuário'
source_hash = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
addon_utils.enable('rigify', default_set=True, persistent=False)
addon_utils.enable('bl_ext.blender_org.mpfb', default_set=True, persistent=False)
services = importlib.import_module('bl_ext.blender_org.mpfb.services')
scene = bpy.context.scene
rig = bpy.data.objects['Vega_CONTROLES']
body = bpy.data.objects['Base_feminina_TREINO_nao_rosto_Vega']
if bpy.context.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')
scene.frame_set(1)

def points(frame):
    scene.frame_set(frame)
    bpy.context.view_layer.update()
    obj = body.evaluated_get(bpy.context.evaluated_depsgraph_get())
    mesh = obj.to_mesh()
    result = [v.co.copy() for v in mesh.vertices]
    obj.to_mesh_clear()
    return result

before = points(1)
old_rig_count = len(rig.data.bones)
old_action = rig.animation_data.action
old_slot = rig.animation_data.action_slot
old_fk = {side: rig.pose.bones['upper_arm_parent.' + side]['IK_FK'] for side in ('L', 'R')}
old_topology = len(body.data.vertices)
old_weights = [(g.name, g.index) for g in body.vertex_groups]
# Frozen comparison surface, created only in this new in-memory scene.
mesh_before = bpy.data.meshes.new_from_object(body.evaluated_get(bpy.context.evaluated_depsgraph_get()))
targets_dir = Path(services.LocationService.get_mpfb_data('targets'))
targets = {
    'torso/torso-scale-horiz-incr.target.gz': ('Vega_02_largura_tronco', .18),
    'torso/torso-muscle-dorsi-incr.target.gz': ('Vega_02_costas', .35),
}
for side in ('l', 'r'):
    targets[f'arms/{side}-upperarm-shoulder-muscle-incr.target.gz'] = (f'Vega_02_ombro_{side}', .55)
    targets[f'legs/{side}-upperleg-muscle-incr.target.gz'] = (f'Vega_02_coxa_{side}', .25)
    targets[f'legs/{side}-lowerleg-muscle-incr.target.gz'] = (f'Vega_02_panturrilha_{side}', .15)
for relative, (name, weight) in targets.items():
    services.TargetService.load_target(body, str(targets_dir / relative), weight=weight, name=name)

# MPFB refits the retained metarig to the changed surface and regenerates
# its existing Rigify rig. Do not stretch the whole generated skeleton.
services.RigService.refit_existing_armature(rig, body)
rig.animation_data_create()
rig.animation_data.action = old_action
rig.animation_data.action_slot = old_slot
for side, value in old_fk.items():
    rig.pose.bones['upper_arm_parent.' + side]['IK_FK'] = value
scene.frame_set(1)
assert len(body.data.vertices) == old_topology
assert len(rig.data.bones) == old_rig_count
assert rig.animation_data.action == old_action
assert [(g.name, g.index) for g in body.vertex_groups] == old_weights
assert any(m.type == 'ARMATURE' and m.object == rig for m in body.modifiers)
after = points(1)
assert len(before) == len(after)
changes = [(a-b).length for a,b in zip(before, after)]
assert sum(d > .001 for d in changes) > 100
height = max(v.z for v in before)
head_drift = max((a-b).length for a,b in zip(before,after) if a.z > height * .88)
assert head_drift < .0001, f'Cabeça sofreu deslocamento: {head_drift}'
assert abs(max(v.z for v in after) - height) < .0001
rest, bent = after, points(30)
moved = sum((a-b).length > .001 for a,b in zip(rest,bent))
assert moved > 50
assert all(math.isfinite(c) for v in bent for c in v)
print('PROPORCOES_OK', 'alterados', sum(d > .001 for d in changes), 'cabeca_desvio_m', head_drift, 'flexao_vertices', moved)

# Small before/after board rendered by Blender, same lens and lighting.
scene.frame_set(1)
mesh_after = bpy.data.meshes.new_from_object(body.evaluated_get(bpy.context.evaluated_depsgraph_get()))
body.hide_render = True
camera = scene.camera
saved_camera = (camera.location.copy(), camera.rotation_euler.copy(), camera.data.ortho_scale)
camera.location = (0, -7, 1.05)
camera.rotation_euler = (Vector((0,0,1.05))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.ortho_scale = 2.7
snapshots = []
for i, mesh in enumerate((mesh_before, mesh_after)):
    obj = bpy.data.objects.new('Comparacao_temporaria', mesh)
    scene.collection.objects.link(obj)
    obj.location.x = -.62 if i == 0 else .62
    obj.color = body.color
    snapshots.append(obj)
    font = bpy.data.curves.new('Legenda_temporaria', 'FONT')
    font.body = '01 / BASE' if i == 0 else '02 / PROPORCOES'
    font.align_x = 'CENTER'
    font.size = .065
    label = bpy.data.objects.new('Legenda_temporaria', font)
    scene.collection.objects.link(label)
    label.location = (obj.location.x, -.3, 1.92)
    label.rotation_euler = camera.rotation_euler
    label.color = (.8,.88,.95,1)
    snapshots.append(label)
scene.render.resolution_x, scene.render.resolution_y = 1100, 900
scene.render.filepath = str(OUT / 'comparacao.png')
bpy.ops.render.render(write_still=True)
for obj in snapshots:
    # Only the temporary comparison objects created above, never user objects.
    data = obj.data
    bpy.data.objects.remove(obj, do_unlink=True)
    if isinstance(data, bpy.types.Mesh):
        bpy.data.meshes.remove(data)
    else:
        bpy.data.curves.remove(data)
body.hide_render = False
camera.location, camera.rotation_euler, camera.data.ortho_scale = saved_camera
scene.render.resolution_x, scene.render.resolution_y = 800, 800
scene.frame_set(30)
scene.render.filepath = str(OUT / 'flexao.png')
bpy.ops.render.render(write_still=True)
scene.frame_set(1)
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode='POSE')
scene['LEIA'] = 'Revisão 02: proporções corporais candidatas. Espaço reproduz o mesmo teste de cotovelo. Rosto genérico inalterado.'
bpy.ops.wm.save_as_mainfile(filepath=str(DEST), compress=True)
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest() == source_hash
report = {'blender': bpy.app.version_string, 'fonte_sha256': source_hash,
          'vertices_corpo': old_topology, 'ossos': len(rig.data.bones),
          'vertices_proporcoes_maior_1mm': sum(d>.001 for d in changes),
          'desvio_max_cabeca_m': head_drift, 'vertices_flexao_maior_1mm': moved,
          'parametros': {name: weight for name,weight in targets.values()}}
print('RELATORIO', json.dumps(report, ensure_ascii=False))
