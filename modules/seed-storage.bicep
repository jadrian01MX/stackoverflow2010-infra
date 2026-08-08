targetScope = 'resourceGroup'

@description('Globally unique name for the storage account')
param storageAccountName string

@description('Azure region for the storage account')
param location string = resourceGroup().location

@description('Tags applied to the storage account')
param tags object = {}

@description('Object ID of the GitHub Actions service principal')
param githubActionsPrincipalId string

var seedContainerName = 'database-seed'

var storageBlobDataReaderRoleName = 'Storage Blob Data Reader'

var storageBlobDataReaderRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    changeFeed: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 30
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 30
    }
    isVersioningEnabled: true
  }
}

resource seedContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: seedContainerName
  properties: {
    publicAccess: 'None'
  }
}

resource blobDataReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    storageAccount.id,
    githubActionsPrincipalId,
    storageBlobDataReaderRoleName
  )
  scope: storageAccount
  properties: {
    principalId: githubActionsPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataReaderRoleId
  }
}

output storageAccountName string = storageAccount.name
output seedContainerName string = seedContainer.name
