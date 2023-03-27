param actionGroupName string
@minLength(1)
@maxLength(12)
param actionGroupShortName string
param tags object = {}

var actionGroupEmail = 'christopherl@stcu.org'

resource supportTeamActionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: actionGroupName
  location: 'global'
  tags: tags
  properties: {
    enabled: true
    groupShortName: actionGroupShortName
    emailReceivers: [
      {
        name: actionGroupName
        emailAddress: actionGroupEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

output id string = supportTeamActionGroup.id
