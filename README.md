# My Kubernetes Cluster

This is the repository containing my Kubernetes configuration on Amazon EKS (Elastic Kubernetes Service)

## Table of Contents

1. [General Workflow](#General-Workflow)
2. [Kubernetes Various Notes](#Kubernetes-Various-Notes)
3. [GitOps Kubernetes Cluster](#GitOps-Kubernetes-Cluster)

### General Workflow

* Create Kubernetes cluster configuration file (`cluster.yaml`)
* Create cluster from configuration

### Kubernetes Various Notes

* Launching a cluster that is only available through private networks on your VPC, refer to this [EKS user guide](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html#private-access).

### GitOps Kubernetes Cluster

1. Install **AWS CLI** >= 1.16.156
2. Install a compatible version of `kubectl` that works with **EKS**
3. Create an empty *repository*
    1. This can be on **GitHub**, if you want
4. Create an **EKS** *cluster*:

    ```bash
    eksctl create cluster
    ```

5. After the *cluster* is created, check the *cluster* contents to see system workloads:

    ```bash
    kubectl get nodes
    ```

    ```bash
    kubectl get pods --all-namespaces
    ```

6. We need to enable a **gitops** *operator* on our *cluster* with:

    ```bash
    eksctl enable repo \
        --git-url git@github.com:example/my-eks-config \
        --git-email <username>@users.noreply.github.com \
        --cluster your-cluster-name \
        --region your-cluster-region
    ```

    This command, along with some additional arguments, will set up our *cluster* with the **gitops** *operator*, **Flux** and **Flux Helm Operator with Helm v3 support**.

    * `--git-url`: this points to a Git URL where the configuration for your cluster will be stored. This will contain config for the workloads and infrastructure later on.
    * `--git-email`: the email used to commit changes to your config repository.
    * `--cluster`: the name of your cluster. Use `eksctl get cluster` to see all clusters in your default region.
    * `--region`: the region of your cluster.

    You can find additional arguments and options in the [gitops reference of eksctl](https://eksctl.io/usage/gitops/).

7. While the above command is running, take note of the line starting with `ssh-rsa` and copy it somewhere. We will use this to give the *operator* read/write access to our *repository*. For example, in **GitHub**, we would add this as a "deploy key" by navigating to the **GitHub** *repo* and then to `Settings > Deploy keys > Add deploy key` (make sure to check the box that says "Allow write access").

    **Flux** will poll **Git** at a specific interval, but you can tell it to sync the changes immediately with the following command:

    ```bash
    fluxctl sync --k8s-fwd-ns flux
    ```

    * The next time **Flux** syncs from **Git**, it will start updating the *cluster* and actively deploying.

8. Run the command `git pull` after **Flux** has finished syncing and you will that **eksctl** has committed them to your config repository. That is, you will see the new *namespace* and *pods* in your *cluster*.

    ```bash
    kubectl get pods --all-namespaces
    ```

    You now have a fully gitops enable Kubernetes cluster!

9. The following command will set up your cluster with the `app-dev` profile, the first **gitops** Quick Start. The config files you need for a production-ready cluster will be in the git repository and deployed in the cluster. Then, whenever you make changes in the configuration they will be reflected on your cluster.

    ```bash
    eksctl enable profile app-dev \
        --git-url git@github.com:example/my-eks-config \
        --git-email <username>@users.noreply.github.com \
        --cluster your-cluster-name \
        --region your-cluster-region
    ```

    * `--git-url`: this points to a Git URL where the configuration for your cluster will be stored. This will contain config for the workloads and infrastructure later on.
    * `--git-email`: the email used to commit changes to your config repository.
    * `--cluster`: the name of your cluster. Use `eksctl get cluster` to see all clusters in your default region.
    * `--region`: the region of your cluster.
    * *positional argument*: this is the name of one of the profiles we put together, so you can easily pick and choose and won't have to start from scratch every time. Here, we use `app-dev`.

    You can find additional arguments and options in the [gitops reference of eksctl](https://eksctl.io/usage/gitops/).

    This loads **gitops** Quick Start manifests into your repo and uses templating to add the cluster name and region to the config which means the cluster components that need those values can work (ex: `alb-ingress`).

10. Fetch the latest changes to your configuration repository so you can see `eksctl` updated it with the templated files from the Quick Start. So, next time Flux polls the repo and syncs, it will start updating the cluster with the current config.

    Run the following command to see the new namespaces and pods:

    ```bash
    kubectl get pods --all-namespaces
    ```

    Your Kubernetes cluster is now fully configured and **gitopsed**! With the `app-dev` Quick Start profile, you will have the following components running in your cluster:
    * **ALB** ingress controller -- to easily expose services to the public
    * *Cluster* autoscaler -- to automatically add/remove nodes to/from your cluster based on its usage
    * **Prometheus** (its **Alertmanager**, its operator, its `node-exporter`, `kube-state-metrics`, and `metrics-server`) -- for powerful metrics & alerts
    * **Grafana** -- for a rich way to visualize metrics via *dashboards* you can create, explore, and share
    * **Kubernetes** dashboard -- **Kubernetes'** standard *dashboard*
    * **Fluentd** & **Amazon's CloudWatch** agent -- for *cluster* & *containers'* log collection, aggregation & analytics in **CloudWatch**
    * **podinfo** -- a toy demo application

11. Finally, you can confirm all of this stuff is up and running with the following command:

    ```bash
    kubectl get service --namespace demo
    ```

    Then, you can port-forward the service to access it more easily:

    ```bash
    kubectl port-forward -n demo svc/podinfo 9898:9898
    ```

    When you open `localhost:9898` in your browser you should see a "greetings" screen from **podinfo**.

That's all folks!
