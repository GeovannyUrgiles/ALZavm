param systemAssignedIdentityPrincipalId string

// RBAC Role Definition Id
var kvSecretsUserRoleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'

// Give User Assigned Managed Identity Owner on the Resource Group
resource RoleAssignment_SAMI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(systemAssignedIdentityPrincipalId, kvSecretsUserRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: systemAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', kvSecretsUserRoleDefinitionId)
  }
  dependsOn: [
  ]
}
