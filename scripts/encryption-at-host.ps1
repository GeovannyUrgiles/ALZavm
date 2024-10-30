azure

Register-AzProviderFeature -FeatureName "EncryptionAtHost" -ProviderNamespace "Microsoft.Compute"

New-AzRoleAssignment -ApplicationId "c56384d7-d782-4ecd-8e9c-9a9f79161b41" -Scope "/" -RoleDefinitionName "Owner"