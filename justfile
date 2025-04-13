# Minikube configuration
minikube_cpus := "4"
minikube_memory := "8192"
minikube_k8s_version := "v1.29.0"
minikube_driver := "docker"
minikube_container_runtime := "containerd"
minikube_addons := "ingress"

# GitOps repository info
git_url := "ssh://git@gitea.imkumpy.in:kumpy/fluxcd-demo.git"
git_branch := "main"
git_path := "clusters/minikube"

# Start minikube with standard config
start:
    echo "🚀 Starting Minikube..."
    minikube start \
      --cpus={{minikube_cpus}} \
      --memory={{minikube_memory}} \
      --kubernetes-version={{minikube_k8s_version}} \
      --driver={{minikube_driver}} \
      --container-runtime={{minikube_container_runtime}} \
      --addons={{minikube_addons}}

# Bootstrap FluxCD into Minikube
bootstrap:
    echo "📦 Bootstrapping FluxCD..."
    flux bootstrap git \
      --url={{git_url}} \
      --branch={{git_branch}} \
      --path={{git_path}} \
      --components-extra=image-reflector-controller,image-automation-controller

# Wipe Minikube and Flux state (use with caution)
clean:
    echo "🧹 Cleaning up Minikube and Flux state..."
    minikube delete --all --purge
    rm -rf ~/.flux
    rm -f ~/.kube/config
    echo "✅ Cleaned."

# Reset kube context to minikube after deletion
context:
    echo "🔁 Resetting kubectl context..."
    minikube update-context

# Run full clean + bootstrap workflow
rebuild: clean start bootstrap context

# Port-forward Grafana (adjust as needed)
grafana:
    kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80

