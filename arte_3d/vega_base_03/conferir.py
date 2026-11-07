"""Reabre a revisão salva, confere parâmetros e renderiza detalhe sem salvar o BLEND."""
from pathlib import Path
import bpy
from mathutils import Vector

out = Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(out / 'vega_cintura_abdomen_03.blend'))
body = bpy.data.objects['Base_feminina_TREINO_nao_rosto_Vega']
rig = bpy.data.objects['Vega_CONTROLES']
keys = body.data.shape_keys.key_blocks
assert abs(keys['Vega_03_cintura'].value - .4) < .0001
assert abs(keys['Vega_03_abdomen'].value - .85) < .0001
assert abs(keys['Vega_02_costas'].value - .35) < .0001
scene = bpy.context.scene
scene.frame_set(1)
a = rig.pose.bones['forearm_fk.L'].rotation_euler.x
scene.frame_set(30)
b = rig.pose.bones['forearm_fk.L'].rotation_euler.x
assert abs(b-a) > .5
scene.frame_set(1)
camera = scene.camera
camera.location = (0.8, -6, 1.15)
camera.rotation_euler = (Vector((0,0,1.1))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.ortho_scale = .8
scene.render.resolution_x = scene.render.resolution_y = 650
scene.render.filepath = str(out / 'abdomen_detalhe.png')
bpy.ops.render.render(write_still=True)
print('REABERTURA_03_OK', 'cintura', keys['Vega_03_cintura'].value, 'abdomen', keys['Vega_03_abdomen'].value)
