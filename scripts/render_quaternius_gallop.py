import bpy
import json
import math
import os
import sys
from mathutils import Vector

def args_after_double_dash():
    if "--" not in sys.argv:
        raise SystemExit("usage: blender -b --python render_quaternius_gallop.py -- <horse.glb> <output-dir>")
    return sys.argv[sys.argv.index("--") + 1:]

def look_at(obj, target):
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()

def evaluated_vertices(scene):
    depsgraph = bpy.context.evaluated_depsgraph_get()
    points = []
    for obj in scene.objects:
        if obj.type != "MESH" or obj.hide_render:
            continue
        evaluated = obj.evaluated_get(depsgraph)
        mesh = evaluated.to_mesh()
        try:
            points.extend(evaluated.matrix_world @ vertex.co for vertex in mesh.vertices)
        finally:
            evaluated.to_mesh_clear()
    return points

def pick_gallop_action():
    exact = bpy.data.actions.get("Gallop")
    if exact is not None:
        return exact
    candidates = [
        action for action in bpy.data.actions
        if "gallop" in action.name.lower() and "jump" not in action.name.lower()
    ]
    if not candidates:
        raise RuntimeError("Gallop action was not found. Actions: " + ", ".join(sorted(a.name for a in bpy.data.actions)))
    return sorted(candidates, key=lambda a: (len(a.name), a.name))[0]

def set_render_engine(scene):
    for engine in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
        try:
            scene.render.engine = engine
            return engine
        except Exception:
            pass
    scene.render.engine = "BLENDER_WORKBENCH"
    return "BLENDER_WORKBENCH"

def main():
    argv = args_after_double_dash()
    if len(argv) != 2:
        raise SystemExit("expected GLB path and output directory")
    glb_path, output_dir = argv
    os.makedirs(output_dir, exist_ok=True)

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=glb_path)

    scene = bpy.context.scene
    engine = set_render_engine(scene)
    scene.render.resolution_x = 512
    scene.render.resolution_y = 512
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.fps = 24

    armatures = [obj for obj in scene.objects if obj.type == "ARMATURE"]
    if not armatures:
        raise RuntimeError("No armature found in horse GLB")

    action = pick_gallop_action()
    for armature in armatures:
        armature.animation_data_create()
        armature.animation_data.action = action

    start, end = action.frame_range
    if end <= start:
        raise RuntimeError(f"Invalid Gallop frame range: {start}..{end}")

    # 12 gameplay frames plus the authored loop endpoint for seam analysis.
    preview_frames = [start + (end - start) * i / 12.0 for i in range(12)]
    analysis_frames = preview_frames + [end]

    mins = Vector((math.inf, math.inf, math.inf))
    maxs = Vector((-math.inf, -math.inf, -math.inf))
    for frame in analysis_frames:
        scene.frame_set(int(round(frame)))
        points = evaluated_vertices(scene)
        if not points:
            raise RuntimeError("No renderable mesh vertices found")
        for point in points:
            mins.x = min(mins.x, point.x)
            mins.y = min(mins.y, point.y)
            mins.z = min(mins.z, point.z)
            maxs.x = max(maxs.x, point.x)
            maxs.y = max(maxs.y, point.y)
            maxs.z = max(maxs.z, point.z)

    center = (mins + maxs) * 0.5
    extent = maxs - mins
    span = max(extent.x, extent.y, extent.z, 0.001)

    camera_data = bpy.data.cameras.new("SideCamera")
    camera = bpy.data.objects.new("SideCamera", camera_data)
    scene.collection.objects.link(camera)
    # Quaternius horse uses Y-up in the imported Blender scene and travels along Z.
    # Camera from +X gives the required racing side profile.
    camera.location = (maxs.x + span * 3.0, center.y, center.z)
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = max(extent.y, extent.z) * 1.22
    look_at(camera, center)
    scene.camera = camera

    key = bpy.data.lights.new("Key", type="AREA")
    key.energy = 900
    key.size = span * 3.0
    key_obj = bpy.data.objects.new("Key", key)
    scene.collection.objects.link(key_obj)
    key_obj.location = (center.x + span * 2.0, center.y + span * 2.0, center.z + span * 1.5)
    look_at(key_obj, center)

    fill = bpy.data.lights.new("Fill", type="AREA")
    fill.energy = 500
    fill.size = span * 2.5
    fill_obj = bpy.data.objects.new("Fill", fill)
    scene.collection.objects.link(fill_obj)
    fill_obj.location = (center.x - span * 1.5, center.y + span, center.z - span)
    look_at(fill_obj, center)

    if scene.world is None:
        scene.world = bpy.data.worlds.new("World")
    scene.world.color = (0.55, 0.55, 0.55)

    rendered = []
    for index, frame in enumerate(preview_frames):
        scene.frame_set(int(round(frame)))
        path = os.path.join(output_dir, f"gallop_{index:02d}.png")
        scene.render.filepath = path
        bpy.ops.render.render(write_still=True)
        rendered.append({"index": index, "source_frame": float(frame), "file": os.path.basename(path)})

    scene.frame_set(int(round(end)))
    loop_end_path = os.path.join(output_dir, "gallop_loop_end.png")
    scene.render.filepath = loop_end_path
    bpy.ops.render.render(write_still=True)

    metadata = {
        "render_engine": engine,
        "action": action.name,
        "action_frame_start": float(start),
        "action_frame_end": float(end),
        "fps": scene.render.fps,
        "preview_frame_count": len(rendered),
        "available_actions": sorted(action.name for action in bpy.data.actions),
        "armature_count": len(armatures),
        "bounds": {
            "min": [mins.x, mins.y, mins.z],
            "max": [maxs.x, maxs.y, maxs.z],
        },
        "frames": rendered,
        "loop_end_file": os.path.basename(loop_end_path),
    }
    with open(os.path.join(output_dir, "render-metadata.json"), "w", encoding="utf-8") as handle:
        json.dump(metadata, handle, indent=2, ensure_ascii=False)

    print("HORSE_RENDER_METADATA=" + json.dumps(metadata, ensure_ascii=False))

if __name__ == "__main__":
    main()
