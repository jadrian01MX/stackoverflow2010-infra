targetScope = 'subscription'

@description('Azure region for the shared seed-data resources')
param location string = 'mexicocentral'

@description('Tags applied to all shared resources')
param tags object = {
  workload: 'stackoverflow2010'
  lifecycle: 'shared'
}

var resourceGroupName = 'rg-stackoverflow2010-shared-${location}'
// Storage account names must be globally unique, lowercase, and 3-24 characters.
var storageAccountName = 'stso2010${uniqueString(subscription().id)}'

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module seedStorage './modules/seed-storage.bicep' = {
  name: 'deploy-seed-storage'
  scope: sharedResourceGroup
  params: {
    location: location
    storageAccountName: storageAccountName
    tags: tags
  }
}

output sharedResourceGroupName string = sharedResourceGroup.name
output seedStorageAccountName string = seedStorage.outputs.storageAccountName
output seedContainerName string = seedStorage.outputs.seedContainerName
