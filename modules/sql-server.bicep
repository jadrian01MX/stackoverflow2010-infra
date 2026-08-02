@description('Azure SQL logical server name')
param sqlServerName string

@description('Azure region')
param location string = resourceGroup().location

@description('Microsoft Entra administrator display name')
param entraAdminLogin string

@description('Microsoft Entra administrator object ID')
param entraAdminObjectId string

@description('Tags applied to the SQL Server')
param tags object = {}

@description('Allow Azure services to access SQL Server')
param allowAzureServices bool = true

@description('Client public IP address')
param clientIpAddress string

@description('Public network access configuration')
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

@description('Firewall rule name for the client IP')
param clientFirewallRuleName string = 'AllowMyIP'

resource sqlServer 'Microsoft.Sql/servers@2025-01-01' = {
  name: sqlServerName
  location: location

  tags: tags

  properties: {
    version: '12.0'
    publicNetworkAccess: publicNetworkAccess
    minimalTlsVersion: minimalTlsVersion

    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: entraAdminLogin
      sid: entraAdminObjectId
      tenantId: tenant().tenantId
      azureADOnlyAuthentication: true
    }
  }
}

resource azureServicesFirewallRule 'Microsoft.Sql/servers/firewallRules@2025-01-01' = if (allowAzureServices) {
  name: 'AllowAzureServices'
  parent: sqlServer

  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource clientFirewallRule 'Microsoft.Sql/servers/firewallRules@2025-01-01' = {
  name: clientFirewallRuleName
  parent: sqlServer

  properties: {
    startIpAddress: clientIpAddress
    endIpAddress: clientIpAddress
  }
}

output sqlServerId string = sqlServer.id

output sqlServerName string = sqlServer.name

output sqlServerLocation string = sqlServer.location

output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

output sqlServerResourceGroup string = resourceGroup().name
