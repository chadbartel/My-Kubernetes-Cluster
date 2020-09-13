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

That's all! You now have a fully gitops enable Kubernetes cluster!
