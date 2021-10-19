# ##################################################
# PARAMETERS

param
(
  [Parameter(Mandatory = $true)]
  [string] $tenantId,
  [Parameter(Mandatory = $true)]
  [string] $subscriptionId,
  [Parameter(Mandatory = $true)]
  [string[]] $azureRegions,
  [Parameter(Mandatory = $true)]
  [string] $resourceGroupNameInfix,
  [Parameter(Mandatory = $true)]
  [string] $logAnalyticsWorkspaceNameInfix,
  [Parameter(Mandatory = $true)]
  [string] $appInsightsNameInfix,
  [Parameter(Mandatory = $true)]
  [int] $appInsightsResourcesPerRegion,
  [Parameter(Mandatory = $true)]
  [string] $publicIngest,
  [Parameter(Mandatory = $true)]
  [string] $publicQuery
  )

# ##################################################
# VARIABLES

class AzMonResources {
  $locationWorkspaces = @{}
  $locationAppInsights = @{}
}

$azMonResources = [AzMonResources]::new()

# ##################################################

# Set Azure CLI to auto install extensions
az config set extension.use_dynamic_install=yes_without_prompt
az config set extension.run_after_dynamic_install=$true

# ##################################################

# Dot-source the functions
. .\Functions.ps1

# ##################################################
# Resources

$azureRegions | ForEach-Object {
  $azureRegion = $_

  # Resource Group
  [string] $rgName = "${resourceGroupNameInfix}-${azureRegion}"
  az group create --subscription $subscriptionId -l $azureRegion -n $rgName --verbose

  # Log Analytics Workspace and Diagnostics
  [string] $workspaceName = "${logAnalyticsWorkspaceNameInfix}-${azureRegion}"

  New-LogAnalyticsWorkspace `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -location $azureRegion `
  -workspaceName $workspaceName `
  -publicNetworkAccessForIngest $publicIngest `
  -publicNetworkAccessForQuery $publicQuery

  $workspace = Get-LogAnalyticsWorkspace -subscriptionId $subscriptionId -resourceGroupName $rgName -workspaceName $workspaceName

  #$locationWorkspaces.Add($azureRegion, $workspace)
  $azMonResources.locationWorkspaces.Add($azureRegion, $workspace)

  New-LogAnalyticsWorkspaceDiagnostics `
  -subscriptionId $subscriptionId `
  -resourceGroupName $rgName `
  -workspaceName $workspaceName `
  -logAnalyticsWorkspaceResourceId $workspace.id

  # App Insights Instances
  For ($i = 1; $i -le $appInsightsResourcesPerRegion; $i++) {
    [string] $appIName = "${appInsightsNameInfix}-${azureRegion}-${i}"

    New-AppInsights `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -location $azureRegion `
    -appInsightsName $appIName `
    -logAnalyticsWorkspaceResourceId $workspaceId `
    -publicNetworkAccessForIngest $publicIngest `
    -publicNetworkAccessForQuery $publicQuery
  
    $appInsights = Get-AppInsights -subscriptionId $subscriptionId -resourceGroupName $rgName -appInsightsName $appIName

    #$locationAppInsights.Add($azureRegion, $appInsights)
    $azMonResources.locationAppInsights.Add($azureRegion, $appInsights)
  
    New-AppInsightsDiagnostics `
    -subscriptionId $subscriptionId `
    -resourceGroupName $rgName `
    -appInsightsName $appIName `
    -logAnalyticsWorkspaceResourceId $workspaceId
  }
}

# ##################################################

return $azMonResources
