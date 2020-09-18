#!/bin/bash

set -x
JENKINS_URL=https://cvs.fineco.it/jenkins
#JENKINS_CRUMB=$(curl --user jenkins-user:Cvbhui135 "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
#curl --user jenkins-user:Cvbhui135 -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<$1" $JENKINS_URL/pipeline-model-converter/validate
curl --user giancarlorosso:11e9b9eb489d43be2bf69727a1f605b34d -X POST -F "jenkinsfile=<$1" ${JENKINS_URL}/pipeline-model-converter/validate
