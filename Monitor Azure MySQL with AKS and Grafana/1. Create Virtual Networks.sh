location="East US"
resourceGroup="my-demo-rg"
tag="demo"
vNet1="kubernetes-vnet"
vNet1addressPrefix="10.0.0.0/16"
vNet1subnetNode="kubernetes-node-subnet"
vNet1subnetNodePrefix="10.0.0.0/22"
vNet1subnetPod="kubernetes-pod-subnet"
vNet1subnetPodPrefix="10.0.8.0/21"

vNet2="mysql-vnet"
vNet2addressPrefix="10.1.0.0/16"
vNet2subnet="mysql-subnet"
vNet2subnetPrefix="10.1.0.0/24"

echo "Creating $resourceGroup in $location..."
az group create --name $resourceGroup --location "$location" --tags $tag

# Create a virtual network and a subnet for kubernetes cluster.
echo "Creating $vNet1 and $vNet1subnet"
az network vnet create --resource-group $resourceGroup --name $vNet1 --address-prefix $vNet1addressPrefix  --location "$location"
az network vnet subnet create -g $resourceGroup --vnet-name $vNet1 --name $vNet1subnetNode --address-prefixes $vNet1subnetNodePrefix -o none 
az network vnet subnet create -g $resourceGroup --vnet-name $vNet1 --name $vNet1subnetPod --address-prefixes $vNet1subnetPodPrefix -o none 

# Create a virtual network and a subnet for mysql cluster.
echo "Creating $vNet2 and $vNet2subnet"
az network vnet create --resource-group $resourceGroup --name $vNet2 --address-prefix $vNet2addressPrefix  --location "$location" --subnet-name $vNet2subnet --subnet-prefix $vNet2subnetPrefix

# Get the ID of VNet1
echo "Getting the id for $vNet1"
VNet1Id=$(az network vnet show --resource-group $resourceGroup --name $vNet1 --query id --out tsv)

#Get the ID of VNet2
echo "Getting the id for $vNet2"
VNet2Id=$(az network vnet show --resource-group $resourceGroup --name $vNet2 --query id --out tsv)

# Peer VNet1 to VNet2.
echo "Peering $vNet1 to $vNet2"
az network vnet peering create --name "Link"$vNet1"To"$vNet2 --resource-group $resourceGroup --vnet-name $vNet1 --remote-vnet $VNet2Id --allow-vnet-access

# Peer VNet2 to VNet1.
echo "Peering $vNet2 to $vNet1"
az network vnet peering create --name "Link"$vNet2"To"$vNet1 --resource-group $resourceGroup --vnet-name $vNet2 --remote-vnet $VNet1Id --allow-vnet-access
