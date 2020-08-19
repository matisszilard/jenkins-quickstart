
build:
	docker build -t jenkins -f ./Dockerfile .

deploy: build
	docker tag jenkins mszg/jenkins:latest
	docker push mszg/jenkins:latest

run:
	docker run -p 8080:8080 -p 50000:50000 -v ./jenkins_home:/var/jenkins_home jenkins

run-deployed:
	docker pull mszg/jenkins:latest
	docker run -p 8080:8080 -p 50000:50000 -v ./jenkins_home:/var/jenkins_home mszg/jenkins:latest

namespace ?= jenkins
jenkins-pvc:
	oc apply -f ./kube/pvc.yaml -n ${namespace}

jenkins-pvc-down:
	oc delete -f ${DEVOPS}/devops-palinta/devops/jenkins/pvc.yaml -n ${namespace}

jenkins: jenkins-pvc
	oc apply -f ${DEVOPS}/devops-palinta/devops/jenkins/jenkins.yaml -n ${namespace}

jenkins-down:
	oc delete -f ${DEVOPS}/devops-palinta/devops/jenkins/jenkins.yaml -n ${namespace}


# Run Jenkins agents

## TODO update env variables

run-jenkins-golang-agent-in-docker:
	docker run -it --rm \
	--env JENKINS_SECRET=${JENKINS_AGENT_GOLANG_DOCKER_SECRET} \
	--env JENKINS_TUNNEL=${JENKINS_TUNNEL} \
	--env JENKINS_AGENT_NAME=${JENKINS_AGENT_GOLANG_DOCKER_NAME} \
	--env JENKINS_AGENT_WORKDIR=${JENKINS_AGENT_GOLANG_DOCKER_WORKDIR} \
	--env JENKINS_URL=${JENKINS_URL} \
	mszg/jenkins-slave:v0.5.0

run-jenkins-agent-dind:
	docker run -it --rm \
	--env JENKINS_SECRET=${JENKINS_AGENT_GOLANG_DOCKER_SECRET} \
	--env JENKINS_TUNNEL=${JENKINS_TUNNEL} \
	--env JENKINS_AGENT_NAME=${JENKINS_AGENT_GOLANG_DOCKER_NAME} \
	--env JENKINS_AGENT_WORKDIR=${JENKINS_AGENT_GOLANG_DOCKER_WORKDIR} \
	--env JENKINS_URL=${JENKINS_URL} \
	-v /var/run/docker.sock:/var/run/docker.sock \
	jenkins-agent:latest
