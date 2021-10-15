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

# Monitoring Resources

[string[]] $locations = @("eastus2", "westus2")
[string] $publicIngest = "Enabled"
[string] $publicQuery = "Enabled"
[string[]] $appISuffixes = @("1", "2" )

$locations | ForEach-Object {
  $location = $_

  # Resource Group
  [string] $rgName = "azmon-${location}"
  az group create --subscription $subscriptionId -l $location -n $rgName --verbose

  # Log Analytics Workspace and Diagnostics
  [string] $workspaceName = "la-${location}"

  New-LogAnalyticsWorkspace `
  -deploymentName $workspaceName `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -location $location `
  -workspaceName $workspaceName `
  -publicNetworkAccessForIngest $publicIngest `
  -publicNetworkAccessForQuery $publicQuery

  $workspaceId = (az monitor log-analytics workspace show --subscription $subscriptionId -g $rgName -n $workspaceName -o tsv --query 'id')

  New-LogAnalyticsWorkspaceDiagnostics `
  -deploymentName "${workspaceName}-diag" `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -workspaceName $workspaceName `
  -logAnalyticsWorkspaceResourceId $workspaceId

  # App Insights Instances
  $appISuffixes | ForEach-Object {
    [string] $appIName = "appi-${location}-${_}"

    New-AppInsights `
    -deploymentName $appIName `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -location $location `
    -appInsightsName $appIName `
    -logAnalyticsWorkspaceResourceId $workspaceId `
    -publicNetworkAccessForIngest $publicIngest `
    -publicNetworkAccessForQuery $publicQuery
  
    New-AppInsightsDiagnostics `
    -deploymentName "${appIName}-diag" `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -appInsightsName $appIName `
    -logAnalyticsWorkspaceResourceId $workspaceId
  }
}


