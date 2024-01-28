param adfName string

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing= {
  name: adfName
}

resource selfhostedIR 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  parent: adf
  name: 'selfhostedRuntimeADT'
  properties: {
    type: 'SelfHosted'
  }
}
