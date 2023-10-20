#!/bin/sh
TODAY=$(date +%Y%m%d)

alias devel='cd /home/giancarlorosso/Development'
alias home="cd /mnt/c/Users/giancarlorosso"
alias svn_propset='svn propset svn:ignore -F /c/users/giancarlorosso/Documents/svn_ignore.txt -R .'
alias display_updates='mvn org.codehaus.mojo:versions-maven-plugin:2.8.1:display-dependency-updates'
alias display_updates_no_major='mvn -DallowAnyUpdates=false -DallowMajorUpdates=false org.codehaus.mojo:versions-maven-plugin:2.8.1:display-dependency-updates'
alias oc-prod='oc login https://prod-openshift.fineco.it --username=giancarlorosso'
alias oc-dev='oc login https://dev-openshift.fineco.it --username=giancarlorosso'
alias oc-fineco-dev='oc project fineco-dev'
alias oc-fineco-test='oc project fineco-test'
alias oc-get-pods='oc get pods'
alias dev-log='cd /data/logs/dev/$TODAY'
alias test-log='cd /data/logs/dev/$TODAY'
alias mount_u='sudo mount -t drvfs U: /mnt/u/'
alias sshlog='ssh -l giancarlorosso@kdsa-view@netltr ckpsmp'
alias sizes='du -d1 -k . | sort -n'
alias ddeploy='cd ~/Development/deploy'
alias ddocker='cd ~/Development/architetture/docker'
alias dconfigs='cd ~/Development/deploy/configs'
alias dansible='cd ~/Development/deploy/ansible'
alias kdevint='kubectl login -u giancarlorosso -s devkubeint && kubectl config set-context --current --namespace=fineco-dev'
alias kdevext='kubectl login -u giancarlorosso -s devkubeext && kubectl config set-context --current --namespace=fineco-dev'
alias ktestint='kubectl login -u giancarlorosso -s devkubeint && kubectl config set-context --current --namespace=fineco-test'
alias ktestext='kubectl login -u giancarlorosso -s devkubeext && kubectl config set-context --current --namespace=fineco-test'
alias kmasterint='kubectl login -u giancarlorosso -s prodkubeint && kubectl config set-context --current --namespace=fineco-master'
alias kmasterext='kubectl login -u giancarlorosso -s prodkubeext && kubectl config set-context --current --namespace=fineco-master'
alias kprodint='kubectl login -u giancarlorosso -s prodkubeint && kubectl config set-context --current --namespace=fineco-prod'
alias kprodext='kubectl login -u giancarlorosso -s prodkubeext && kubectl config set-context --current --namespace=fineco-prod'
alias kgetpods='kubectl get pods'
alias ec='emacsclient -q'

function opensslfull() {
    openssl crl2pkcs7 -nocrl -certfile $1 | openssl pkcs7 -print_certs -text -noout
}

function kubelogs() {
    kubectl logs --tail 10 -f $1
}

function kubersh() {
    kubectl exec --stdin --tty -n fineco-dev $1 -- bash
}

function git_clone() {
    # git_clone deploy/ansible/pianificazioneservice pianificazioneservice
    if [ $# -lt 2 ]; then
	echo "No arguments supplied"
    else
        git clone "https://giancarlorosso@cvs.fineco.it/gerrit/a/$1" $2 && (cd "$1" && mkdir -p `git rev-parse --git-dir`/hooks/ && curl -Lo `git rev-parse --git-dir`/hooks/commit-msg https://cvs.fineco.it/gerrit/tools/hooks/commit-msg && chmod +x `git rev-parse --git-dir`/hooks/commit-msg)
    fi
}

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

function ca {
    if [ $# -eq 0 ]; then
	echo "No arguments supplied"
    else
	ssh -l giancarlorosso@root@$1 ckpsmp
    fi
}

function proxysrv {
    echo 'Proxysrv Standard'
    export http_proxy=http://proxysrv.fineco.it:3128
    export https_proxy=$http_proxy
    export no_proxy=".fineco.it,.finecobank.com"
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

git-verify-pack() {
    if [ $# -eq 0 ]; then
	echo "No arguments supplied"
    else
	git verify-pack -v $1 | sort -k 3 -n | tail -10
    fi
}

git-rev-list() {
    if [ $# -eq 0 ]; then
	echo "No arguments supplied"
    else
	git rev-list --objects --all | grep $1
    fi
}

function ls-projects {
    ssh -p 29418 cvs.fineco.it gerrit ls-projects -m $1
}

function set-jdk() {
    if [ $# -eq 0 ]; then
	echo "No arguments supplied"
    else
	export JAVA_HOME=/etc/alternatives/java_sdk_$1
        export PATH=$JAVA_HOME/bin:$PATH
	java -version
    fi
}

function oc-logs() {
    if [ $# -eq 1 ]; then
	echo "No arguments supplied"
    else
	oc logs --tail 10 -f $1
    fi
}

function kube-logs() {
    if [ $# -eq 1 ]; then
	echo "No arguments supplied"
    else
	kubectl logs --tail 10 -f $1
    fi
}
