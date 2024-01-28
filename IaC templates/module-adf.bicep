param adfDetails object 
param location string
param financialtag string 
param adfPrivateDnsZoneID string
param dataFactoryPrivateDnsZoneID string
param logAnalyitcsID string
param eventHubID string
param eventHub string


resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: adfDetails.adfName
  location: location
  tags: {
    financial: financialtag
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource adfDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adf
  name: '${adfDetails.adfName}-ds'
  properties: {
    workspaceId: logAnalyitcsID
    eventHubAuthorizationRuleId: eventHubID
    eventHubName: eventHub
    logs: [
      {
        category: 'ActivityRuns'
        enabled: true
      }
      {
        category: 'PipelineRuns'
        enabled: true
      }
      {
        category: 'TriggerRuns'
        enabled: true
      }
      {
        category: 'SSISPackageEventMessages'
        enabled: true
      }
      {
        category: 'SSISIntegrationRuntimeLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource dfprivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${adfDetails.adfName}-df-sv'
  location: location
  tags: {
    financial: financialtag
  }
  properties: {
    subnet: {
      id: adfDetails.subnetID
    }
    privateLinkServiceConnections: [
      {
        name: '${adfDetails.adfName}-df-sv'
        properties: {
          privateLinkServiceId: resourceId(resourceGroup().name, 'Microsoft.DataFactory/factories', '${adfDetails.adfName}')
          groupIds: [
            'dataFactory'
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: '${adfDetails.adfName}-df-sv'
        properties: {
        
          groupId: 'dataFactory'
        
          memberName: 'dataFactory'
          
          privateIPAddress: adfDetails.dfPrivateEndpointIP
        }
      }  
    ]
  }
  dependsOn: [
    adf
  ]
}

resource dfpvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${adfDetails.adfName}-df-sv/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: dataFactoryPrivateDnsZoneID
        }
      }
    ]
  }
  dependsOn: [
    dfprivateEndpoint
  ]
}

resource adfprivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${adfDetails.adfName}-adf-sv'
  location: location
  tags: {
    financial: financialtag
  }
  properties: {
    subnet: {
      id: adfDetails.subnetID
    }
    privateLinkServiceConnections: [
      {
        name: '${adfDetails.adfName}-adf-sv'
        properties: {
          privateLinkServiceId: resourceId(resourceGroup().name, 'Microsoft.DataFactory/factories', '${adfDetails.adfName}')
          groupIds: [
            'portal'
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: '${adfDetails.adfName}-adf-sv'
        properties: {
        
          groupId: 'portal'
        
          memberName: 'portal'
          
          privateIPAddress: adfDetails.adfPrivateEndpointIP
        }
      }  
    ]
  }
  dependsOn: [
    adf
  ]
}

resource adfpvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${adfDetails.adfName}-adf-sv/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: adfPrivateDnsZoneID
        }
      }
    ]
  }
  dependsOn: [
    adfprivateEndpoint
  ]
}
