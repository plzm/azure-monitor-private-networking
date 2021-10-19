# ##################################################
# VARIABLES

[string] $tenantId = $null
[string] $subscriptionId = $null

[string[]] $azureRegions = @("eastus2", "westus2")

[string] $resourceGroupNameInfixNet = "poc-net"
[string] $resourceGroupNameInfixAzMon = "poc-azmon"

# ##################################################

# Set Azure CLI to auto install extensions
az config set extension.use_dynamic_install=yes_without_prompt
az config set extension.run_after_dynamic_install=$true

# ##################################################

# Dot-source the functions
. .\Functions.ps1

# ##################################################

# Get tenant and/or subscription from context if they were not otherwise specified
if (!$tenantId -or !$subscriptionId) {
  $azureAccount = Get-AzureAccount

  if (!$tenantId) {$tenantId = $azureAccount.tenantId}
  if (!$subscriptionId) {$subscriptionId = $azureAccount.id}
}

# ##################################################

$azureRegions | ForEach-Object {
  $azureRegion = $_

  # Networking Resource Group
  [string] $rgName = "${resourceGroupNameInfixNet}-${azureRegion}"

  az group delete --subscription $subscriptionId -n $rgName --yes --verbose

  # Monitoring Resource Group
  [string] $rgName = "${resourceGroupNameInfixAzMon}-${azureRegion}"

  az group delete --subscription $subscriptionId -n $rgName --yes --verbose
}
