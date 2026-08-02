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

@description('Azure SQL Database name')
param databaseName string

@description('Azure SQL Database SKU')
param skuName string = 'GP_S_Gen5_2'

@description('Maximum database size in GB')
param maxSizeGb int = 128

@description('Tags applied to all resources')
param tags object = {}


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


module sqlDatabase './modules/sql-database.bicep' = {

  name: 'deploy-sql-database'

  params: {

    databaseName: databaseName

    sqlServerName: sqlServer.outputs.sqlServerName

    skuName: skuName

    maxSizeGb: maxSizeGb

    tags: tags
  }
}


output sqlServerId string = sqlServer.outputs.sqlServerId

output sqlServerName string = sqlServer.outputs.sqlServerName

output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn


output sqlDatabaseId string = sqlDatabase.outputs.databaseId

output sqlDatabaseName string = sqlDatabase.outputs.databaseName
