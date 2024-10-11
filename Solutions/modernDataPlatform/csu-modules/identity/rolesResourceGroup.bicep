param devOpsServicePrincipalId string
param userAssignedIdentityPrincipalId string
param dataAdminGroupId string
param dataTeamGroupId string

// Owner RBAC Role Definition Id
var ownerRoleDefinitionId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var contribRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var keyVaultAdminRoleDefinitionId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'
var keyVaultCryptoRoleDefinitionId = 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
var keyVaultSecretsUserRoleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'
var storageBlobContributorRoleDefinitionId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageQueueContributorRoleDefinitionId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var storageContributorRoleDefinitionId = '17d1049b-9a84-46fb-8f53-869881c3d3ab'


// Give DevOps SP Crypto Reader on the Resource Group
resource RoleAssignment_SP_Crypto 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(devOpsServicePrincipalId, keyVaultCryptoRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: devOpsServicePrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultCryptoRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give UAMI Storage Blob Contributor on the Resource Group
resource RoleAssignment_UAMI_BlobContrib 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentityPrincipalId, storageBlobContributorRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: userAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobContributorRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give UAMI Storage Queue Contributor on the Resource Group
resource RoleAssignment_UAMI_QueueContrib 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentityPrincipalId, storageQueueContributorRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: userAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageQueueContributorRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give UAMI Storage Contributor on the Resource Group
resource RoleAssignment_UAMI_StorageContrib 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentityPrincipalId, storageContributorRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: userAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageContributorRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give UAMI Crypto Reader on the Resource Group
resource RoleAssignment_UAMI_Crypto 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentityPrincipalId, keyVaultCryptoRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: userAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultCryptoRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give DevOps SP Key Vault Admin on the Resource Group
resource RoleAssignment_SP_KV_Admin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(devOpsServicePrincipalId, keyVaultAdminRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: devOpsServicePrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdminRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give User Assigned Managed Identity Owner on the Resource Group
resource RoleAssignment_UAMI_Owner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentityPrincipalId, ownerRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: userAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', ownerRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give User Assigned Managed Identity Key Vault Admin on the Resource Group
resource RoleAssignment_UAMI_KV_Admin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentityPrincipalId, keyVaultAdminRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: userAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdminRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give Data Admins Owner on the Resource Group
resource RoleAssignment_DataAdmins 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dataAdminGroupId, ownerRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: dataAdminGroupId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', ownerRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give Data Admins Key Vault Admin on the Resource Group
resource RoleAssignment_DataAdmins_KV_Admin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dataAdminGroupId, keyVaultAdminRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: dataAdminGroupId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdminRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give Data Team Contributor on the Resource Group
resource RoleAssignment_DataTeam 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dataTeamGroupId, contribRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: dataTeamGroupId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contribRoleDefinitionId)
  }
  dependsOn: [
  ]
}

// Give Data Team Key Vault Secrets User on the Resource Group
resource RoleAssignment_DataTeam_Secrets_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dataTeamGroupId, keyVaultSecretsUserRoleDefinitionId, resourceGroup().id)
  properties: {
    principalId: dataTeamGroupId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleDefinitionId)
  }
  dependsOn: [
  ]
}
