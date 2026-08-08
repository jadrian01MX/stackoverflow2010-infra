targetScope = 'subscription'

@description('Azure region where resources will be deployed')
param location string = 'mexicocentral'

@description('Environment name')
param environment string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-stackoverflow2010-${environment}-${location}'
  location: location
}
