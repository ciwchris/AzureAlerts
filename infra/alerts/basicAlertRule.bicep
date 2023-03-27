param location string = resourceGroup().location
param tags object = {}
@description('The Action Group to send the alert to')
param actionGroupId string
@description('The App Insights instance to use')
param appInsightsId string

// https://en.wikipedia.org/wiki/ISO_8601#Durations
var evaluationFrequency = 'PT15M'
var windowSize = 'PT15M'
// 0-4: Critical, Error, Warning, Information, Verbose. Default 3/Information
var severity = 3

resource rule 'Microsoft.Insights/scheduledQueryRules@2022-08-01-preview' = {
  name: 'Test alert'
  location: location
  tags: tags
  properties: {
    description: 'A test alert'
    evaluationFrequency: evaluationFrequency
    severity: severity
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          query: '''
exceptions
| where cloud_RoleName == "notifications-publisher"
  and operation_Name endswith "Orchestrator"
  and operation_Name !in ("CreateMemberEventOrchestrator")
          '''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroupId
      ]
    }
    scopes: [
      appInsightsId
    ]
  }
}
