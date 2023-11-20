#! blender --background --python .\blend_export.py

# The MIT License (MIT)

# Copyright (c) 2016 Godot Engine

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

"""
Automates the regeneration of various export formats from golden blend files.

Note: In environments that do not support shebang execution, Blender may be
invoked from the command line with the arguments from the first line of this
script (see run_tests.bat).
"""

import bpy
import posixpath
import shutil
import os
import sys

argv = sys.argv
argv = argv[argv.index("--") + 1:]  # get all args after "--"
path = argv[0]

bpy.ops.preferences.addon_install(filepath=os.path.join(path, "VRM_Addon_for_Blender-2_15_22.zip"))
bpy.ops.preferences.addon_enable(module="VRM_Addon_for_Blender-2_15_22")
export_path = os.path.join(path, 'blockmesh')

directories = ["blue_tin_fox/characters"]
shutil.rmtree(export_path, ignore_errors=True)
posixpath.os.mkdir(export_path, mode=0o777)
for directory in directories:
    for root, subdirs, files in os.walk(os.path.join(path, directory)):   
        for subdir in subdirs:
            print('\t- subdirectory ' + subdir) 
        for filename in files:
            if not filename.endswith(".blend"):
                continue
            bpy.ops.wm.open_mainfile(filepath=os.path.join(root, filename))
            basename = filename.rsplit(".blend", 1)[0]
            basename = "v_sekai_" + basename
            bpy.ops.export_scene.vrm(
                filepath=os.path.join(export_path, basename + ".vrm")
            )

directories = ["blue_tin_fox"]
for directory in directories:
    for root, subdirs, files in os.walk(os.path.join(path, directory)):   
        for subdir in subdirs:
            print('\t- subdirectory ' + subdir) 
        for filename in files:
            if not filename.endswith(".blend"):
                continue
            bpy.ops.wm.open_mainfile(filepath=os.path.join(root, filename))
            basename = filename.rsplit(".blend", 1)[0]
            basename = basename
            bpy.ops.export_scene.gltf(
                filepath=os.path.join(export_path, basename + ".glb"),
                export_format='GLB',
                export_texture_dir='textures',
                export_colors=False,
                export_all_influences=True,
                export_extras=True,
                export_cameras=True,
                export_lights=True,
            )
