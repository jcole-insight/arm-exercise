New-AzResourceGroup -Name TestDeployGroup -Location "East US"
New-AzResourceGroupDeployment `
  -Name TestDeployment `
  -ResourceGroupName TestDeployGroup `
  -TemplateFile ./vmlab.json `
  -TemplateParameterFile ./vmlab_params.json