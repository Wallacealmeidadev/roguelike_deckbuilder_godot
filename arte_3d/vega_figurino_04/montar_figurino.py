"""Figurino inicial nativo: malhas separadas, base 03 preservada.

Execute com Blender --background --factory-startup --python-exit-code 1.
Nao requer addons, rede nem scripts de UI do Rigify habilitados.
"""
from pathlib import Path
from collections import defaultdict
import hashlib
import json
import math
import sys
import bpy
import bmesh
from mathutils import Vector
from mathutils.kdtree import KDTree
from mathutils.bvhtree import BVHTree

OUT = Path(__file__).resolve().parent
SOURCE = OUT.parent / 'vega_base_03/vega_cintura_abdomen_03.blend'
DEST = OUT / 'vega_figurino_04.blend'
if DEST.exists():
    # Used only while reviewing this newly generated file, before delivery.
    assert '--replace-sha256' in sys.argv, 'Nao sobrescrever revisao ja entregue.'
    expected=sys.argv[sys.argv.index('--replace-sha256')+1].lower()
    assert hashlib.sha256(DEST.read_bytes()).hexdigest()==expected, 'Arquivo mudou; preservar.'
source_hash = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
scene = bpy.context.scene
if bpy.context.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')
scene.frame_set(1)
body = bpy.data.objects['Base_feminina_TREINO_nao_rosto_Vega']
rig = bpy.data.objects['Vega_CONTROLES']
action_name = rig.animation_data.action.name
body_keys = {k.name: k.value for k in body.data.shape_keys.key_blocks}
ev = body.evaluated_get(bpy.context.evaluated_depsgraph_get())
base = bpy.data.meshes.new_from_object(ev)
coords = [v.co.copy() for v in base.vertices]
weights = []
for v in base.vertices:
    ws = {body.vertex_groups[g.group].name: g.weight for g in v.groups
          if body.vertex_groups[g.group].name.startswith('DEF-') and g.weight > .0001}
    total = sum(ws.values())
    weights.append({name: w/total for name,w in ws.items()})
tree = KDTree(len(coords))
for i,p in enumerate(coords):
    tree.insert(p,i)
tree.balance()
collection = bpy.data.collections.new('04_FIGURINO | pecas editaveis')
scene.collection.children.link(collection)
garments = []

def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color,1)
    # Blender 5.2 creates node-based materials by default.
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color,1)
    bsdf.inputs['Roughness'].default_value = .86
    return mat

coal = material('Tecido | carvao', (.045,.048,.055))
pants_mat = material('Tecido | grafite', (.068,.071,.079))
wine = material('Tecido | vinho fechado', (.20,.022,.055))
wine_edge = material('Bainhas | vinho escuro', (.11,.012,.029))
rubber = material('Solas | borracha', (.018,.020,.025))
leather = material('Botas | couro fosco', (.043,.036,.036))
seam_mat = material('Costuras | grafite', (.105,.105,.115))
metal = material('Ilhoses | aco escuro', (.18,.19,.21))

def bind(obj, source_ids=None, fixed_bone=None):
    buckets = defaultdict(list)
    for i,v in enumerate(obj.data.vertices):
        if fixed_bone:
            ws = {fixed_bone:1.0}
        elif source_ids is not None:
            ws = weights[source_ids[i]]
        else:
            near = tree.find_n(v.co, 4)
            ws = defaultdict(float)
            for _,idx,d in near:
                factor = 1.0 / max(d,.002)**2
                for name,w in weights[idx].items():
                    ws[name] += w*factor
            total=sum(ws.values())
            ws={n:w/total for n,w in ws.items() if w/total>.001}
        for name,w in ws.items():
            buckets[name].append((i,w))
    for name,items in buckets.items():
        group=obj.vertex_groups.new(name=name)
        for i,w in items:
            group.add([i],w,'REPLACE')
    mod=obj.modifiers.new('Mesmo rig da base aprovada','ARMATURE')
    mod.object=rig
    mod.use_deform_preserve_volume=True

def mesh_object(name, verts, faces, mat, source_ids=None, thickness=.003, sub=1, fixed_bone=None):
    data=bpy.data.meshes.new(name)
    data.from_pydata(verts,[],faces)
    data.update()
    bm=bmesh.new()
    bm.from_mesh(data)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(data)
    bm.free()
    obj=bpy.data.objects.new(name,data)
    collection.objects.link(obj)
    data.materials.append(mat)
    obj.color=mat.diffuse_color
    for p in data.polygons:
        p.use_smooth=True
    bind(obj,source_ids,fixed_bone)
    if sub:
        mod=obj.modifiers.new('Suavidade de tecido','SUBSURF')
        mod.levels=sub
        mod.render_levels=sub
    if thickness:
        mod=obj.modifiers.new('Espessura real','SOLIDIFY')
        mod.thickness=thickness
        mod.offset=0
    garments.append(obj)
    return obj

def smooth_points(verts,faces,steps=.0,boundary_only=False):
    adjacent=defaultdict(set)
    edges=defaultdict(int)
    for face in faces:
        for a,b in zip(face,face[1:]+face[:1]):
            adjacent[a].add(b)
            adjacent[b].add(a)
            edges[tuple(sorted((a,b)))]+=1
    boundary={i for edge,count in edges.items() if count==1 for i in edge}
    for _ in range(int(steps)):
        old=[v.copy() for v in verts]
        for i,neighbors in adjacent.items():
            if boundary_only and i not in boundary:
                continue
            use=neighbors & boundary if i in boundary else neighbors
            if use:
                avg=sum((old[j] for j in use),Vector())/len(use)
                verts[i]=old[i].lerp(avg,.45)
    return verts

def extract(name,predicate,transform,mat,smoothing):
    polys=[tuple(p.vertices) for p in base.polygons if predicate(p.center)]
    ids=sorted({i for p in polys for i in p})
    lookup={old:new for new,old in enumerate(ids)}
    faces=[tuple(lookup[i] for i in p) for p in polys]
    vs=[coords[i].copy() for i in ids]
    smooth_points(vs,faces,smoothing)
    smooth_points(vs,faces,4,True)
    vs=[transform(v,i) for v,i in zip(vs,ids)]
    return mesh_object(name,vs,faces,mat,ids)

def shirt_region(p):
    if not (.932 < p.z < 1.40 and abs(p.x)<.15):
        return False
    # Round neckline; broad straps and open armholes.
    neckline = (1.245 if p.y<-.02 else 1.292)+.072*(abs(p.x)/.080)**2
    if p.z>neckline:
        return False
    arm_width=.154-.031*max(0,math.sin(math.pi*(p.z-1.15)/.175)) if p.z>1.15 else .154
    return abs(p.x)<arm_width

def shirt_fit(v,i):
    p=v.copy()
    radial=Vector((p.x,p.y+.035,0)).normalized()
    p+=radial*.014
    # Fit a broad fabric envelope across the chest, without skin normals.
    if p.y<-.055 and 1.07<p.z<1.255:
        depth=profile(p.z,[(1.07,.108),(1.10,.138),(1.15,.155),(1.20,.145),(1.255,.095)])
        surface=-.040-depth*math.sqrt(max(.12,1-(p.x/.18)**2))
        blend=min(1,(p.z-1.07)/.025,(1.255-p.z)/.025)
        p.y=p.y*(1-blend)+surface*blend
    # Broad cloth folds at the waist, millimetric rather than sculpted abs.
    if .94<p.z<1.075:
        p.y += .0035*math.sin(66*p.z+13*p.x)*max(0,1-abs(p.x)/.16)
    if coords[i].z>1.20:
        # Above the chest, preserve the original continuous shoulder topology.
        # Laplacian contraction here would pull the strap inside the shoulder.
        shoulder=coords[i]+base.vertices[i].normal*.018
        p=p.lerp(shoulder,min(1,(coords[i].z-1.20)/.045))
    return p

def profile(z,values):
    if z<=values[0][0]:
        return values[0][1]
    for (z0,a),(z1,b) in zip(values,values[1:]):
        if z<=z1:
            t=(z-z0)/(z1-z0)
            return a+(b-a)*t
    return values[-1][1]

shirt=extract('01_REGATA | carvao',shirt_region,shirt_fit,coal,12)
# Relax the cut edge on the shoulder surface, rather than keeping the stair
# steps of the underlying skin topology in the neckline.
shirt_faces=[tuple(p.vertices) for p in shirt.data.polygons]
shirt_points=[v.co.copy() for v in shirt.data.vertices]
smooth_points(shirt_points,shirt_faces,18,True)
skin_surface=BVHTree.FromPolygons(coords,[tuple(p.vertices) for p in base.polygons])
for v,p in zip(shirt.data.vertices,shirt_points):
    if p.z>1.22:
        point,normal,_,_=skin_surface.find_nearest(p)
        p=point+normal*.014
    v.co=p
shirt.data.update()

def trouser_fit(v,i):
    p=v.copy()
    z=p.z
    sign=1 if p.x>=0 else -1
    center_x=sign*(.095+.07*max(0,min(1,(.81-z)/.66)))
    center_y=-.035
    angle=math.atan2((p.y-center_y),p.x-center_x)
    rx=profile(z,[(.145,.056),(.20,.074),(.32,.077),(.46,.086),(.58,.094),(.72,.108),(.81,.112)])
    ry=profile(z,[(.145,.058),(.22,.080),(.46,.088),(.65,.108),(.81,.134)])
    leg=Vector((center_x+rx*math.cos(angle),center_y+ry*math.sin(angle),z))
    pelvic_angle=math.atan2((p.y-center_y)/1.0,p.x)
    pelvis=Vector((profile(z,[(.78,.215),(.86,.198),(.963,.141)])*math.cos(pelvic_angle),
                   center_y+profile(z,[(.78,.148),(.86,.148),(.963,.105)])*math.sin(pelvic_angle),z))
    blend=max(0,min(1,(z-.77)/.09))
    p=leg.lerp(pelvis,blend)
    # Gather the cloth near the cuff and knee; no cargo plates.
    radial=Vector((p.x-center_x,p.y-center_y,0))
    if radial.length>0:
        a=math.atan2(radial.y,radial.x)
        wrinkle=(.006*math.sin(z*105+a*2)*math.exp(-((z-.22)/.09)**2)
                 +.004*math.sin(z*58+a*3)*math.exp(-((z-.47)/.12)**2))
        p+=radial.normalized()*wrinkle
    return p

pants=extract('02_CALCA | corte solto',lambda p:.145<p.z<.963 and abs(p.x)<.27,trouser_fit,pants_mat,10)

# Keep original anatomy, hide only its covered lower surface in this outfit.
# Evaluate without helper masks briefly to retain original vertex indices.
helper_masks=[m for m in body.modifiers if m.type=='MASK']
for mod in helper_masks:
    mod.show_viewport=False
bpy.context.view_layer.update()
full=body.evaluated_get(bpy.context.evaluated_depsgraph_get())
full_mesh=full.to_mesh()
assert len(full_mesh.vertices)==len(body.data.vertices)
covered=[v.index for v in full_mesh.vertices if v.co.z<.930 and abs(v.co.x)<.28]
full.to_mesh_clear()
for mod in helper_masks:
    mod.show_viewport=True
covered_group=body.vertex_groups.new(name='04_Corpo_sob_calca_preservado')
covered_group.add(covered,1,'REPLACE')
mask=body.modifiers.new('04 Ocultar corpo coberto pela calca','MASK')
mask.vertex_group=covered_group.name
mask.invert_vertex_group=True
bpy.context.view_layer.update()

def rings(name,levels,mat,n=40,thickness=.003,sub=1,fixed_bone=None):
    verts=[]
    for z,cx,cy,rx,ry in levels:
        for j in range(n):
            a=2*math.pi*j/n
            verts.append((cx+rx*math.cos(a),cy+ry*math.sin(a),z))
    faces=[]
    for k in range(len(levels)-1):
        for j in range(n):
            a=k*n+j; b=k*n+(j+1)%n
            faces.append((a,b,b+n,a+n))
    return mesh_object(name,verts,faces,mat,thickness=thickness,sub=sub,fixed_bone=fixed_bone)

# Waistband connects the wrapped shirt to the waist; sleeve tails remain separate.
rings('03_CAMISA | tecido enrolado',[
    (.913,0,-.04,.174,.128),(.923,0,-.04,.175,.130),
    (.946,0,-.04,.158,.119),(.973,0,-.04,.143,.112),
    (.978,0,-.04,.141,.110)],wine,n=64)

# Back panel, open at the front: a tied shirt, not a closed skirt.
verts=[]; faces=[]; rows=14; columns=48
for r in range(rows):
    t=r/(rows-1)
    for c in range(columns):
        a=-.12+(math.pi+.24)*c/(columns-1)
        edge=abs(2*c/(columns-1)-1)
        z=.941-t*(.27+.045*math.sin(3*a)-.04*edge)
        rx=.171+.076*math.sin(t*math.pi/2)
        ry=.134+.046*math.sin(t*math.pi/2)
        fold=.008*math.sin(9*a+2*t)*math.sin(math.pi*t/2)
        verts.append(((rx+fold)*math.cos(a),-.035+(ry+fold)*math.sin(a),z))
for r in range(rows-1):
    for c in range(columns-1):
        i=r*columns+c
        faces.append((i,i+1,i+1+columns,i+columns))
mesh_object('03_CAMISA | costas e abas',verts,faces,wine,thickness=.004)

def tube(name,centers,radii,mat,n=12,sub=1,fixed_bone=None):
    verts=[]
    for i,center in enumerate(centers):
        p=Vector(center)
        tangent=Vector(centers[min(i+1,len(centers)-1)])-Vector(centers[max(i-1,0)])
        tangent.normalize()
        u=tangent.cross(Vector((0,1,0)))
        if u.length<.01:
            u=tangent.cross(Vector((1,0,0)))
        u.normalize(); v=tangent.cross(u).normalized()
        radius=radii[i] if isinstance(radii,list) else radii
        rx,ry=radius if isinstance(radius,tuple) else (radius,radius)
        for j in range(n):
            a=j*2*math.pi/n
            verts.append(p+u*(rx*math.cos(a))+v*(ry*math.sin(a)))
    faces=[]
    for k in range(len(centers)-1):
        for j in range(n):
            a=k*n+j; b=k*n+(j+1)%n
            faces.append((a,b,b+n,a+n))
    faces.extend([tuple(reversed(range(n))),tuple((len(centers)-1)*n+j for j in range(n))])
    return mesh_object(name,verts,faces,mat,thickness=0,sub=sub,fixed_bone=fixed_bone)

tube('03_CAMISA | no frontal',[(-.015,-.178,.95),(.008,-.190,.946),(.029,-.193,.936),(.048,-.179,.923)],
     [(.023,.018),(.028,.025),(.028,.025),(.023,.018)],wine,n=16)
for side in (-1,1):
    centers=[]; sizes=[]
    for i in range(12):
        t=i/11
        centers.append((.018+side*(.025+.060*t),-.180-.026*math.sin(math.pi*t),.94-(.23 if side<0 else .18)*t))
        sizes.append((.025+.012*t,.007+.002*math.sin(math.pi*t)))
    tube('03_CAMISA | manga pendente '+str(side),centers,sizes,wine,n=12)

# Boots are low-detail volumes with a rounded toe, sole and lace bridge.
for side in (-1,1):
    suffix='L' if side==1 else 'R'
    cx=side*.166
    boot=rings('04_BOTA.'+suffix+' | cano e peito',[
        (.018,cx,-.081,.052,.126),(.028,cx,-.081,.052,.125),
        (.050,cx,-.080,.052,.119),(.069,cx,-.068,.049,.103),
        (.090,cx,-.041,.045,.071),(.119,cx,-.026,.043,.051),
        (.164,cx,-.024,.044,.050),(.192,cx,-.023,.046,.052),
        (.198,cx,-.023,.046,.052)],leather,n=40,thickness=.005)
    sole=rings('04_BOTA.'+suffix+' | sola',[
        (.004,cx,-.081,.055,.130),(.008,cx,-.081,.056,.131),
        (.022,cx,-.081,.056,.131),(.026,cx,-.081,.054,.129)],rubber,n=40,thickness=.006,fixed_bone='DEF-foot.'+suffix)
    for row in range(5):
        z=.080+row*.021
        y=-.109+row*.0069
        for diagonal in (-1,1):
            tube('04_CADARCO.'+suffix+'.'+str(row)+'.'+str(diagonal),
                 [(cx-.025,y,z+diagonal*.006),(cx,y-.006,z),(cx+.025,y,z-diagonal*.006)],
                 .0026,seam_mat,n=6,sub=1)

# Coarse topology checks catch disconnected weighting/data, not artistic approval.
assert len(body.data.vertices)==19158
assert {k.name:k.value for k in body.data.shape_keys.key_blocks}==body_keys
assert rig.animation_data.action.name==action_name
assert all(any(m.type=='ARMATURE' and m.object==rig for m in o.modifiers) for o in garments)
assert all(len(v.groups)>0 for o in garments for v in o.data.vertices)
assert all(math.isfinite(c) for o in garments for v in o.data.vertices for c in v.co)

scene.render.engine='BLENDER_WORKBENCH'
scene.display.shading.light='STUDIO'
scene.display.shading.studio_light='paint.sl'
scene.display.shading.color_type='MATERIAL'
scene.display.shading.show_shadows=True
scene.display.shading.show_cavity=True
scene.display.shading.cavity_type='BOTH'
scene.display.shading.curvature_ridge_factor=1.15
scene.display.shading.curvature_valley_factor=1.0
scene.display.shading.show_specular_highlight=False
scene.display.shading.background_type='WORLD'
scene.world.color=(.035,.045,.060)
# Neutral mannequin remains neutral; not a new identity/skin treatment.
if not body.data.materials:
    neutral=material('Manequim | identidade ainda pendente',(.30,.36,.42))
    body.data.materials.append(neutral)
    base.materials.append(neutral)
for mat in body.data.materials:
    mat.diffuse_color=(.30,.36,.42,1)
scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
camera=scene.camera

def render_view(name,position,target,scale,w=880,h=1000):
    camera.location=position
    camera.rotation_euler=(Vector(target)-camera.location).to_track_quat('-Z','Y').to_euler()
    camera.data.ortho_scale=scale
    scene.render.resolution_x=w; scene.render.resolution_y=h
    scene.render.filepath=str(OUT/name)
    bpy.ops.render.render(write_still=True)

render_view('figurino_frente.png',(0,-6,1.05),(0,0,.82),1.83)
render_view('figurino_tres_quartos.png',(2.5,-6,1.9),(0,0,.82),1.9)
render_view('figurino_costas.png',(-2,6,1.8),(0,0,.82),1.9)
scene.frame_set(30)
render_view('figurino_flexao.png',(2.5,-6,1.9),(0,0,.82),1.9)
scene.frame_set(1)

# Native before/after board: hide/unhide only the new garment collection.
# Two views in one render via temporary frozen meshes, not duplicated saved rigs.
snaps=[]
body.hide_render=True
for obj in garments:
    obj.hide_render=True
for offset,clothed in [(-.61,False),(.61,True)]:
    surface=bpy.data.meshes.new_from_object(body.evaluated_get(bpy.context.evaluated_depsgraph_get())) if clothed else base.copy()
    snapshot=bpy.data.objects.new('Comparacao temporaria',surface)
    scene.collection.objects.link(snapshot)
    snapshot.location.x=offset
    snaps.append(snapshot)
    if clothed:
        for obj in garments:
            data=bpy.data.meshes.new_from_object(obj.evaluated_get(bpy.context.evaluated_depsgraph_get()))
            snap=bpy.data.objects.new('Comparacao temporaria',data)
            scene.collection.objects.link(snap)
            snap.location.x=offset
            snaps.append(snap)
render_view('comparacao.png',(0,-7,1.0),(0,0,.82),2.50,w=1200,h=900)
for obj in snaps:
    data=obj.data
    bpy.data.objects.remove(obj,do_unlink=True)
    bpy.data.meshes.remove(data)
body.hide_render=False
for obj in garments:
    obj.hide_render=False
bpy.data.meshes.remove(base)

camera.location=(2.5,-6,1.9)
camera.rotation_euler=(Vector((0,0,.82))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.ortho_scale=1.9
scene.render.resolution_x=880
scene.render.resolution_y=1000
scene.render.filepath=str(OUT/'previa_editor.png')
bpy.ops.object.select_all(action='DESELECT')
shirt.select_set(True)
bpy.context.view_layer.objects.active=shirt
for screen in bpy.data.screens:
    for area in screen.areas:
        if area.type=='VIEW_3D':
            space=area.spaces.active
            space.region_3d.view_distance=2.8
            space.region_3d.view_location=Vector((0,0,.82))
            space.region_3d.view_rotation=camera.rotation_euler.to_quaternion()
            space.shading.type='SOLID'
            space.shading.color_type='MATERIAL'
            space.shading.light='STUDIO'
            space.shading.studio_light='paint.sl'
            space.shading.show_shadows=True
            space.shading.show_cavity=True
            space.overlay.show_overlays=False
scene['LEIA']='Figurino 04: formas iniciais. Corpo 03 mantido. Espaco: flexao. Alt+Z nao e necessario; overlays ocultos para avaliar silhueta. Rosto/cabelo/proteses pendentes.'
scene['FONTE_03_SHA256']=source_hash
scene['FIGURINO_ETAPA']='Volumes e caimento inicial; sem simulacao de tecido ou certificacao de poses extremas.'
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==source_hash
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(DEST),compress=True)
print('FIGURINO_OK',json.dumps({'blender':bpy.app.version_string,'pecas':len(garments),'vertices_roupa':sum(len(o.data.vertices) for o in garments),'source_sha256':source_hash,'rig_bones':len(rig.data.bones),'action':action_name}))
