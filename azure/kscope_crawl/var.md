## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Client ID of service principal to be used for creating resources | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Client secret of service principal to be used for creating resources | `string` | n/a | yes |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | Location of the resource group | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | ID of Subcsription where resources are to be created | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | ID Tenant of where resources are to be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | client id to be used for Kaleidoscope data crawl configuration |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | client secret to be used for Kaleidoscope data crawl configuration |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription ID to be used for Kaleidoscope data crawl configuration |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Tenant ID to be used for Kaleidoscope data crawl configuration |
| <a name="output_owner_object_id"></a> [owner\_object\_id](#output\_owner\_object\_id) | Owner Object Id |
| <a name="output_storageAccountKey"></a> [storageAccountKey](#output\_storageAccountKey) | Storage Account Key to be used for Kaleidoscope event crawl configuration |
| <a name="output_storageAccountName"></a> [storageAccountName](#output\_storageAccountName) | Storage Account Name to be used for Kaleidoscope event crawl configuration |
| <a name="output_storageContainerName"></a> [storageContainerName](#output\_storageContainerName) | Storage Account Name to be used for Kaleidoscope event crawl configuration |
| <a name="output_storageQueueName"></a> [storageQueueName](#output\_storageQueueName) | Storage Queue Name to be used for Kaleidoscope event crawl configuration |
