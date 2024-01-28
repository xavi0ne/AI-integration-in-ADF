param adfDetails array = [
  {
    adfName: <adfResourceName>
    adfResourceGroup: <rgName>
    adfPrivateEndpointIP: <staticPrivateIP>
    dfPrivateEndpointIP: <staticPrivateIP>
    subnetID: <subnetID>
  }
]
param location string = <region-for-usgov>
param financialtag string = <tagvalue>

param subscriptionId string = <usgov sub Id>
param DNSZoneresourceGroup string = <rgName-where-DNSZones-reside>

//adfUpdate Params
param AzureKeyVault1_properties_typeProperties_baseUrl string = 'https://<keyVaultName>.vault.usgovcloudapi.net/'
param AzureBlobStorage1_properties_typeProperties_serviceEndpoint string = 'https://<storageName>.blob.core.usgovcloudapi.net/'
param AzureSqlDatabase1_properties_typeProperties_connectionString_secretName string = '<secretName of sql connectionString>'
param CognitiveService651_properties_privateLinkResourceId string = '/subscriptions/<subscriptionId>/resourceGroups/<rgName-where-AI-service-resides>/providers/Microsoft.CognitiveServices/accounts/<AI-serviceName>'
param CognitiveService651_properties_groupId string = 'account'
param CognitiveService651_properties_fqdns array = [
  '<AI-ServiceName>.cognitiveservices.azure.us'
]
param AzureSqlDatabase920_properties_privateLinkResourceId string = '/subscriptions/<subscriptionId>/resourceGroups/rgName-where-sqlsvc-resides>/providers/Microsoft.Sql/servers/<AzureSQLName>'
param AzureSqlDatabase920_properties_groupId string = 'sqlServer'
param AzureSqlDatabase920_properties_fqdns array = [
  '<AzureSQLName>.database.usgovcloudapi.net'
]
param trigger1_properties_typeProperties_scope string = '/subscriptions/<subscriptionId>/resourceGroups/rgName-where-storage-resides>/providers/Microsoft.Storage/storageAccounts/<storageName>'


//adf maindeploy Vars
var dataFactoryPrivateDnsZoneID = '/subscriptions/${subscriptionId}/resourceGroups/${DNSZoneresourceGroup}/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.us'
var adfPrivateDnsZoneID = '/subscriptions/${subscriptionId}/resourceGroups/${DNSZoneresourceGroup}/providers/Microsoft.Network/privateDnsZones/privatelink.adf.azure.us'
var logAnalyitcsID = '/subscriptions/<subscriptionId>/resourcegroups/<rgName>/providers/microsoft.operationalinsights/workspaces/<logAnalyticsWorkspaceName>'
var eventHubID = '/subscriptions/<subscriptionId>/resourceGroups/<rgName>/providers/Microsoft.EventHub/namespaces/<eventHubName>/authorizationRules/RootManageSharedAccessKey'
var eventHub = '<eventHubName>'

module dataFactory 'module-adf.bicep' = [ for (adf, i) in adfDetails: {
  name: 'DeployADF${i}'
  scope: resourceGroup(adf.adfResourceGroup)
  params: {
    adfDetails: adf
    adfPrivateDnsZoneID: adfPrivateDnsZoneID
    dataFactoryPrivateDnsZoneID: dataFactoryPrivateDnsZoneID
    eventHub: eventHub
    eventHubID: eventHubID
    financialtag: financialtag
    location: location
    logAnalyitcsID: logAnalyitcsID
  }
}]

module SHIR 'IntegrationRuntimes/module-adfSelfHostedIR.bicep' = [ for (adf, i) in adfDetails: {
  name: 'DeploySHIR${i}'
  scope: resourceGroup(adf.adfResourceGroup)
  params: {
    adfName: adf.adfName
  }
  dependsOn: [
    dataFactory
  ]
}]

module managedVNET 'IntegrationRuntimes/module-managedVNET.bicep' = [ for (adf, i) in adfDetails: {
  name: 'deployManagedVNET${i}'
  scope: resourceGroup(adf.adfResourceGroup)
  params: {
    adfName: adf.adfName
  }
  dependsOn: [
    dataFactory
  ]
}]

module AZIR 'IntegrationRuntimes/module-AzureIR.bicep' = [ for (adf, i) in adfDetails: {
  name: 'deployAZIR${i}'
  scope: resourceGroup(adf.adfResourceGroup)
  params: {
    adfName: adf.adfName
    location: location
  }
  dependsOn: [
    dataFactory, managedVNET
  ]
}]

//adfManualExportUpdatedTemplate
module adfTEST_svc_ArmTemplate_0 'adfUpdates/ArmTemplate_0.json' = [ for (adf, i) in adfDetails: {
  name: 'adfTEST-svc_ArmTemplate_0${i}'
  scope: resourceGroup(adf.adfResourceGroup)
  params: {
    factoryName: adf.adfName
    AzureKeyVault1_properties_typeProperties_baseUrl: AzureKeyVault1_properties_typeProperties_baseUrl
    CognitiveService651_properties_privateLinkResourceId: CognitiveService651_properties_privateLinkResourceId
    CognitiveService651_properties_groupId: CognitiveService651_properties_groupId
    CognitiveService651_properties_fqdns: CognitiveService651_properties_fqdns
    AzureSqlDatabase920_properties_privateLinkResourceId: AzureSqlDatabase920_properties_privateLinkResourceId
    AzureSqlDatabase920_properties_groupId: AzureSqlDatabase920_properties_groupId
    AzureSqlDatabase920_properties_fqdns: AzureSqlDatabase920_properties_fqdns
    AzureBlobStorage1_properties_typeProperties_serviceEndpoint: AzureBlobStorage1_properties_typeProperties_serviceEndpoint
    AzureSqlDatabase1_properties_typeProperties_connectionString_secretName: AzureSqlDatabase1_properties_typeProperties_connectionString_secretName
    trigger1_properties_typeProperties_scope: trigger1_properties_typeProperties_scope
  }
  dependsOn: [
    dataFactory, managedVNET, AZIR
  ]
}]
