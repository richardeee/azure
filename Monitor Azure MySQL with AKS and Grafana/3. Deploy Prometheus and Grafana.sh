resourceGroup="my-demo-rg"
clusterName="myAKSCluster"

subscriptionId = $(az account show --query "id" --output tsv)

az aks get-credentials --resource-group $resourceGroup --name $clusterName

helm repo add stable https://charts.helm.sh/stable

kubectl create ns monitoring

helm install prometheus stable/prometheus-operator --namespace monitoring
