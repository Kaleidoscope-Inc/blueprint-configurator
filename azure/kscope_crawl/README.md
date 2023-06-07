## Usage of this module

This Terraform script defines infrastructure as code to deploy an Azure Active Directory (AD) application and outputs some information about the created resources.

The script uses the `azurerm` and `azuread` providers to interact with Azure resources, which are defined in the `required_providers` block at the top.

The `azurerm_subscription` and `azurerm_client_config` data sources are used to retrieve information about the current subscription and the client configuration, respectively.

The `random_string` resource generates a random string that will be used as the client secret for the Azure AD application.

The `azuread_application` resource creates an Azure AD application with a display name of "kaleidoscope-blueprint" and assigns an owner based on the `object_id` of the current client configuration. It also specifies a required resource access to a specific scope.

Finally, the script uses `output` blocks to print the values of the following resources:

- `azuread_application.example.application_id`: The client ID of the created Azure AD application.
- `random_string.client_secret.result`: The generated client secret for the Azure AD application.
- `data.azurerm_subscription.current.subscription_id`: The ID of the current Azure subscription.
- `data.azurerm_client_config.current.tenant_id`: The ID of the Azure AD tenant associated with the current subscription.
- `data.azurerm_client_config.current.object_id`: The object ID of the owner of the Azure AD application.
