"""Run in a fresh background Blender process. Uses installed MPFB + Rigify.
No user preferences are saved; never run this inside an existing art session.
"""
from pathlib import Path
import math
import importlib
import bpy
import addon_utils
from mathutils import Vector

OUT = Path(__file__).resolve().parent
BLEND = OUT / "vega_base_treino_01.blend"
if BLEND.exists():
    raise RuntimeError("Arquivo já existe; escolha outra revisão antes de gerar novamente")
assert not bpy.data.filepath, "Executar somente com --factory-startup"
addon_utils.enable("rigify", default_set=True, persistent=False)
addon_utils.enable("bl_ext.blender_org.mpfb", default_set=True, persistent=False)
services = importlib.import_module("bl_ext.blender_org.mpfb.services")
HumanService = services.HumanService
TargetService = services.TargetService
RigService = services.RigService

# Only the default objects of this fresh process are removed.
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
macro = TargetService.get_default_macro_info_dict()
macro.update(gender=0.0, age=0.5, muscle=0.65, weight=0.5)
body = HumanService.create_human(macro_detail_dict=macro)
body.name = "Base_feminina_TREINO_nao_rosto_Vega"
for face in body.data.polygons:
    face.use_smooth = True
body.color = (0.30, 0.36, 0.42, 1)
meta = HumanService.add_builtin_rig(body, "rigify.human", import_weights=True)
rig = RigService.generate_rigify_rig(meta, name="Vega_CONTROLES", meta_rig_action="hide")
assert rig is not None
assert any(m.type == 'ARMATURE' and m.object == rig for m in body.modifiers)
assert len(body.vertex_groups) > 0
print("RIG_BONES", [b.name for b in rig.pose.bones if 'forearm_fk' in b.name or 'upper_arm_parent' in b.name])

# A small elbow exercise, not a combat animation or finished anatomy.
scene = bpy.context.scene
scene.frame_start, scene.frame_end = 1, 60
scene.render.fps = 30
for side in ('L', 'R'):
    rig.pose.bones['upper_arm_parent.' + side]['IK_FK'] = 1.0
arm = rig.pose.bones['forearm_fk.L']
arm.rotation_mode = 'XYZ'
for frame, angle in [(1, 0), (30, 65), (60, 0)]:
    arm.rotation_euler.x = math.radians(angle)
    arm.keyframe_insert(data_path='rotation_euler', frame=frame, group="Exercicio_cotovelo")
scene.timeline_markers.new("BASE", frame=1)
scene.timeline_markers.new("FLEXAO_TESTE", frame=30)
scene.timeline_markers.new("RETORNO", frame=60)

# Validate that the actual weighted surface changes when the control moves.
def evaluated_points(frame):
    scene.frame_set(frame)
    obj = body.evaluated_get(bpy.context.evaluated_depsgraph_get())
    mesh = obj.to_mesh()
    points = [v.co.copy() for v in mesh.vertices]
    obj.to_mesh_clear()
    return points
rest, bent = evaluated_points(1), evaluated_points(30)
assert len(rest) == len(bent)
moved = sum((a-b).length > 0.001 for a, b in zip(rest, bent))
assert moved > 50, "O controle não deformou a superfície"
print("VALIDACAO", bpy.app.version_string, "vertices_movidos", moved, "ossos", len(rig.data.bones))

camera_data = bpy.data.cameras.new("Camera_treino")
camera = bpy.data.objects.new("Camera_treino", camera_data)
scene.collection.objects.link(camera)
camera.location = (3.0, -6.5, 2.6)
camera.rotation_euler = (Vector((0, 0, 0.95)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera_data.type = 'ORTHO'
camera_data.ortho_scale = 2.25
scene.camera = camera
scene.render.engine = 'BLENDER_WORKBENCH'
scene.display.shading.light = 'STUDIO'
scene.display.shading.color_type = 'OBJECT'
scene.display.shading.background_type = 'WORLD'
scene.world.color = (0.035, 0.045, 0.06)
scene.render.resolution_x, scene.render.resolution_y = 800, 800
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = str(OUT / "flexao_teste.png")
bpy.ops.render.render(write_still=True)

scene.frame_set(1)
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode='POSE')
bpy.ops.pose.select_all(action='DESELECT')
rig.data.bones.active = rig.data.bones['forearm_fk.L']
for screen in bpy.data.screens:
    for area in screen.areas:
        if area.type == 'VIEW_3D':
            area.spaces.active.region_3d.view_distance = 3.2
            area.spaces.active.region_3d.view_location = Vector((0, 0, 1.0))
            area.spaces.active.region_3d.view_rotation = camera.rotation_euler.to_quaternion()
            area.spaces.active.shading.color_type = 'OBJECT'
scene['LEIA'] = "Base técnica. Espaço: flexão de cotovelo. Não é arte final da Vega. Referência de identidade: A/03."
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
print("ARQUIVO_PRONTO", BLEND)
