group:          "charlie"
label_template: "docker-gocd-agent-centos-8-groups_${docker-gocd-agent-centos-8-groups_git[:8]}.${COUNT}"
materials: [{
	branch:      "master"
	destination: "g"
	name:        "docker-gocd-agent-centos-8-groups_git"
	type:        "git"
	url:         "https://github.com/V-Sekai/docker-groups.git"
}]
name: "docker-gocd-agent-centos-8-groups"
stages: [{
	clean_workspace: false
	fetch_materials: true
	jobs: [{
		artifacts: [{
			destination: ""
			source:      "docker_image.txt"
			type:        "build"
		}]
		name: "dockerJob"
		resources: [
			"dind",
		]
		tasks: [{
			arguments: ["-c", "set -x; docker build -t \"groupsinfra/gocd-agent-centos-8-groups:$GO_PIPELINE_LABEL\" \"g/gocd-agent-centos-8-groups\" && docker push \"groupsinfra/gocd-agent-centos-8-groups:$GO_PIPELINE_LABEL\" && echo \"groupsinfra/gocd-agent-centos-8-groups:$GO_PIPELINE_LABEL\" > docker_image.txt"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}]
	}]
	name: "buildPushStage"
}]
