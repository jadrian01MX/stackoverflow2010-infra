@description('Azure Function App name')
param functionAppName string

@description('Storage account name used by Azure Functions')
param functionStorageAccountName string

@description('Application Insights name')
param applicationInsightsName string

@description('Tags applied to resources')
param tags object = {}

@description('Azure region')
param location string = resourceGroup().location

@description('Maximum number of Function App instances')
param maximumInstanceCount int = 10

@description('Memory allocated to each Function App instance in MB')
@allowed([
  2048
  4096
  8192
])
param instanceMemoryMB int = 2048


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: functionStorageAccountName
  location: location
  tags: tags

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'

  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource deploymentContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${storageAccount.name}/default/deployments'

  properties: {
    publicAccess: 'None'
  }
}


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags

  kind: 'web'

  properties: {
    Application_Type: 'web'
  }
}


resource functionPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: '${functionAppName}-plan'
  location: location
  tags: tags

  kind: 'functionapp'

  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
  }

  properties: {
    reserved: true
  }
}


resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: location
  tags: tags

  kind: 'functionapp,linux'

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: functionPlan.id

    httpsOnly: true

    siteConfig: {
      minTlsVersion: '1.2'

      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }

        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }

        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.name
        }

        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }

    functionAppConfig: {
      runtime: {
        name: 'dotnet-isolated'
        version: '10.0'
      }

      deployment: {
        storage: {
          type: 'blobContainer'

          value: '${storageAccount.properties.primaryEndpoints.blob}deployments'

          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }

      scaleAndConcurrency: {
        maximumInstanceCount: maximumInstanceCount
        instanceMemoryMB: instanceMemoryMB
      }
    }
  }

  dependsOn: [
    deploymentContainer
  ]
}


output functionAppId string = functionApp.id

output functionAppName string = functionApp.name

output functionAppPrincipalId string = functionApp.identity.principalId

output functionAppDefaultHostName string = functionApp.properties.defaultHostName

output functionStorageAccountName string = storageAccount.name

output applicationInsightsName string = applicationInsights.name
