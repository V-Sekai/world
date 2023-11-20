local groups_export = import 'groups_export.json';
local platform = import 'platform_dict.json';
local templates = import 'templates.libsonnet';

local enabled_engine_platforms = [platform.platform_info_dict[x] for x in ['windows', 'linux', 'web']];
local enabled_template_platforms = enabled_engine_platforms;

local enabled_groups_engine_platforms = enabled_engine_platforms;
local enabled_groups_template_platforms = enabled_engine_platforms;
local enabled_groups_export_platforms = [groups_export.groups_export_configurations[x] for x in ['windows', 'linux']];

{

  godot_editor_export(
    pipeline_name='',
    pipeline_dependency='',
    itchio_login='',
    gocd_group='',
    godot_status='',
    gocd_project_folder='',
    enabled_export_platforms=[],
    first_stage_approval=null,
    timer_spec='* * * * * ?',
  ):: {
    name: pipeline_name,
    group: gocd_group,
    label_template: pipeline_name + '.${COUNT}',
    timer: {
      spec: timer_spec,
      only_on_changes: true,
    },
    environment_variables:
      [{
        name: 'GODOT_STATUS',
        value: godot_status,
      }],
    materials: [
      {
        name: pipeline_dependency + '_pipeline_dependency',
        type: 'dependency',
        pipeline: pipeline_dependency,
        stage: 'templateZipStage',
        ignore_for_scheduling: false,
      },
    ],
    stages: [
      {
        name: 'uploadStage',
        approval: first_stage_approval,
        jobs: [
          {
            name: export_info.export_name + '_job',
            resources: [
              'linux',
              'mingw5',
            ],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: export_info.platform_name + '_job',
                is_source_a_file: true,
                source: export_info.export_executable,
                destination: export_info.export_directory,
              },
              if std.endsWith(export_info.export_executable, '.exe') then {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: export_info.platform_name + '_job',
                is_source_a_file: true,
                source: templates.exe_to_pdb_path(export_info.export_executable),
                destination: export_info.export_directory,
              } else null,
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push ' + export_info.export_directory + ' ' + itchio_login + ':' + export_info.itchio_out + ' --userversion `date +"%Y-%m-%dT%H%M%SZ" --utc`-$GO_PIPELINE_NAME',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          }
          for export_info in enabled_export_platforms
          if export_info.itchio_out != null
        ],
      },
    ],
  },
}
