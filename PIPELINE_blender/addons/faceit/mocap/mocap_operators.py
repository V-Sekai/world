import csv
import json
import os
from bpy_extras.io_utils import ImportHelper
from .mocap_importers import A2FMocapImporter, FaceCapImporter, EpicMocapImporter
from .mocap_base import MocapImporterBase
from ..core.shape_key_utils import get_all_shape_key_actions, get_enum_shape_key_actions, has_shape_keys, get_shape_key_names_from_objects, set_rest_position_shape_keys
from ..core import retarget_list_utils as rutils
from ..core import faceit_utils as futils
from ..core import faceit_data as fdata
from ..core.retarget_list_base import FaceRegionsBaseProperties
import bpy
from bpy.props import BoolProperty, EnumProperty, IntProperty, FloatProperty
from mathutils import Matrix
from .mocap_utils import add_zero_keyframe, remove_frame_range
from .osc_operators import get_head_base_transform


class FACEIT_OT_ResetExpressionValues(bpy.types.Operator):
    '''Reset all expression values to 0'''
    bl_idname = 'faceit.reset_expression_values'
    bl_label = 'Reset Face Expression'
    bl_options = {'REGISTER', 'UNDO', 'INTERNAL'}

    def execute(self, context):
        scene = context.scene
        all_target_shapes = rutils.get_all_set_target_shapes(scene.faceit_arkit_retarget_shapes)
        all_target_shapes.extend(rutils.get_all_set_target_shapes(scene.faceit_a2f_retarget_shapes))
        set_rest_position_shape_keys(expressions_filter=all_target_shapes)
        return {'FINISHED'}


class FACEIT_OT_ResetHeadPose(bpy.types.Operator):
    '''Reset the head bone / object'''
    bl_idname = "faceit.reset_head_pose"
    bl_label = "Reset Head Pose"

    def execute(self, context):
        scene = context.scene
        auto_kf = scene.tool_settings.use_keyframe_insert_auto
        scene.tool_settings.use_keyframe_insert_auto = False
        scene = context.scene
        head_obj = scene.faceit_head_target_object
        if head_obj:
            if head_obj.type == 'ARMATURE':
                pb = head_obj.pose.bones.get(scene.faceit_head_sub_target)
                # Reset pose
                if pb:
                    pb.matrix_basis = Matrix()
            else:
                head_base_rotation, head_base_location = get_head_base_transform()
                if head_base_rotation is not None:
                    if head_obj.rotation_mode == 'QUATERNION':
                        head_obj.rotation_quaternion = head_base_rotation
                    elif head_obj.rotation_mode == 'AXIS_ANGLE':
                        head_obj.rotation_axis_angle = head_base_rotation
                    else:
                        head_obj.rotation_euler = head_base_rotation
                if head_base_location is not None:
                    head_obj.location = head_base_location
                # print(scene.faceit_head_base_location)
        scene.tool_settings.use_keyframe_insert_auto = auto_kf
        return {'FINISHED'}


class FACEIT_OT_ResetEyePose(bpy.types.Operator):
    '''Reset the eye bones'''
    bl_idname = "faceit.reset_eye_pose"
    bl_label = "Reset Eye Pose"

    def execute(self, context):
        scene = context.scene
        auto_kf = scene.tool_settings.use_keyframe_insert_auto
        scene.tool_settings.use_keyframe_insert_auto = False
        scene = context.scene
        eye_rig = scene.faceit_eye_target_rig
        if eye_rig:
            for name in (scene.faceit_eye_L_sub_target, scene.faceit_eye_R_sub_target):
                pb = eye_rig.pose.bones.get(name)
                # Reset pose
                if pb:
                    pb.matrix_basis = Matrix()
        scene.tool_settings.use_keyframe_insert_auto = auto_kf
        return {'FINISHED'}


class FACEIT_OT_ImportFaceCapMocap(MocapImporterBase, bpy.types.Operator):
    '''Import a TXT file generated by the Face Cap app for iOS (Bannaflak)'''
    bl_idname = 'faceit.import_face_cap_mocap'
    bl_label = 'Import Face Cap TXT'

    def __init__(self):
        super().__init__()
        self.engine_name = "FACECAP"
        self.target_shapes_prop_name = "faceit_arkit_retarget_shapes"
        self.engine_settings = None
        self.record_frame_rate = 1000

    def _get_mocap_importer(self):
        return FaceCapImporter()


class FACEIT_OT_ImportEpicMocap(MocapImporterBase, bpy.types.Operator):
    '''Import a CSV file generated by the Live Link Face app for iOS (Epic Games)'''
    bl_idname = 'faceit.import_epic_mocap'
    bl_label = 'Import Live Link Face CSV'

    def __init__(self):
        super().__init__()
        self.engine_name = "EPIC"
        self.target_shapes_prop_name = "faceit_arkit_retarget_shapes"
        self.engine_settings = None
        self.can_import_head_location = False
        self.can_import_head_rotation = True

    def _get_mocap_importer(self):
        return EpicMocapImporter()


class FACEIT_OT_ImportA2FMocap(MocapImporterBase, bpy.types.Operator):
    '''Import a JSON file generated by the Audio2Face app for PCs with RTX cards (Nvidia)'''
    bl_idname = 'faceit.import_a2f_mocap'
    bl_label = 'Import Nvidia Audio2Face JSON'

    a2f_solver: EnumProperty(
        name='Solver',
        items=(
            ('ARKIT', 'ARKit', 'Use the 52 ARKit target shapes.'),
            ('A2F', 'A2F', 'Use the original 46 A2F target shapes.')
        ),
        default='A2F',
        options={'HIDDEN', 'SKIP_SAVE'}
    )

    def __init__(self):
        super().__init__()
        self.engine_name = "A2F"
        self.target_shapes_prop_name = "faceit_a2f_retarget_shapes"
        self.engine_settings = None
        self.record_frame_rate = 60
        self.can_bake_control_rig = False
        self.can_import_head_location = False
        self.can_import_head_location = False
        self.animate_head_rotation = False
        self.animate_head_rotation = False
        self.found_solver = False

    def _get_mocap_importer(self):
        return A2FMocapImporter()


class FACEIT_OT_AddZeroKeyframe(FaceRegionsBaseProperties, bpy.types.Operator):
    '''Add a 0.0 keyframe for all target shapes in the specified list(s)'''
    bl_idname = 'faceit.add_zero_keyframe'
    bl_label = 'Add Zero Keyframe'
    bl_options = {'UNDO'}

    expression_sets: EnumProperty(
        name='Expression Sets',
        items=(
            ('ALL', 'All', 'Search for all available expressions'),
            ('ARKIT', 'ARKit', 'The 52 ARKit Expressions that are used in all iOS motion capture apps'),
            ('A2F', 'Audio2Face', 'The 46 expressions that are used in Nvidias Audio2Face app by default.'),
        ),
        default='ALL'
    )

    use_region_filter: BoolProperty(
        name='Filter Face Regions',
        default=True,
        description='Filter face regions that should be animated.'
        # options={'SKIP_SAVE', }
    )

    existing_action: EnumProperty(
        name='Action',
        items=get_enum_shape_key_actions,
        options={'SKIP_SAVE', }
    )

    data_paths: EnumProperty(
        name='Fcurves',
        items=(
            ('EXISTING', 'Existing', 'Add a zero keyframe to all fcurves that are currently found in the specified action'),
            ('ALL', 'All', 'Add a Keyframe for all target shapes in the specified list(s). Create a new fcurve if it doesn\'t exist')
        ),
        default='EXISTING',
        options={'SKIP_SAVE', }
    )

    frame: IntProperty(
        name='Frame',
        default=0,
        options={'SKIP_SAVE', }
    )

    def invoke(self, context, event):

        # Check if the main object has a Shape Key Action applied
        main_obj = futils.get_main_faceit_object()
        sk_action = None
        if has_shape_keys(main_obj):
            if main_obj.data.shape_keys.animation_data:
                sk_action = main_obj.data.shape_keys.animation_data.action

        if sk_action:
            self.existing_action = sk_action.name

        self.frame = context.scene.frame_current

        # face_regions_prop = context.scene.faceit_face_regions
        # props = [x for x in face_regions_prop.keys()]
        # for p in props:
        #     face_regions_prop.property_unset(p)

        wm = context.window_manager
        return wm.invoke_props_dialog(self)

    def draw(self, context):
        layout = self.layout

        row = layout.row(align=True)
        row.label(text='Affect Expressions')
        row = layout.row()
        row.prop(self, 'expression_sets', expand=True)

        row = layout.row()
        row.label(text='Choose a Shape Key Action:')
        row = layout.row()
        row.prop(self, 'existing_action', text='', icon='ACTION')

        row = layout.row()
        row.prop(self, 'frame', icon='KEYTYPE_KEYFRAME_VEC')

        row = layout.row(align=True)
        row.label(text='Region Filter')
        row = layout.row(align=True)
        row.prop(self, 'use_region_filter', icon='USER')

        if self.use_region_filter:

            col = layout.column(align=True)

            row = col.row(align=True)

            icon_value = 'CHECKBOX_HLT' if self.brows else 'CHECKBOX_DEHLT'
            row.prop(self, 'brows', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.eyes else 'CHECKBOX_DEHLT'
            row.prop(self, 'eyes', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.eyelids else 'CHECKBOX_DEHLT'
            row.prop(self, 'eyelids', icon=icon_value)

            row = col.row(align=True)
            icon_value = 'CHECKBOX_HLT' if self.cheeks else 'CHECKBOX_DEHLT'
            row.prop(self, 'cheeks', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.nose else 'CHECKBOX_DEHLT'
            row.prop(self, 'nose', icon=icon_value)

            row = col.row(align=True)
            icon_value = 'CHECKBOX_HLT' if self.mouth else 'CHECKBOX_DEHLT'
            row.prop(self, 'mouth', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.tongue else 'CHECKBOX_DEHLT'
            row.prop(self, 'tongue', icon=icon_value)

    @classmethod
    def poll(cls, context):
        return get_all_shape_key_actions() and futils.get_faceit_objects_list()

    def execute(self, context):

        scene = context.scene

        shape_names = []
        if self.expression_sets in ('ALL', 'ARKIT'):
            retarget_list = scene.faceit_arkit_retarget_shapes
            for region, active in self.get_active_regions().items():
                if active:
                    shape_names.extend(rutils.get_all_set_target_shapes(retarget_list=retarget_list, region=region))
        if self.expression_sets in ('ALL', 'A2F'):
            retarget_list = scene.faceit_a2f_retarget_shapes
            for region, active in self.get_active_regions().items():
                if active:
                    shape_names.extend(rutils.get_all_set_target_shapes(retarget_list=retarget_list, region=region))

        action = bpy.data.actions.get(self.existing_action)
        if not action:
            self.report({'WARNING'}, f'Couldn\'t find the action {self.existing_action}')
            return {'CANCELLED'}
        fcurves_to_operate_on = [fc for fc in action.fcurves if any(
            shape_name in fc.data_path for shape_name in shape_names)]
        add_zero_keyframe(fcurves=fcurves_to_operate_on, frame=self.frame)
        scene.frame_set(scene.frame_current)

        return {'FINISHED'}


def update_frame_start(self, context):
    if self.frame_start >= self.frame_end:
        self.frame_end = self.frame_start + 1


def update_frame_end(self, context):
    if self.frame_end <= self.frame_start:
        self.frame_start = self.frame_end - 1


class FACEIT_OT_RemoveFrameRange(FaceRegionsBaseProperties, bpy.types.Operator):
    '''Remove a range of frames from the specified Shape Key action'''
    bl_idname = 'faceit.remove_frame_range'
    bl_label = 'Remove Keyframes Filter'
    bl_options = {'UNDO'}

    expression_sets: EnumProperty(
        name='Expression Sets',
        items=(
            ('ALL', 'All', 'Search for all available expressions'),
            ('ARKIT', 'ARKit', 'The 52 ARKit Expressions that are used in all iOS motion capture apps'),
            ('A2F', 'Audio2Face', 'The 46 expressions that are used in Nvidias Audio2Face app by default.'),
        ),
        default='ALL'
    )
    use_region_filter: BoolProperty(
        name='Filter Face Regions',
        default=True,
        description='Filter face regions that should be animated.'
        # options={'SKIP_SAVE', }
    )

    existing_action: EnumProperty(
        name='Action',
        items=get_enum_shape_key_actions,
        options={'SKIP_SAVE', }
    )

    frame_range: EnumProperty(
        name='Effect Frames',
        items=(
            ('CUSTOM', 'Custom', 'Specify a frame range that should be affected'),
            ('ALL', 'All', 'Affect all keys in the specified action'),
        )
    )
    frame_start: IntProperty(
        name='Frame Start',
        default=0,
        soft_min=0,
        soft_max=50000,
        update=update_frame_start
        # options={'SKIP_SAVE', }
    )
    frame_end: IntProperty(
        name='Frame End',
        default=10,
        soft_min=0,
        soft_max=50000,
        update=update_frame_end
        # options={'SKIP_SAVE', }
    )

    def invoke(self, context, event):

        # Check if the main object has a Shape Key Action applied
        main_obj = futils.get_main_faceit_object()
        sk_action = None
        if has_shape_keys(main_obj):
            if main_obj.data.shape_keys.animation_data:
                sk_action = main_obj.data.shape_keys.animation_data.action

        if sk_action:
            self.existing_action = sk_action.name

        wm = context.window_manager
        return wm.invoke_props_dialog(self)

    def draw(self, context):
        layout = self.layout

        row = layout.row(align=True)
        row.label(text='Affect Expressions')
        row = layout.row()
        row.prop(self, 'expression_sets', expand=True)

        row = layout.row()
        row.label(text='Choose a Shape Key Action:')
        row = layout.row()
        row.prop(self, 'existing_action', text='', icon='ACTION')

        row = layout.row()
        row.label(text='Frame Range:')
        row = layout.row()
        row.prop(self, 'frame_range', expand=True)

        if self.frame_range == 'CUSTOM':
            row = layout.row(align=True)
            row.prop(self, 'frame_start', icon='KEYTYPE_KEYFRAME_VEC')
            row.prop(self, 'frame_end', icon='KEYTYPE_KEYFRAME_VEC')

        row = layout.row(align=True)
        row.label(text='Region Filter')
        row = layout.row(align=True)
        row.prop(self, 'use_region_filter', icon='USER')

        if self.use_region_filter:

            col = layout.column(align=True)

            row = col.row(align=True)

            icon_value = 'CHECKBOX_HLT' if self.brows else 'CHECKBOX_DEHLT'
            row.prop(self, 'brows', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.eyes else 'CHECKBOX_DEHLT'
            row.prop(self, 'eyes', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.eyelids else 'CHECKBOX_DEHLT'
            row.prop(self, 'eyelids', icon=icon_value)

            row = col.row(align=True)
            icon_value = 'CHECKBOX_HLT' if self.cheeks else 'CHECKBOX_DEHLT'
            row.prop(self, 'cheeks', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.nose else 'CHECKBOX_DEHLT'
            row.prop(self, 'nose', icon=icon_value)

            row = col.row(align=True)
            icon_value = 'CHECKBOX_HLT' if self.mouth else 'CHECKBOX_DEHLT'
            row.prop(self, 'mouth', icon=icon_value)

            icon_value = 'CHECKBOX_HLT' if self.tongue else 'CHECKBOX_DEHLT'
            row.prop(self, 'tongue', icon=icon_value)

    @classmethod
    def poll(cls, context):
        return get_all_shape_key_actions() and futils.get_faceit_objects_list()

    def execute(self, context):

        scene = context.scene

        shape_names = []
        if self.expression_sets in ('ALL', 'ARKIT'):
            retarget_list = scene.faceit_arkit_retarget_shapes
            for region, active in self.get_active_regions().items():
                if active:
                    shape_names.extend(rutils.get_all_set_target_shapes(retarget_list=retarget_list, region=region))
        if self.expression_sets in ('ALL', 'A2F'):
            retarget_list = scene.faceit_a2f_retarget_shapes
            for region, active in self.get_active_regions().items():
                if active:
                    shape_names.extend(rutils.get_all_set_target_shapes(retarget_list=retarget_list, region=region))

        action = bpy.data.actions.get(self.existing_action)
        if not action:
            self.report({'WARNING'}, f'Couldn\'t find the action {self.existing_action}')
            return {'CANCELLED'}
        fcurves_to_operate_on = [fc for fc in action.fcurves if any(
            shape_name in fc.data_path for shape_name in shape_names)]
        if self.frame_range == 'CUSTOM':
            remove_frame_range(action=action, fcurves=fcurves_to_operate_on,
                               frame_start=self.frame_start, frame_end=self.frame_end)
        else:
            # Just remove the entire fcurves
            for fc in fcurves_to_operate_on:
                action.fcurves.remove(fc)

        set_rest_position_shape_keys(expressions_filter=shape_names)

        scene.frame_set(scene.frame_current)

        return {'FINISHED'}


class FACEIT_OT_MotionFileImportBase(ImportHelper):

    filename_ext = ".txt"
    filter_glob: bpy.props.StringProperty(
        default="*.txt",
        options={'HIDDEN'},
        maxlen=255,  # Max internal buffer length, longer would be clamped.
    )
    auto_load_audio: bpy.props.BoolProperty(
        name="Auto Load Audio",
        description="Try to load the audio file automatically.",
        default=True,
    )
    engine_name = 'FACECAP'
    engine_settings = None

    def draw(self, context):
        layout = self.layout
        layout.label(text="Import Options")
        layout.prop(self, "auto_load_audio", icon='SOUND')

    def invoke(self, context, event):
        self.engine_settings = fdata.get_engine_settings(self.engine_name)
        if self.engine_settings.filename:
            self.filepath = self.engine_settings.filename
        audio_file = self.engine_settings.audio_filename
        if audio_file:
            self.auto_load_audio = False
        else:
            self.auto_load_audio = True
        wm = context.window_manager
        wm.fileselect_add(self)
        return {'RUNNING_MODAL'}


class FACEIT_OT_LoadFaceCapTXTFile(bpy.types.Operator, FACEIT_OT_MotionFileImportBase):
    '''Choose a catured file to import as keyframes'''
    bl_idname = 'faceit.load_face_cap_txt_file'
    bl_label = 'Load TXT File'
    bl_options = {'UNDO', 'INTERNAL'}

    # Default Properties

    def execute(self, context):
        with open(self.filepath) as csvfile:
            reader = csv.reader(csvfile)
            first_row = next(reader)
            if first_row[0] != "info":
                self.report({'ERROR'}, "The specified file is not valid.")
                return {'CANCELLED'}
        # Try to find the audio in the same folder.
        if self.auto_load_audio:
            directory, txt_filename = os.path.split(self.filepath)
            base_name, _ = os.path.splitext(txt_filename)
            audio_path = os.path.join(directory, f"{base_name}.wav")
            # Check if the .wav file exists
            if os.path.isfile(audio_path):
                self.engine_settings.audio_filename = audio_path
            else:
                self.report({'WARNING'}, "Couldn't find a valid audio file.")
        self.engine_settings.filename = self.filepath
        # Update UI
        for region in context.area.regions:
            if region.type == 'UI':
                region.tag_redraw()
        return {'FINISHED'}


class FACEIT_OT_LoadLiveLinkFaceCSVFile(bpy.types.Operator, FACEIT_OT_MotionFileImportBase):
    '''Choose a catured file to import as keyframes'''
    bl_idname = 'faceit.load_live_link_face_csv_file'
    bl_label = 'Load CSV File'
    bl_options = {'UNDO', 'INTERNAL'}

    filename_ext = ".csv"
    filter_glob: bpy.props.StringProperty(
        default="*.csv",
        options={'HIDDEN'},
        maxlen=255,  # Max internal buffer length, longer would be clamped.
    )
    engine_name = 'EPIC'
    engine_settings = None

    def execute(self, context):
        with open(self.filepath) as csvfile:
            reader = csv.reader(csvfile)
            first_row = next(reader)
            if first_row[1].lower() != "BlendShapeCount".lower():
                self.report({'ERROR'}, "The specified file is not valid.")
                return {'CANCELLED'}
        if self.auto_load_audio:
            directory, csv_filename = os.path.split(self.filepath)
            anim_name, _ = os.path.splitext(csv_filename)
            if anim_name.endswith('_raw'):
                base_name = anim_name.strip("_raw")
            elif anim_name.endswith('_cal'):
                base_name = anim_name.strip("_cal")
            else:
                base_name = anim_name
            audio_path = os.path.join(directory, f"{base_name}.mov")
            # Check if the .wav file exists
            if os.path.isfile(audio_path):
                self.engine_settings.audio_filename = audio_path
            else:
                self.report({'WARNING'}, "Couldn't find a valid audio file.")

        self.engine_settings.filename = self.filepath
        # Update UI
        for region in context.area.regions:
            if region.type == 'UI':
                region.tag_redraw()
        return {'FINISHED'}


class FACEIT_OT_LoadAudio2FaceJSONFile(bpy.types.Operator, FACEIT_OT_MotionFileImportBase):
    '''Choose a catured file to import as keyframes'''
    bl_idname = 'faceit.load_audio2face_json_file'
    bl_label = 'Load JSON File'
    bl_options = {'UNDO', 'INTERNAL'}

    filename_ext = ".json"
    filter_glob: bpy.props.StringProperty(
        default="*.json",
        options={'HIDDEN'},
        maxlen=255,  # Max internal buffer length, longer would be clamped.
    )
    engine_name = 'A2F'
    engine_settings = None

    def execute(self, context):
        with open(self.filepath, 'r') as f:
            data = json.load(f)
            if not data.get("weightMat"):
                self.report({'ERROR'}, "The specified file is not valid.")
                return {'CANCELLED'}
            if self.auto_load_audio:
                audio_path = ''
                audio_path = data.get("trackPath")
                if audio_path:
                    if os.path.isfile(audio_path):
                        self.engine_settings.audio_filename = audio_path
                    else:
                        self.report({'WARNING'}, "Couldn't find a valid audio file.")
        self.engine_settings.filename = self.filepath
        # Update UI
        for region in context.area.regions:
            if region.type == 'UI':
                region.tag_redraw()
        return {'FINISHED'}


class FACEIT_OT_LoadAudioFile(bpy.types.Operator):
    '''Choose a audio file to import into sequencer'''
    bl_idname = 'faceit.load_audio_file'
    bl_label = 'Load Audio'
    bl_options = {'UNDO', 'INTERNAL'}

    engine: bpy.props.EnumProperty(
        name='mocap engine',
        items=(
            ('FACECAP', 'Face Cap', 'Face Cap TXT'),
            ('EPIC', 'Live Link Face', 'Live Link Face CSV'),
            ('A2F', 'Audio2Face', 'Nvidia Audio2Face'),
        ),
        options={'HIDDEN', },
    )

    filter_glob: bpy.props.StringProperty(
        default='*.mp3;*.wav;*.mov;*.mp4',
        options={'HIDDEN'}
    )

    filepath: bpy.props.StringProperty(
        name='File Path',
        description='Filepath used for importing txt files',
        maxlen=1024,
        default='',
    )

    files: bpy.props.CollectionProperty(
        name='File Path',
        type=bpy.types.OperatorFileListElement,
    )

    def execute(self, context):

        fdata.get_engine_settings(self.engine).audio_filename = self.filepath

        # Update UI
        for region in context.area.regions:
            if region.type == 'UI':
                region.tag_redraw()
        return {'FINISHED'}

    def invoke(self, context, event):
        engine_settings = fdata.get_engine_settings(self.engine)
        if engine_settings.audio_filename:
            self.filepath = engine_settings.audio_filename

        wm = context.window_manager
        wm.fileselect_add(self)
        return {'RUNNING_MODAL'}


class FACEIT_OT_ClearAudioFile(bpy.types.Operator):
    '''Clear the specified audio file'''
    bl_idname = 'faceit.clear_audio_file'
    bl_label = 'Clear Audio'
    bl_options = {'UNDO', 'INTERNAL'}

    engine: bpy.props.EnumProperty(
        name='mocap engine',
        items=(
            ('FACECAP', 'Face Cap', 'Face Cap TXT'),
            ('EPIC', 'Live Link Face', 'Live Link Face CSV'),
            ('A2F', 'Audio2Face', 'Nvidia Audio2Face'),
        ),
        options={'HIDDEN', },
    )

    def execute(self, context):

        fdata.get_engine_settings(self.engine).audio_filename = ''

        # Update UI
        # for region in context.area.regions:
        #     if region.type == 'UI':
        #         region.tag_redraw()
        return {'FINISHED'}


class FACEIT_OT_ClearMotionFile(bpy.types.Operator):
    '''Clear the specified motion file'''
    bl_idname = 'faceit.clear_motion_file'
    bl_label = 'Clear File'
    bl_options = {'UNDO', 'INTERNAL'}

    engine: bpy.props.EnumProperty(
        name='mocap engine',
        items=(
            ('FACECAP', 'Face Cap', 'Face Cap TXT'),
            ('EPIC', 'Live Link Face', 'Live Link Face CSV'),
            ('A2F', 'Audio2Face', 'Nvidia Audio2Face'),
        ),
        options={'HIDDEN', },
    )

    def execute(self, context):

        fdata.get_engine_settings(self.engine).filename = ''
        return {'FINISHED'}


class FACEIT_OT_DisableEyeLookShapeKeysFromSelectedObjects(bpy.types.Operator):
    bl_idname = 'faceit.disable_eye_look_shape_keys_from_selected_objects'
    bl_label = 'Disable Eye Look Shape Keys'
    bl_options = {'UNDO', 'INTERNAL'}

    option: EnumProperty(
        name='Option',
        items=(
            ('REMOVE', 'Remove', 'Remove the shape keys'),
            ('TOGGLE_MUTE', 'Toggle Mute', 'Mute the shape keys'),
        ),
    )

    @classmethod
    def poll(cls, context):
        faceit_objects = futils.get_faceit_objects_list()
        return any(obj in faceit_objects for obj in context.selected_objects)

    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self)

    def draw(self, context):
        layout = self.layout
        layout.prop(self, 'option', expand=True)
        if self.option == 'REMOVE':
            layout.label(text=f'Remove Shape Keys on Object(s)')
        else:
            layout.label(text=f'Toggle Shape Keys on Object(s)')
        faceit_objects = futils.get_faceit_objects_list()
        for obj in context.selected_objects:
            if obj not in faceit_objects:
                continue
            layout.label(text=f'                    + {obj.name}')

    def execute(self, context):
        eye_look_arkit_shapes = [
            'eyeLookDownLeft',
            'eyeLookInLeft',
            'eyeLookOutLeft',
            'eyeLookUpLeft',
            'eyeLookDownRight',
            'eyeLookInRight',
            'eyeLookOutRight',
            'eyeLookUpRight',
        ]
        target_shapes = rutils.get_target_shapes_dict(context.scene.faceit_arkit_retarget_shapes)
        eye_look_target_shapes = []
        for shape_name in eye_look_arkit_shapes:
            if shape_name in target_shapes:
                eye_look_target_shapes.extend(target_shapes[shape_name])
        faceit_objects = futils.get_faceit_objects_list()
        disabled_any = False
        for obj in context.selected_objects:
            if obj in faceit_objects:
                if obj.data.shape_keys:
                    for shape_key in obj.data.shape_keys.key_blocks:
                        if shape_key.name in eye_look_target_shapes:
                            if self.option == 'TOGGLE_MUTE':
                                shape_key.mute = not shape_key.mute
                                disabled_any = True
                            else:
                                obj.shape_key_remove(shape_key)
                                disabled_any = True
            obj.data.update()
        if disabled_any:
            self.report({'INFO'}, 'Success!')
        else:
            self.report({'INFO'}, 'No eye look shape keys found on selected objects')
        return {'FINISHED'}