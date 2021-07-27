# **Terraform**
Proyecto para aprovisionar recursos en azure con terraform.
### Comandos necesarios para crear los recursos con terraform.
#### **Paso 1:** Hacer login con el cli de azure (`az login`) o bien crear un `service principal` y exportar los siguientes valores correspondientes a su cuenta de azure.
```
export AZURE_SUBSCRIPTION_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export AZURE_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export AZURE_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export AZURE_TENANT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
#### **Paso 2 (Opcional):** Crear un [storage account](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage) para guardar el backend de terraform en azure y exportar los siguientes valores.
```
export RG_NAME=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export AZURE_STORAGE_ACCOUNT_NAME=xxxxxxxxxxxxxxxxxxxxxxxx
export AZURE_CONTAINER_NAME=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export AZURE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export AZURE_STORAGE_ACCOUNT_KEY=xxxxxxxxxxxxxxxxxxxxxxxxx
```
#### **Paso 3 (Opción 1):** Inicializar terraform para que se conecte con la cuenta de azure correspondiente usando las credenciales del `az login` y sin definir ningun backend (El backend se guarda localmente en el directorio donde se cuentra el `main.tf`).
```
terraform init
```
#### **Paso 3 (Opción 2  - Recomendada):** Inicializar terraform para que se conecte con la cuenta de azure correspondiente usando un `service principal` y utilizando un `storage account` para guardar la configuracion del backend.
```
terraform init \
-var "service_principal_subscription_id=${AZURE_SUBSCRIPTION_ID}" \
-var "service_principal_client_id=${AZURE_CLIENT_ID}" \
-var "service_principal_client_secret=${AZURE_CLIENT_SECRET}" \
-var "service_principal_tenant_id=${AZURE_TENANT_ID}" \
-backend-config "resource_group_name=${RG_NAME}" \
-backend-config "storage_account_name=${AZURE_STORAGE_ACCOUNT_NAME}" \
-backend-config "container_name=${AZURE_CONTAINER_NAME}" \
-backend-config "key=${AZURE_KEY}" \
-backend-config "access_key=${AZURE_STORAGE_ACCOUNT_KEY}"
```
#### **Paso 4:** Validar la sintaxis de los archivos tf.
```
terraform validate
```
#### **Paso 5:** Ejecutar el plan de terraform
```
terraform plan
```
#### **Paso 6:** Aplicar el plan para crear la infraestructura
```
terraform apply
```

# Información adicional

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>2.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.60.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cosmosdb"></a> [cosmosdb](#module\_cosmosdb) | git::https://github.com/kvncont/azure-terraform-modules.git//modules/services/cosmosdb | v0.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg_terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Shared variables | `string` | `"Central US"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(string)` | <pre>{<br>  "created_by": "terraform",<br>  "env": "dev"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cosmosdb_endpoint"></a> [cosmosdb\_endpoint](#output\_cosmosdb\_endpoint) | CosmosDB endpoint |
