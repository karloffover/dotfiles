#!/bin/sh

#set -x

function pause(){
   read -p "$*"
}

usage() {
	cat <<EOF
Usage:	$0 -p trading -s webapps/pdfe -n pdfe-2.0
        Scarica un progetto da SVN e ne copia il contenuto,
        comprensivo di storico, su git.

Options:
        -h Questo help
        -p repository SVN di partenza (ie. trading, portal) relativo a cvs.fineco.it
        -s percorso interno al repository (ie. webapps/public,
           apps/fundinfo, libs/fineco-commons
        -n nome di destinazione (ie. pdfe)
        -d parent git di destinazione
        -k altro repository svn di partenza

Examples
        $0 -p trading -s libs/fineco-trading-mspconnector -n msp-connector
           crea un progetto in git al percorso trading/msp-connector
           recuperando i sorgenti da SVN.
EOF
}

while getopts "hp:s:n:d:k:" OPTION
do
    case $OPTION in
        h) usage; exit 1;;
        p) SVN_REPO=${OPTARG};;
        s) SVN_PRJ=${OPTARG};;
        n) GIT_NAME=${OPTARG};;
        d) GIT_DEST_PARENT=${OPTARG};;
        k) SVN_FULL_PATH=${OPTARG};;
    esac
done

## $0 trading webapps/pdfe

##SVN_REPO=$1
##SVN_PRJ=$2

if [ $# -lt 6 ]; then
    usage
    exit 1
fi

folder=$(echo $SVN_PRJ | cut -d'/' -f2)

if [ x${GIT_DEST_PARENT} != x ]; then
    GIT_PARENT=${GIT_DEST_PARENT}
else
    GIT_PARENT=${SVN_REPO}
fi

echo -e "\tProgetto importato: $SVN_PRJ
\tDestinazione: ssh://cvs.fineco.it:29418/$GIT_PARENT/$GIT_NAME"

pause 'Press [Enter] key to continue...'

if [ x${SVN_FULL_PATH} == x ]; then
    svn co https://cvs.fineco.it/svn/$SVN_REPO/$SVN_PRJ
else
    svn co ${SVN_FULL_PATH}
fi

pushd $folder && svn log --xml --quiet | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /'
#exit 0
popd
rm $folder -rf
if [ x${SVN_FULL_PATH} == x ]; then
    git svn clone https://cvs.fineco.it/svn/$SVN_REPO/$SVN_PRJ --authors-file=./users.txt --no-metadata --prefix "" -s $folder
else
    git svn clone ${SVN_FULL_PATH} --authors-file=./users.txt --no-metadata --prefix "" -s $folder
fi

if [ -d $folder ]; then
    pushd $folder
    for t in $(git for-each-ref --format='%(refname:short)' refs/remotes/tags); do git tag ${t/tags\//} $t && git branch -D -r $t; done
    for b in $(git for-each-ref --format='%(refname:short)' refs/remotes); do git branch $b refs/remotes/$b && git branch -D -r $b; done
    for p in $(git for-each-ref --format='%(refname:short)' | grep @); do git branch -D $p; done
    git branch -d trunk
    echo "parent $SVN_REPO $SVN_REPO/$GIT_NAME"
    ssh -p 29418 cvs.fineco.it gerrit create-project --parent $GIT_PARENT $GIT_PARENT/$GIT_NAME
    git remote add origin ssh://giancarlorosso@cvs.fineco.it:29418/$GIT_PARENT/$GIT_NAME
    git tag svn-import
    git push origin --all
    git push origin --tags
    popd
else
    exit 128
fi
echo "Progetto $GIT_NAME importato correttamente."
