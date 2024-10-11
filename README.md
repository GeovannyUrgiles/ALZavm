# Introduction version .9.1.02
Azure BICEP Foundations Enterprise Deployment. This Neudesic deployment will lay down a Multi-Hub Azure VWAN with support for Primary and Secondary (BCDR) Spokes.

# Deployment
* To deploy via AZ CLI your deployment account MUST have Tenant Root privileges. Please run:
* New-AzRoleAssignment -ApplicationId "nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnn" -Scope "/" -RoleDefinitionName "Owner" 

# Key Features:
* Follows Neudesic CAF Standards
* VWAN based with support for Secure Hub configuration
* Well documented capabilities with editable technical illustrations (continual improvements)
* Consistent Private Endpoint subnet nnn.nnn.254.nnn/23 in every Vnet
* DNS Private Zone Groups pre-linked to Core VNet
* Key Vault in every Subscription
* Diagnostics Storage in each Subscription
* Automation Account in each Subscription
* Log Analytics Workspace available in each Subscription

The majority of individual resource settings can be modified in main.bicep!

# New Features
* Added Common 10 Solutions to Log Analytics Workspace
* Added linkage from Log Analytics to Automation Account in each subscription
* Availability Set based Domain Controller VM in each Core can be enabled/disabled via parameter value
* Preconfigured Subnets can be enabled/disabled via parameter value (excludes mandatory Private Endpoint Subnets)
* Firewall can be enabled/disabled via parameter value
* DNS Private Resolver can be enabled/disabled via parameter value
* Bastion in each Core can be enabled/disabled via parameter value
* S2S VPN Gateway in each Hub can be enabled/disabled via parameter value
* Recovery Services Vault in each Core can be enabled/disabled via parameter value
* On-Prem capable Azure DNS automatically enabled/configured (must choose either AZFW DNS Proxy or DNS Private Resolver. Requires Domain Controller option and AD Join to on-premise Active Directory)

# Still to do
* Integrate VM Admin and Domain Join credentials into Key Vault
* Boolean toggle allowing for Log Anaytics Workspace to be located either in each Spoke Sub or limit to each Core Sub
* Boolean toggle to enable/disable Automation Accounts in each Spoke Sub
* Boolean toggle to enable/disable Express Route Gateway in each Core Hub
* Need to remove some unused params
* Balance beween DNS Resolver and AZFW DNS Proxy needs review

# Build and Test
* TODO: Deployment Guide - general description of how and what to modify for deployment

# Notes
* DNS Resolver - NA in CUS and other regions while in Preview


# Contribute
Please pay close attention to naming conventions. Hyper-verbose parameter and variable naming is employed so as this deployment grows it will be easy to identify and make use of standard naming conventions.

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)
