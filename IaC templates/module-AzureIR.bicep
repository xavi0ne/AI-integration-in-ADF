param adfName string
param location string

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing= {
  name: adfName
}

resource AZIRName 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  parent: adf
  name: 'AzureIR'
  properties: {
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: location
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 8
          timeToLive: 10
          cleanup: false
          customProperties: []
        }
        pipelineExternalComputeScaleProperties: {
          timeToLive: 60
          numberOfExternalNodes: 1
          numberOfPipelineNodes: 1
        }
      }
    }
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
    }
  }
}
