#!/bin/sh

#set -x

usage() {
        cat <<EOF
Usage:  $0 -p JenkinsfileToCheck 
        Fa check del Jenkinsfile.

Options:
        -h Questo help
        -p Jenkinsfile

Examples
        $0
           Fa il check del default Jenkinsfile
        $0 -p JenkinsfileTapi
           Fa il check di JenkinsfileTapi
EOF
}

while getopts "hp:" OPTION
do
    case $OPTION in
        h) usage; exit 1;;
        p) JENKINSFILE=${OPTARG};;
    esac
done

if [ $# -lt 1 ]; then
    JENKINSFILE=Jenkinsfile
fi

# ssh (Jenkins CLI)
JENKINS_SSHD_PORT=41365
JENKINS_HOSTNAME=jenkins-vm01.fineco.it
ssh -p $JENKINS_SSHD_PORT $JENKINS_HOSTNAME declarative-linter < ./${JENKINSFILE}
