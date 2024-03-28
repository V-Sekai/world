group:          "charlie"
label_template: "docker-uro_${docker-uro_git[:8]}.${COUNT}"
materials: [{
	branch:      "master"
	destination: "g"
	name:        "docker-uro_git"
	type:        "git"
	url:         "https://github.com/V-Sekai/uro.git"
}]
name: "docker-uro"
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
			arguments: ["-c", "set -x; docker build -t \"groupsinfra/uro:$GO_PIPELINE_LABEL\" \"g/.\" && docker push \"groupsinfra/uro:$GO_PIPELINE_LABEL\" && echo \"groupsinfra/uro:$GO_PIPELINE_LABEL\" > docker_image.txt"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}]
	}]
	name: "buildPushStage"
}]
