# Develop Data Extraction Powerhouse using Azure Data Factory and Azure AI Services

Learn and build an Azure lab for AI: Document Intelligence document processing using Azure Data Factory data flows.  

## DETAILS

### IAC TEMPLATES

The 'adf-maindeploy.bicep' template assumes that you are a US regulated entity with requirements for network isolation, access control, and least privilege security controls. For deployment to be successful, please ensure the following pre-requisites:

  + The AI: Document Intelligence, key vault, logic app, and storage account should be deployed in the same Azure US Government region.
  + Template assumes the following resources exist in the subscription prior to deployment. Please provide the resource IDs for the following resources:
    + Log Analytics Workspace
    + Event Hub
    + Key Vault with Private Endpoint
    + Storage Blob with Private Endpoint
    + Azure SQL DB with Private Endpoint
    + AI: Document Intelligence with Private Endpoint
    + Key Vault Private DNS Zone
    + AI Private DNS Zone
    + Storage Account Blob Private DNS Zone
    + Azure SQL Private DNS Zone  

  + Template assumes a virtual network already exists and is linked to the private DNS Zones.
  + The subnet ID parameter must pertain to the linked virtual network for each private DNS zone.
  + Ensure a secret with the SQL database connection string is created in the key vault prior to template deployment. 

### MANAGED IDENTITIES

The Azure Data Factory resource must have the following role assignments configured:
  + Storage Blob Data Contributor at the storage account resource scope
  + Key Vault Secret User at the key vault scope. 
