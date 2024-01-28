param adfName string


resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing= {
  name: adfName
}

resource managedVNET 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: 'default'
  parent: adf
  properties: {}
}
