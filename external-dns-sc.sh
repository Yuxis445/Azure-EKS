# ExternalDNS needs permissions to make changes in Azure Private DNS. These permissions are roles assigned to the service principal used by ExternalDNS.

# A service principal with a minimum access level of Private DNS Zone Contributor to the Private DNS zone(s) and Reader to the resource group containing the Azure Private DNS zone(s) is necessary. More powerful role-assignments like Owner or assignments on subscription-level work too.

$ az ad sp create-for-rbac --skip-assignment -n http://externaldns-sp
{
  "appId": "appId GUID",  <-- aadClientId value
  ...
  "password": "password",  <-- aadClientSecret value
  "tenant": "AzureAD Tenant Id"  <-- tenantId value
}