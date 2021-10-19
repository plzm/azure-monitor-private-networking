# ##################################################
# PARAMETERS

param
(
)

# ##################################################
# VARIABLES

[string] $tenantId = $null
[string] $subscriptionId = $null
[string[]] $azureRegions = @("eastus2", "westus2")

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

# Monitoring Resources

[string] $resourceGroupNameInfix = "poc-azmon"
[string] $logAnalyticsWorkspaceNameInfix = "la"
[string] $appInsightsNameInfix = "appi"
[int] $appInsightsResourcesPerRegion = 2
[string] $publicIngest = "Enabled"
[string] $publicQuery = "Enabled"

$azMonResources = .\Deploy-Monitor.ps1 `
  -tenantId $tenantId `
  -subscriptionId $subscriptionId `
  -azureRegions $azureRegions `
  -resourceGroupNameInfix $resourceGroupNameInfix `
  -logAnalyticsWorkspaceNameInfix $logAnalyticsWorkspaceNameInfix `
  -appInsightsNameInfix $appInsightsNameInfix `
  -appInsightsResourcesPerRegion $appInsightsResourcesPerRegion `
  -publicIngest $publicIngest `
  -publicQuery $publicQuery

Write-Host $azMonResources

# ##################################################

## Networking

#[int] $vnetPrefix = 11
#[int] $numOfVnetsPerRegion = 2
#[int] $numOfSubnetsPerVnet = 2
#[string] $vnetSuffix = "0.0.0/16"
#[string] $subnetSuffix = "0/24"
#[string] $privateEndpointNetworkPolicies = "Enabled"
#[string] $privateLinkServiceNetworkPolicies = "Enabled"
#[string] $nsgRuleInbound100Src = "75.68.47.183"

#$azureRegions | ForEach-Object {
#  $azureRegion = $_

#  $workspaceId = $azureRegionWorkspaces[$azureRegion]

#  # Resource Group
#  [string] $rgName = "poc-net-${azureRegion}"

#  az group create --subscription $subscriptionId -l $azureRegion -n $rgName --verbose

#  # NSG
#  [string] $nsgName = "nsg-${azureRegion}"

#  New-Nsg `
#  -subscriptionId $subscriptionId `
#  -resourceGroupName $rgName `
#  -location $azureRegion `
#  -nsgName $nsgName `
#  -nsgRuleInbound100Src $nsgRuleInbound100Src

#  New-NsgDiagnostics `
#  -subscriptionId $subscriptionId `
#  -resourceGroupName $rgName `
#  -nsgName $nsgName `
#  -logAnalyticsWorkspaceResourceId $workspaceId

#  For ($i = 1; $i -le $numOfVnetsPerRegion; $i++) {
#    $vnetName = "vnet-${azureRegion}-${vnetPrefix}"

#    New-VNet `
#    -subscriptionId $subscriptionId `
#    -resourceGroupName $rgName `
#    -location $azureRegion `
#    -vnetName $vnetName `
#    -vnetPrefix "${vnetPrefix}.${vnetSuffix}"
  
#    New-VNetDiagnostics `
#    -subscriptionId $subscriptionId `
#    -resourceGroupName $rgName `
#    -vnetName $vnetName `
#    -logAnalyticsWorkspaceResourceId $workspaceId

#    For ($i = 1; $i -le $numOfSubnetsPerVnet; $i++) {
#      $subnetName = "subnet${i}"
#      $subnetPrefix = "${vnetPrefix}.0.${i}.${subnetSuffix}"

#      New-Subnet `
#      -subscriptionId $subscriptionId `
#      -resourceGroupName $rgName `
#      -vnetName $vnetName `
#      -subnetName $subnetName `
#      -subnetPrefix $subnetPrefix `
#      -nsgResourceGroup $rgName `
#      -nsgName $nsgName `
#      -serviceEndpoints $null `
#      -delegationService $null `
#      -privateEndpointNetworkPolicies $privateEndpointNetworkPolicies `
#      -privateLinkServiceNetworkPolicies $privateLinkServiceNetworkPolicies
#    }

#    $vnetPrefix++
#  }
#}
