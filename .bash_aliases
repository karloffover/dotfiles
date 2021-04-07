#!/bin/sh
TODAY=$(date +%Y%m%d)

alias devel='cd /home/giancarlorosso/Development'
alias home="cd /mnt/c/Users/giancarlorosso"
alias svn_propset='svn propset svn:ignore -F /c/users/giancarlorosso/documents/netbeansprojects/svn_ignore.txt -R .'
alias display_updates='mvn org.codehaus.mojo:versions-maven-plugin:2.8.1:display-dependency-updates'
alias display_updates_no_major='mvn -DallowAnyUpdates=false -DallowMajorUpdates=false org.codehaus.mojo:versions-maven-plugin:2.8.1:display-dependency-updates'
alias oc-prod='oc login https://prod-openshift.fineco.it --username=giancarlorosso'
alias oc-dev='oc login https://dev-openshift.fineco.it --username=giancarlorosso'
alias fineco-dev='oc project fineco-dev'
alias fineco-test='oc project fineco-test'
alias get-pods='oc get pods'
alias dev-log='cd /data/logs/dev/$TODAY'
alias test-log='cd /data/logs/dev/$TODAY'
alias mount_u='sudo mount -t drvfs U: /mnt/u/'

function scp_get {
    if [ $# -lt 2 ]; then
        echo "No arguments supplied"
    else
        scp giancarlorosso@root@$1@ckpsmp:$2 .
    fi
}

function scp_put {
    if [ $# -lt 2 ]; then
        echo "No arguments supplied"
    else
        scp $1 giancarlorosso@root@$2@ckpsmp:$3
    fi
}

function sshc {
    if [ $# -eq 0 ]; then
	echo "No arguments supplied"
    else
	ssh -l giancarlorosso@root@$1 ckpsmp
    fi
}

function proxy {
    echo 'Proxy Standard'
    export http_proxy=http://proxy.fineco.it:3128
    export https_proxy=$http_proxy
    export no_proxy=".fineco.it,.finecobank.com"
}

function proxy_v1 {
    echo "Proxy-v1"
    export http_proxy=http://proxy-v1.fineco.it:3128
    export https_proxy=$http_proxy
    export no_proxy=".fineco.it,.finecobank.com"
}

function proxy_v2 {
    echo "Proxy-v2"
    export http_proxy=http://proxy-v2.fineco.it:3128
    export https_proxy=$http_proxy
    export no_proxy=".fineco.it,.finecobank.com"
}

function unset_proxy {
    unset http_proxy
    unset https_proxy
}

function run_ssh_env {
    . "${SSH_ENV}" > /dev/null
}

function start_ssh_agent {
    echo "Initializing new SSH agent..."
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo "succeeded"
    chmod 600 "${SSH_ENV}"

    run_ssh_env;

    ssh-add ~/.ssh/id_rsa;
}

agent_is_running() {
    if [ "$SSH_AUTH_SOCK" ]; then
	# ssh-add returns:
	#   0 = agent running, has keys
	#   1 = agent running, no keys
	#   2 = agent not running
	ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
    else
	false
    fi
}

agent_has_keys() {
    ssh-add -l >/dev/null 2>&1
}

agent_load_env() {
    . "$env" >/dev/null
}

agent_start() {
    (umask 077; ssh-agent >"$env")
    . "$env" >/dev/null
}

add_all_keys() {
    ls ~/.ssh | grep id_rsa[^.]*$ | sed "s:^:`echo ~`/.ssh/:" | xargs -n 1 ssh-add
}

gerrit() {
	ssh -p 29418 cvs.fineco.it gerrit "$@"
}
