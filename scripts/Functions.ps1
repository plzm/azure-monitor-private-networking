function Get-AzureAccount {
  $azureAccount = (az account show) | ConvertFrom-Json

  return $azureAccount
}

function New-LogAnalyticsWorkspace {
  param
  (
    [string] $deploymentName,
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $location,
    [string] $workspaceName,
    [string] $publicNetworkAccessForIngest,
    [string] $publicNetworkAccessForQuery
  )

  Write-Host "New-LogAnalyticsWorkspace"

  $templateFile = "..\templates\monitor.log-analytics-workspace.json"

  az deployment group create --verbose `
    -n $deploymentName `
    --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
      location=$location `
      workspaceName=$workspaceName `
      publicNetworkAccessForIngestion=$publicNetworkAccessForIngest `
      publicNetworkAccessForQuery=$publicNetworkAccessForQuery
}

function New-LogAnalyticsWorkspaceDiagnostics {
  param
  (
    [string] $deploymentName,
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $workspaceName,
    [string] $logAnalyticsWorkspaceResourceId
  )

  Write-Host "New-LogAnalyticsWorkspaceDiagnostics"

  $templateFile = "..\templates\monitor.log-analytics-workspace.diagnostics.json"

  az deployment group create --verbose `
    -n $deploymentName `
    --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
      workspaceName=$workspaceName `
      logAnalyticsWorkspaceResourceId=$logAnalyticsWorkspaceResourceId
}

function New-AppInsights {
  param
  (
    [string] $deploymentName,
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $location,
    [string] $appInsightsName,
    [string] $logAnalyticsWorkspaceResourceId,
    [string] $publicNetworkAccessForIngest,
    [string] $publicNetworkAccessForQuery
  )

  Write-Host "New-AppInsights"

  $templateFile = "..\templates\monitor.app-insights.json"

  az deployment group create --verbose `
    -n $deploymentName `
    --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
      location=$location `
      appInsightsName=$appInsightsName `
      logAnalyticsWorkspaceResourceId=$logAnalyticsWorkspaceResourceId `
      publicNetworkAccessForIngest=$publicNetworkAccessForIngest `
      publicNetworkAccessForQuery=$publicNetworkAccessForQuery
}

function New-AppInsightsDiagnostics {
  param
  (
    [string] $deploymentName,
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $appInsightsName,
    [string] $logAnalyticsWorkspaceResourceId
  )

  Write-Host "New-AppInsightsDiagnostics"

  $templateFile = "..\templates\monitor.app-insights.diagnostics.json"

  az deployment group create --verbose `
    -n $deploymentName `
    --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
    appInsightsName=$appInsightsName `
    logAnalyticsWorkspaceResourceId=$logAnalyticsWorkspaceResourceId
}
