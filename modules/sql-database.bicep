@description('Azure SQL Database name')
param databaseName string

@description('Azure SQL logical server name')
param sqlServerName string

@description('Azure region')
param location string = resourceGroup().location

@description('Database SKU name')
param skuName string = 'Free'

@description('Maximum database size in GB')
param maxSizeGb int = 32

@description('Database collation')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Tags applied to the database')
param tags object = {}


resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}


resource sqlDatabase 'Microsoft.Sql/servers/databases@2025-01-01' = {

  parent: sqlServer

  name: databaseName

  location: location

  tags: tags

  sku: {
    name: skuName
  }

  properties: {

    maxSizeBytes: maxSizeGb * 1024 * 1024 * 1024

    collation: collation

    zoneRedundant: false

    readScale: 'Disabled'

  }
}


output databaseId string = sqlDatabase.id

output databaseName string = sqlDatabase.name
