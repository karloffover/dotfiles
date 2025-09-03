#!/bin/bash

set -x
JENKINS_URL=https://cvs.fineco.it/jenkins
#JENKINS_CRUMB=$(curl --user jenkins-user: "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
#curl --user jenkins-user: -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<$1" $JENKINS_URL/pipeline-model-converter/validate
curl --user giancarlorosso: -X POST -F "jenkinsfile=<$1" ${JENKINS_URL}/pipeline-model-converter/validate
