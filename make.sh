
function create-secret() {
    kubectl -n staging-1-3 delete secret dispatcher-conf
    kubectl -n staging-1-3 create secret generic dispatcher-conf --from-file=conf_env.yml=dispatcher/conf/conf_env.yml
}

function install() {
    set -x
    helm -n ${NAMESPACE:?} install oda-dispatcher . --set image.tag="$(cd dispatcher; git describe --always)"
}

function upgrade() {
    set -x
    helm upgrade --install -n ${NAMESPACE:?} oda-dispatcher . --set image.tag="$(cd dispatcher; git describe --always)"
}

$@
