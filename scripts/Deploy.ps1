# ##################################################
# PARAMETERS

param
(
)

# ##################################################
# VARIABLES

[string] $tenantId = $null
[string] $subscriptionId = $null

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

# General

[string[]] $locations = @("eastus2", "westus2")

# ##################################################

# Monitoring Resources

[string] $publicIngest = "Enabled"
[string] $publicQuery = "Enabled"
[string[]] $appISuffixes = @("1", "2" )

$locationWorkspaces = @{}

$locations | ForEach-Object {
  $location = $_

  # Resource Group
  [string] $rgName = "poc-azmon-${location}"
  az group create --subscription $subscriptionId -l $location -n $rgName --verbose

  # Log Analytics Workspace and Diagnostics
  [string] $workspaceName = "la-${location}"

  New-LogAnalyticsWorkspace `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -location $location `
  -workspaceName $workspaceName `
  -publicNetworkAccessForIngest $publicIngest `
  -publicNetworkAccessForQuery $publicQuery

  $workspaceId = (az monitor log-analytics workspace show --subscription $subscriptionId -g $rgName -n $workspaceName -o tsv --query 'id')

  $locationWorkspaces.Add($location, $workspaceId)

  New-LogAnalyticsWorkspaceDiagnostics `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -workspaceName $workspaceName `
  -logAnalyticsWorkspaceResourceId $workspaceId

  # App Insights Instances
  $appISuffixes | ForEach-Object {
    [string] $appIName = "appi-${location}-${_}"

    New-AppInsights `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -location $location `
    -appInsightsName $appIName `
    -logAnalyticsWorkspaceResourceId $workspaceId `
    -publicNetworkAccessForIngest $publicIngest `
    -publicNetworkAccessForQuery $publicQuery
  
    New-AppInsightsDiagnostics `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -appInsightsName $appIName `
    -logAnalyticsWorkspaceResourceId $workspaceId
  }
}

# ##################################################

# Networking

[int] $vnetPrefix = 11
[int] $numOfVnetsPerRegion = 2
[int] $numOfSubnetsPerVnet = 2
[string] $vnetSuffix = "0.0.0/16"
[string] $subnetSuffix = "0/24"
[string] $privateEndpointNetworkPolicies = "Enabled"
[string] $privateLinkServiceNetworkPolicies = "Enabled"
[string] $nsgRuleInbound100Src = "75.68.47.183"

$locations | ForEach-Object {
  $location = $_

  $workspaceId = $locationWorkspaces[$location]

  # Resource Group
  [string] $rgName = "poc-net-${location}"

  az group create --subscription $subscriptionId -l $location -n $rgName --verbose

  # NSG
  [string] $nsgName = "nsg-${location}"

  New-Nsg `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -location $location `
  -nsgName $nsgName `
  -nsgRuleInbound100Src $nsgRuleInbound100Src

  New-NsgDiagnostics `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -nsgName $nsgName `
  -logAnalyticsWorkspaceResourceId $workspaceId

  For ($i = 1; $i -le $numOfVnetsPerRegion; $i++) {
    $vnetName = "vnet-${location}-${vnetPrefix}"

    New-VNet `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -location $location `
    -vnetName $vnetName `
    -vnetPrefix "${vnetPrefix}.${vnetSuffix}"
  
    New-VNetDiagnostics `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -vnetName $vnetName `
    -logAnalyticsWorkspaceResourceId $workspaceId

    For ($i = 1; $i -le $numOfSubnetsPerVnet; $i++) {
      $subnetName = "subnet${i}"
      $subnetPrefix = "${vnetPrefix}.0.${i}.${subnetSuffix}"

      New-Subnet `
      -subscriptionId $subscriptionId `
      -resourceGroupName $rgName `
      -vnetName $vnetName `
      -subnetName $subnetName `
      -subnetPrefix $subnetPrefix `
      -nsgResourceGroup $rgName `
      -nsgName $nsgName `
      -serviceEndpoints $null `
      -delegationService $null `
      -privateEndpointNetworkPolicies $privateEndpointNetworkPolicies `
      -privateLinkServiceNetworkPolicies $privateLinkServiceNetworkPolicies
    }

    $vnetPrefix++
  }
}