# Set Azure Subscription
az account set -s aeda07d9-84a0-4974-b345-dfbe9df0dad4
 
# Create resource group
az group create -l eastus2 -n tflabgroup
 
# Create storage account
az storage account create -n tflabstate -g tflabgroup -l eastus2 --sku Standard_LRS --kind StorageV2
 
# Create blob container
az storage container create --account-name tflabstate --name remotetfstate