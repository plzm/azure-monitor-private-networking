function Get-AzureAccount {
  $azureAccount = (az account show) | ConvertFrom-Json

  return $azureAccount
}

function New-LogAnalyticsWorkspace {
  param
  (
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
    -n $workspaceName `
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
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $workspaceName,
    [string] $logAnalyticsWorkspaceResourceId
  )

  Write-Host "New-LogAnalyticsWorkspaceDiagnostics"

  $templateFile = "..\templates\monitor.log-analytics-workspace.diagnostics.json"

  az deployment group create --verbose `
    -n "${workspaceName}-diag" `
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
    -n $appInsightsName `
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
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $appInsightsName,
    [string] $logAnalyticsWorkspaceResourceId
  )

  Write-Host "New-AppInsightsDiagnostics"

  $templateFile = "..\templates\monitor.app-insights.diagnostics.json"

  az deployment group create --verbose `
  -n "${appInsightsName}-diag" `
  --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
    appInsightsName=$appInsightsName `
    logAnalyticsWorkspaceResourceId=$logAnalyticsWorkspaceResourceId
}

function New-VNet {
  param
  (
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $location,
    [string] $vnetName,
    [string] $vnetPrefix,
    [bool] $enableDdosProtection = $false,
    [string] $ddosProtectionPlanResourceGroup = $null,
    [string] $ddosProtectionPlanName = $null,
    [bool] $enableVmProtection = $false
  )

  Write-Host "New-VNet"

  $templateFile = "..\templates\net.vnet.json"

  az deployment group create --verbose `
    -n $vnetName `
    --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
      location=$location `
      vnetName=$vnetName `
      vnetPrefix=$vnetPrefix `
      enableDdosProtection=$enableDdosProtection `
      ddosProtectionPlanResourceGroup=$ddosProtectionPlanResourceGroup `
      ddosProtectionPlanName=$ddosProtectionPlanName `
      enableVmProtection=$enableVmProtection
}

function New-VNetDiagnostics {
  param
  (
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $vnetName,
    [string] $logAnalyticsWorkspaceResourceId
  )

  Write-Host "New-VNetDiagnostics"

  $templateFile = "..\templates\net.vnet.diagnostics.json"

  az deployment group create --verbose `
  -n "${vnetName}-diag" `
  --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
    vnetName=$vnetName `
    logAnalyticsWorkspaceResourceId=$logAnalyticsWorkspaceResourceId
}

function New-Subnet {
  param
  (
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $vnetName,
    [string] $subnetName,
    [string] $subnetPrefix,
    [string] $nsgResourceGroup = $null,
    [string] $nsgName = $null,
    [string] $serviceEndpoints = $null,
    [string] $delegationService = $null,
    [string] $privateEndpointNetworkPolicies = $null,
    [string] $privateLinkServiceNetworkPolicies = $null
  )

  Write-Host "New-Subnet"

  $templateFile = "..\templates\net.vnet.subnet.json"

  az deployment group create --verbose `
    -n $subnetName `
    --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
      vnetName=$vnetName `
      subnetName=$subnetName `
      subnetPrefix=$subnetPrefix `
      nsgResourceGroup=$nsgResourceGroup `
      nsgName=$nsgName `
      serviceEndpoints=$serviceEndpoints `
      delegationService=$delegationService `
      privateEndpointNetworkPolicies=$privateEndpointNetworkPolicies `
      privateLinkServiceNetworkPolicies=$privateLinkServiceNetworkPolicies
}

function New-Nsg {
  param
  (
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $location,
    [string] $nsgName,
    [string] $nsgRuleInbound100Src
  )

  Write-Host "New-Nsg"

  $templateFile = "..\templates\net.nsg.json"

  az deployment group create --verbose `
    -n $nsgName `
    --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
      location=$location `
      nsgName=$nsgName `
      nsgRuleInbound100Src=$nsgRuleInbound100Src
}

function New-NsgDiagnostics {
  param
  (
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $nsgName,
    [string] $logAnalyticsWorkspaceResourceId
  )

  Write-Host "New-NsgDiagnostics"

  $templateFile = "..\templates\net.nsg.diagnostics.json"

  az deployment group create --verbose `
  -n "${nsgName}-diag" `
  --subscription $subscriptionId `
	  -g $resourceGroupName `
    --template-file $templateFile `
	  --parameters `
    nsgName=$nsgName `
    logAnalyticsWorkspaceResourceId=$logAnalyticsWorkspaceResourceId
}
