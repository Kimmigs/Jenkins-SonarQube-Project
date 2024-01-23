

3--install.sh



4--
terraform init, terraform plan, terraform apply -auto-approve

=============================================================================================================================================================================================================================
Refer---https://archive.eksworkshop.com/intermediate/290_argocd/install/
Refer--https://github.com/aws-samples/eks-workshop/issues/734
[B] Create AWS EKS Cluster
1--Install kubectl on Jenkins Server
 sudo apt update
 sudo apt install curl
 curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
 sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
 kubectl version --client

2--Install AWS Cli

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws --version

3--Installing  eksctl

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
cd /tmp
sudo mv /tmp/eksctl /bin
eksctl version

4--Setup Kubernetes using eksctl
eksctl create cluster --name virtualtechbox-cluster \
--region ap-south-1 \
--node-type t2.small \
--nodes 3 \

5-- Verify Cluster with below command
$ kubectl get nodes
=============================================================================================================================================================================================================================
[C] Setup Monitoring for Kubernetes using Helm, Prometheus and Grafana Dashboard
1 ) Install Helm Chart
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

2 )
helm repo add stable https://charts.helm.sh/stable                    //add the Helm Stable Charts for your local client

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts                      //Add Prometheus Helm repo

kubectl create namespace prometheus                    //Create Prometheus namespace

helm install stable prometheus-community/kube-prometheus-stack -n prometheus              //Install Prometheus

kubectl get pods -n prometheus       //check whether Prometheus is installed or not 

kubectl get svc -n prometheus        //check the services file (svc) of the Prometheus

//Grafana will be coming along with Prometheus as the stable version

3 ) let’s expose Prometheus to the external world

kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus                 //change it from Cluster IP to LoadBalancer.change port & targetport to 9090, save and close

kubectl get svc -n prometheus    //copy dns name of LB and browse with 9090

4 ) let’s change the SVC file of the Grafana and expose it to the outer world

kubectl edit svc stable-grafana -n prometheus            //change it from Cluster IP to LoadBalancer

kubectl get svc -n prometheus         //copy dns name of LB and browse

kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo           //use this command to get the password. the user name is admin

5) Import dashboard - 15760 - Load - Select Prometheus  & Click Import. 
6) Import dashboard - 12740 - Load - Select Prometheus  & Click Import. 
=============================================================================================================================================================================================================================
Refer---https://argo-cd.readthedocs.io/en/stable/cli_installation/
[D] ArgoCD Installation on Kubernetes Cluster and Add EKS Cluster to ArgoCD
1 ) First, create a namespace
    $ kubectl create namespace argocd

2 ) Next, let's apply the yaml configuration files for ArgoCd
    $ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

3 ) Now we can view the pods created in the ArgoCD namespace.
    $ kubectl get pods -n argocd

4 ) To interact with the API Server we need to deploy the CLI:
    $ sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
    $ sudo chmod +x /usr/local/bin/argocd
      
5 ) Expose argocd-server
    $ kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

6 ) Wait about 2 minutes for the LoadBalancer creation
    $ kubectl get svc -n argocd

7 ) Get pasword and decode it and login to ArgoCD on Browser. Go to user info and change the password
    $ kubectl get secret argocd-initial-admin-secret -n argocd -o yaml
    $ echo WXVpLUg2LWxoWjRkSHFmSA== | base64 --decode

8 ) login to ArgoCD from CLI
    $ argocd login a2255bb2bb33f438d9addf8840d294c5-785887595.ap-south-1.elb.amazonaws.com --username admin,    provide the password which you set above

9 ) Check available clusters in ArgoCD
     $ argocd cluster list

10 ) Below command will show the EKS cluster details
     $ kubectl config get-contexts

11 ) Add above EKS cluster to ArgoCD with below command
     $ argocd cluster add i-08b9d0ff0409f48e7@virtualtechbox-cluster.ap-south-1.eksctl.io --name virtualtechbox-eks-cluster
     
12 ) Now if you give command "$ argocd cluster list" you will get both the clusters EKS & AgoCD(in-cluster). This can be verified at ArgoCD Dashboard.
=============================================================================================================================================================================================================================
[E] Verify the CI/CD Pipeline
git config --global user.name "Ashfaque.Shaikh"
git config --global user.email "ashfaque.s510@gmail.com"
git clone https://github.com/Ashfaque-9x/a-reddit-clone.git
=============================================================================================================================================================================================================================
[F] Cleanup

1--Delete namespace prometheus & argocd
$ kubectl delete namespace prometheus  and $ kubectl delete namespace argocd
2--Delete EKS Cluster
$ eksctl delete cluster virtualtechbox-cluster --region ap-south-1     OR    eksctl delete cluster --region=ap-south-1 --name=virtualtechbox-cluster
3--Delete EC2 Instance with below Terraform Command
terraform destroy