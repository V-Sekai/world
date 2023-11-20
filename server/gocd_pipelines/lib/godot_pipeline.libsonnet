local groups_export = import 'groups_export.json';
local platform = import 'platform_dict.json';
local templates = import 'templates.libsonnet';

local enabled_engine_platforms = [platform.platform_info_dict[x] for x in ['windows', 'linux', 'web']];
local enabled_template_platforms = enabled_engine_platforms;

{
  godot_pipeline(
    pipeline_name='',
    godot_status='',
    godot_git='',
    godot_branch='',
    gocd_group='',
    godot_modules_git='',
    godot_modules_branch='',
    godot_engine_platforms=enabled_engine_platforms,
    godot_template_platforms=enabled_template_platforms,
    first_stage_approval=null,
    timer_spec='* * * * * ?',
  ):: {
    name: pipeline_name,
    group: gocd_group,
    timer: {
      spec: timer_spec,
      only_on_changes: true,
    },
    label_template: godot_status + '.${godot_sandbox[:8]}.${COUNT}',
    environment_variables:
      [{
        name: 'GODOT_STATUS',
        value: godot_status,
      }],
    materials: [
      {
        name: 'godot_sandbox',
        url: godot_git,
        type: 'git',
        branch: godot_branch,
        destination: 'g',
      },
      if godot_modules_git != '' then
        {
          name: 'godot_custom_modules',
          url: godot_modules_git,
          type: 'git',
          branch: godot_modules_branch,
          destination: 'godot_custom_modules',
          shallow_clone: false,
        }
      else null,
    ],
    stages: [
      {
        name: 'defaultStage',
        approval: first_stage_approval,
        jobs: [
          {
            name: platform_info.platform_name + '_job',
            resources: [
              'mingw5',
              'linux',
            ],
            artifacts: [
              {
                source: 'g/bin/' + platform_info.editor_godot_binary,
                destination: '',
                type: 'build',
              },
              if std.endsWith(platform_info.editor_godot_binary, '.exe') then {
                source: 'g/bin/' + templates.exe_to_pdb_path(platform_info.editor_godot_binary),
                destination: '',
                type: 'build',
              } else null,
            ],
            environment_variables: platform_info.environment_variables,
            tasks: [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'sed -i "/^status =/s/=.*/= \\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\"/" version.py',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  platform_info.scons_env + 'scons werror=no platform=' + platform_info.scons_platform + ' target=' + platform_info.target + ' use_lto=no ' + platform_info.godot_scons_arguments +
                  '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              if platform_info.editor_godot_binary != platform_info.intermediate_godot_binary then
                {
                  type: 'exec',
                  arguments: [
                    '-c',
                    'cp -p g/bin/' + platform_info.intermediate_godot_binary + ' g/bin/' + platform_info.editor_godot_binary,
                  ],
                  command: '/bin/bash',
                }
              else null,
            ],
          }
          for platform_info in godot_engine_platforms
        ],
      },
      {
        name: 'templateStage',
        jobs: [
          {
            name: platform_info.platform_name + '_job',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: if platform_info.template_artifacts_override != null then platform_info.template_artifacts_override else [
              {
                type: 'build',
                source: 'g/bin/' + platform_info.template_debug_binary,
                destination: '',
              },
              {
                type: 'build',
                source: 'g/bin/' + platform_info.template_release_binary,
                destination: '',
              },
              {
                type: 'build',
                source: 'g/bin/version.txt',
                destination: '',
              },
            ],
            environment_variables: platform_info.environment_variables,
            tasks: [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_command,
                ],
                command: '/bin/bash',
                working_directory: 'g',
              }
              for extra_command in platform_info.extra_commands
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'sed -i "/^status =/s/=.*/= \\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\"/" version.py',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              if platform_info.editor_godot_binary == platform_info.intermediate_godot_binary then {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_name,
                stage: 'defaultStage',
                job: platform_info.platform_name + '_job',
                is_source_a_file: true,
                source: platform_info.intermediate_godot_binary,
                destination: 'g/bin/',
              } else {
                type: 'exec',
                arguments: [
                  '-c',
                  platform_info.scons_env + 'scons werror=no platform=' + platform_info.scons_platform + ' target=' + platform_info.target + ' use_lto=no ' + platform_info.godot_scons_arguments + if godot_modules_git != '' then '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'ls',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp bin/' + platform_info.intermediate_godot_binary + ' bin/' + platform_info.template_debug_binary + ' && cp bin/' + platform_info.intermediate_godot_binary + ' bin/' + platform_info.template_release_binary + if platform_info.strip_command != null then ' && ' + platform_info.strip_command + ' bin/' + platform_info.template_release_binary else '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'eval `sed -e "s/ = /=/" version.py` && declare "_tmp$patch=.$patch" "_tmp0=" "_tmp=_tmp$patch" && echo $major.$minor${!_tmp}.$GODOT_STATUS.$GO_PIPELINE_COUNTER > bin/version.txt',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_command,
                ],
                command: '/bin/bash',
                working_directory: 'g',
              }
              for extra_command in platform_info.template_extra_commands
            ],
          }
          for platform_info in godot_template_platforms
        ],
      },
      {
        name: 'templateZipStage',
        jobs: [
          {
            name: 'defaultJob',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'godot.templates.tpz',
                destination: '',
              },
            ],
            tasks: [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf templates',
                ],
                command: '/bin/bash',
              },
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: 'version.txt',
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'templateStage',
                job: godot_template_platforms[0].platform_name + '_job',
              },
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: templates.exe_to_pdb_path(platform.platform_info_dict.windows.editor_godot_binary),
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'defaultStage',
                job: 'windows_job',
              },
            ] + std.flatMap(function(platform_info) [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: output_artifact,
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'templateStage',
                job: platform_info.platform_name + '_job',
              }
              for output_artifact in if platform_info.template_output_artifacts != null then platform_info.template_output_artifacts else [
                platform_info.template_debug_binary,
                platform_info.template_release_binary,
              ]
            ], godot_template_platforms) + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf godot.templates.tpz',
                ],
                command: '/bin/bash',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'zip -1 godot.templates.tpz templates/*',
                ],
                command: '/bin/bash',
              },
            ],
          },
        ],
      },
    ],
  },
}
