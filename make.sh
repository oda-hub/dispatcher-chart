export ODA_SITE=${ODA_SITE:-}
export ODA_NAMESPACE=${ODA_NAMESPACE:-oda-staging}

function site-values() {
    if [ "${ODA_SITE}" == "" ]; then
        echo values.yaml
    else
        echo values-${ODA_SITE}.yaml
    fi
}

function create-secret() {
    kubectl -n $ODA_NAMESPACE delete secret dispatcher-conf || echo ok
    kubectl -n $ODA_NAMESPACE create secret generic dispatcher-conf --from-file=conf_env.yml=conf/conf_env.yml
}

function install() {
    upgrade
}

function compute-version() {
    for d in dispatcher-container/*; do  (
        if cd $d > /dev/null 2>&1; then
            if ls -d .git > /dev/null 2>&1; then
                echo "$d: "
                echo -n "  branch: "; git branch | awk 'NF>1 {printf "branch: "$2"\n"}'
                echo -n "  revision: "; git describe --tags --always
            fi
        fi
    ); done
}

function upgrade() {
    set -xe

    helm upgrade --wait --install -n ${ODA_NAMESPACE:?} oda-dispatcher . -f $(site-values) --set image.tag="$(cd dispatcher-container; git describe --always)" 

    (echo -e "Deployed **$(pwd | xargs basename)** to $ODA_NAMESPACE:\n***\n"; cat version-long) | \
        bash make.sh mattermost deployment-$ODA_NAMESPACE
}


function mattermost() {
    channel=${1:?}
    message=${2:-stdin}

    if [ $message == "stdin" ]; then
        message=$(cat)
    fi

    curl -i -X POST -H 'Content-Type: application/json' \
        -d '{"channel": "'"$channel"'", "text": "'"${message:?}"' :tada:"}' \
        ${MATTERMOST_HOOK:?}
}

function update() {
    set -xe
    revision=${1:?e.g. \"master\"}

    git submodule foreach --recursive bash -c 'echo -e "\033[33mupdating $PWD\033[0m"; git pull origin master; git pull origin master'
    (cd dispatcher-container; git commit -a -m "update submodules"; git push)
    git commit -a -m "update submodules"; git push
}

$@
