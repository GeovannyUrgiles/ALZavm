# Introduction

The purpose of this Azure DevOps (ADO) deployment is to install Azure resources for a modern data platform for CSU consisiting of Fabric based Data and Analytics infrastructure. Due to CSU internal security requirements, there is a prerequisite key vault that should be deployed ahead of time that contains a KEK Customer Managed Key to encrypt all data at rest.

The Infrastructure as Code (IaC) is organized into a consistent-across-all-environments manner, with all environment specific identifiers and network and any other required settings.

Unique to each environment is a .yml file (pipeline) and a .bicepparam file containing all the relevant BICEP parameters and variables.

It is recommended that the ADO deployment service principal have Owner permission to execute a deployment. Once succesfully deployed, the permissions for the service principal can be rolled back to a lesser role, like Contributor or Reader.

In the non-prod environments, there are two Windows 11 jumpboxes that should not be required in production and are not part of the deployment codebase. These VMs were to circumvent the required DNS integration with VPN and on-prem.

# Getting Started

Before you deploy there are a few housekeeping items that will need to be completed.

In the Azure Portal you will need to create two resources:

1. Resource Group. Create the Resource Group that will house the Deployment in the destination subscription.
2. Key Vault. It is recommended that a Key Vault matching the name in the (env).bicepparam be deployed manually ahead of time. It should contain a Customer Managed Key whose naming follows the format of the lower environments.  It will also need to contain the Entra service account used for the Framework UI to communicate with the Azure SQL Database.
3.	
4.	

You'll also likely want to edit any YAML and/or BICEP files associated with your particular IaC deployment.

# Build and Test
To build the environment, visit https://dev.azure.com/csu-ado and choose the Modern Data Platform project. In the graphical menu on the left, choose Pipelines (blue icon of a rocket).

# Post Deployment
1.  Peer the Virtual Network to the to Hub/Core Virtual Network in the Connectivity Subscription. A peering transit enabled will need to be established.

