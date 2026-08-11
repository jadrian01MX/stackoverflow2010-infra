targetScope = 'resourceGroup'

@description('Azure SQL Server name')
param sqlServerName string

@description('Microsoft Entra administrator login')
param entraAdminLogin string

@description('Microsoft Entra administrator object ID')
param entraAdminObjectId string

@description('Allow Azure services firewall rule')
param allowAzureServices bool = true

@description('Client public IP address')
param clientIpAddress string

@description('Public network access')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Minimum TLS version')
@allowed([
  '1.2'
  '1.3'
])
param minimalTlsVersion string = '1.2'

@description('Tags applied to all resources')
param tags object = {}


@description('Azure SQL database name')
param sqlDatabaseName string

@description('Azure Function App name')
param functionAppName string

@description('Storage account name used by Azure Functions')
param functionStorageAccountName string

@description('Application Insights name')
param applicationInsightsName string

module sqlServer './modules/sql-server.bicep' = {

  name: 'deploy-sql-server'

  params: {
    sqlServerName: sqlServerName

    entraAdminLogin: entraAdminLogin
    entraAdminObjectId: entraAdminObjectId

    allowAzureServices: allowAzureServices
    clientIpAddress: clientIpAddress

    publicNetworkAccess: publicNetworkAccess
    minimalTlsVersion: minimalTlsVersion

    tags: tags
  }
}
module functionApp './modules/function-app.bicep' = {
  name: 'deploy-function-app'

  params: {
    functionAppName: functionAppName
    functionStorageAccountName: functionStorageAccountName
    applicationInsightsName: applicationInsightsName
    tags: tags
  }
}
output sqlServerId string = sqlServer.outputs.sqlServerId

output sqlServerName string = sqlServer.outputs.sqlServerName

output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn
