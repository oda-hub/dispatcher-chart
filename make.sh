
function create-secret() {
    kubectl -n staging-1-3 delete secret dispatcher-conf
    kubectl -n staging-1-3 create secret generic dispatcher-conf --from-file=conf_env.yml=dispatcher/conf/conf_env.yml
}

$@
