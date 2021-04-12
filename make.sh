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

function upgrade() {
    set -x
    helm upgrade --install -n ${ODA_NAMESPACE:?} oda-dispatcher . -f $(site-values) --set image.tag="$(cd dispatcher; git describe --always)" 
}

$@
