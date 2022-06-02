location="East US"
resourceGroup="my-demo-rg"
clusterName="myAKSCluster"
vNet1="kubernetes-vnet"
dockerBridgeAddress="172.17.0.1/16"
serviceCidr="10.100.0.0/24"

vNet2="mysql-vnet"
mysqlName="demoMySQL"
privateDNS="testDNS.private.mysql.database.azure.com"

# Get kubernetes node subnet id
nodeSubnetId = $(az network vnet subnet list \
    --resource-group $resourceGroup \
    --vnet-name $vNet1 \
    --query "[0].id" --output tsv)
# Get kubernetes pod subnet id
podSubnetId = $(az network vnet subnet list \
    --resource-group $resourceGroup \
    --vnet-name $vNet1 \
    --query "[1].id" --output tsv)

# Create AKS Cluster
az aks create -n $clusterName -g $resourceGroup -l $location -n aksnodepool --max-pods 250 --node-count 3 --network-plugin azure --vnet-subnet-id $nodeSubnetId --pod-subnet-id $podSubnetId --docker-bridge-address $dockerBridgeAddress --service-cidr $serviceCidr --generate-ssh-keys


# Create private dns zone
az network private-dns zone create -g $resourceGroup -n $privateDNS

#Get VNet Id
vNet1Id = $(az network vnet list --resource-group $resourceGroup --query "[?contains(name,'$vNet1')].id" --output tsv)

# Link private dns zone to kubernetes vnet
az network private-dns link vnet create -g $resourceGroup -n privateDNSLink -z $privateDNS  -v $vNet1Id -e False

# Create MySQL Flexible Server

mysqlSubnetId = $(az network vnet subnet list --resource-group $resourceGroup --vnet-name $vNet2 --query "[0].id" --output tsv)

privateDNSZoneId = $(az network private-dns zone list -g $resourceGroup --query "[0].id" --output tsv)

# az mysql flexible-server create --resource-group $resourceGroup --name $mysqlName --location $location --subnet $mysqlSubnetId --private-dns-zone $privateDNSZoneId

az mysql flexible-server create --resource-group $resourceGroup --name $clusterName --vnet $vNet2 --subnet $mysqlSubnetId --location $location --private-dns-zone $privateDNSZoneId