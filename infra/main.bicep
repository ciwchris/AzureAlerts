targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module applicationInsights './app/applicationInsights.bicep' = {
  name: 'applicationInsights'
  scope: rg
  params: {
    location: location
    tags: tags
    name: 'appi-${resourceToken}'
  }
}

module alertRuleGroup './app/alertRuleGroup.bicep' = {
  name: 'alertRuleGroup'
  scope: rg
  params: {
    tags: tags
    actionGroupName: 'member-events-team-alerts'
    actionGroupShortName: 'MEP'
  }
}

module basicAlert './alerts/basicAlertRule.bicep' = {
  name: 'basicAlert'
  scope: rg
  params: {
    location: location
    tags: tags
    actionGroupId: alertRuleGroup.outputs.id
    appInsightsId: applicationInsights.outputs.id
  }
}
