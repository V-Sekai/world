local platform = import '../lib/platform_dict.json';
local groups_export = import '../lib/groups_export.json';

local enabled_engine_platforms = [platform.platform_info_dict[x] for x in ['windows', 'linux', 'web']];
local enabled_template_platforms = enabled_engine_platforms;

local enabled_groups_engine_platforms = enabled_engine_platforms;
local enabled_groups_template_platforms = enabled_engine_platforms;
local enabled_groups_export_platforms = [groups_export.groups_export_configurations[x] for x in ['windows', 'linux']];

local groups_gdextension = import '../lib/groups_gdextension.json';
local templates = import '../lib/templates.libsonnet';
local godot_editor_export = import '../lib/godot_editor_export.libsonnet';
local godot_pipeline = import '../lib/godot_pipeline.libsonnet';

local HEADLESS_SERVER_EDITOR = 'godot.linuxbsd.editor.double.x86_64.llvm';

local docker_pipeline = 'docker-groups';
local docker_uro_pipeline = 'docker-uro';
local docker_gocd_agent_pipeline = 'docker-gocd-agent-centos-8-groups';
local godot_template_groups_editor = 'godot-groups-editor';
local godot_template_groups = 'groups-export';
local godot_template_model_explorer = 'model-explorer-export';
local godot_template_groups_editor_staging = 'godot-groups-staging-editor';
local itch_fire_template = [docker_pipeline, docker_uro_pipeline, docker_gocd_agent_pipeline] + [godot_template_groups_editor] + [godot_template_groups] + [godot_template_groups_editor_staging] + [godot_template_model_explorer];

local generatePipeline = function(pipeline_name, godot_status, godot_branch) std.prune(godot_pipeline.godot_pipeline(
  pipeline_name=pipeline_name,
  godot_status=godot_status,
  godot_git='https://github.com/V-Sekai/godot.git',
  godot_branch=godot_branch,
  gocd_group='gamma',
  godot_engine_platforms=enabled_groups_engine_platforms,
  godot_template_platforms=enabled_groups_template_platforms
));

{
  'godot_v_sekai_editor.gopipeline.json': generatePipeline(godot_template_groups_editor, 'groups-4.2.0', 'groups-4.2'),
  'godot_v_sekai_staging_editor.gopipeline.json': generatePipeline(godot_template_groups_editor_staging, 'groups-staging-4.2', 'groups-staging-4.2'),
} + {
  'godot_template_groups_export.gopipeline.json'
    : std.prine(templates.godot_tools_pipeline_export(
      pipeline_name=godot_template_groups,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='https://github.com/V-Sekai/v-sekai-game.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='groups-4.2',
      gocd_project_folder='groups',
      enabled_export_platforms=enabled_groups_export_platforms,
    )),
  } + {
  'godot_template_groups_export.gopipeline.json'
  : std.prune(
    templates.godot_tools_pipeline_export(
      pipeline_name=godot_template_groups,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='https://github.com/V-Sekai/v-sekai-game.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='groups-4.2',
      gocd_project_folder='groups',
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
} + {
  'godot_template_model_explorer_export.gopipeline.json'
  : std.prune(
    templates.godot_tools_pipeline_export(
      pipeline_name=godot_template_model_explorer,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='ifiregames/model-explorer-42',
      project_git='https://github.com/V-Sekai/TOOL_model_explorer.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='model_explorer-4.2',
      gocd_project_folder='model_explorer',
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
} + {
  'docker_groups.gopipeline.json'
  : std.prune(
    templates.build_docker_server(
      pipeline_name=docker_pipeline,
      pipeline_dependency=godot_template_groups,
      docker_groups_git='https://github.com/V-Sekai/docker-groups.git',
      docker_groups_branch='master',
      docker_groups_dir='groups_server',
      gocd_group='charlie',
      godot_status='docker',
      docker_repo_groups_server='groupsinfra/groups-server',
      server_export_info=groups_export.groups_export_configurations.linux,
    )
  ),
  'docker_gocd_agent.gopipeline.json'
  : std.prune(
    templates.simple_docker_job(
      pipeline_name=docker_gocd_agent_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/gocd-agent-centos-8-groups',
      docker_git='https://github.com/V-Sekai/docker-groups.git',
      docker_branch='master',
      docker_dir='gocd-agent-centos-8-groups',
    )
  ),
  'docker_uro.gopipeline.json'
  : std.prune(
    templates.simple_docker_job(
      pipeline_name=docker_uro_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/uro',
      docker_git='https://github.com/V-Sekai/uro.git',
      docker_branch='master',
      docker_dir='.',
    )
  ),
} + {
'env.fire.goenvironment.json': std.prune({
    name: 'itch-fire',
    pipelines: itch_fire_template,
})}