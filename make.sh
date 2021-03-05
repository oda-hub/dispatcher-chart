export ODA_ENVIRONMENT=${ODA_ENVIRONMENT:-}
export NAMESPACE=${NAMESPACE:-staging-1-3}


function create-secret() {
    kubectl -n $NAMESPACE delete secret dispatcher-conf
    kubectl -n $NAMESPACE create secret generic dispatcher-conf --from-file=conf_env.yml=conf/conf_env.yml
}

function install() {
    upgrade
}

function upgrade() {
    set -x
    helm upgrade --install -n ${NAMESPACE:?} oda-dispatcher . -f values-${ODA_ENVIRONMENT:?}.yaml --set image.tag="$(cd dispatcher; git describe --always)" 
}

$@
