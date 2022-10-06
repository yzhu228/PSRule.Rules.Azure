# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

@{
    MinTLSVersion = "Minimum TLS version is set to {0}."
    ResourceNotTagged = "The resource is not tagged."
    TcpHealthProbe = "The health probe ({0}) is using TCP."
    RootHttpProbePath = "The health probe ({0}) is using '{1}'."
    AKSVersion = "The Kubernetes version is v{0}."
    AKSNodePoolType = "The agent pool ({0}) is not using scale sets."
    AKSNodePoolVersion = "The agent pool ({0}) is running v{1}."
    AKSAutoScaling = "The agent pool ({0}) is not using autoscaling."
    AKSAzureCNI = "The subnet ({0}) should be using a minimum size of /{1}."
    AKSAvailabilityZone = "The agent pool ({0}) deployed to region ({1}) should use following availability zones [{2}]."
    AKSAuditLogs = "The diagnostic setting ({0}) logs should enable at least one of (kube-audit, kube-audit-admin) and guard."
    AKSPlatformLogs = "The diagnostic setting ({0}) logs should enable ({1})."
    AKSEphemeralOSDiskNotConfigured = "The OS disk type 'Managed' should be of type 'Ephemeral'."
    SubnetNSGNotConfigured = "The subnet ({0}) has no NSG associated."
    ServiceUrlNotHttps = "The service URL for '{0}' is not a HTTPS endpoint."
    BackendUrlNotHttps = "The backend URL for '{0}' is not a HTTPS endpoint."
    ResourceNotAssociated = "The resource is not associated."
    EnabledEndpoints = "The number of enabled endpoints is {0}."
    AccessPolicyLeastPrivilege = "One or more access policies grant all or purge permission."
    DiagnosticSettingsNotConfigured = "Diagnostic settings are not configured."
    DiagnosticSettingsLoggingNotConfigured = "Diagnostic settings is not configured to log events for '{0}'."
    SecurityCenterNotConfigured = "Security Center is not configured."
    LateralTraversalNotRestricted = "A rule to limit lateral traversal was not found."
    AllInboundRestricted = "The first inbound rule denies traffic from all sources."
    APIMProductSubscription = "The product '{0}' does not require a subscription to use."
    APIMProductApproval = "The product '{0}' does not require approval."
    APIMProductTerms = "The product '{0}' does not have legal terms set."
    APIMCertificateExpiry = "The certificate for host name '{0}' expires or expired on '{1}'."
    APIMDescriptors = "The {0} '{1}' does not have a {2} set."
    APIMSecretNamedValues = "The named value '{0}' is not secret."
    APIMAvailabilityZone = "The API management service ({0}) deployed to region ({1}) should use a minimum of two availability zones from the following [{2}]."
    PublicAccessStorageContainer = "The container '{0}' is configured with access type '{1}'."
    RoleAssignmentCount = "The number of assignments is {0}."
    UnmanagedDisk = "The VM disk '{0}' is unmanaged."
    UnmanagedSubscription = "The subscription is not managed."
    DBServerFirewallRuleCount = "The number of firewall rules ({0}) exceeded {1}."
    DBServerFirewallPublicIPRange = "The number of public IP addresses permitted ({0}) exceeded {1}."
    TemplateParameterDescription = "The parameter '{0}' does not have a description set."
    ParameterNotFound = "The parameter '{0}' was not used within the template."
    VariableNotFound = "The variable '{0}' was not used within the template."
    AssessmentUnhealthy = "An assessment is reporting one or more issues."
    AssessmentNotFound = "The results for a valid assessment was not found."
    HealthProbeNotDedicated = "The health probe '{0}' used the default path '/'."
    ParameterTypeMismatch = "The {0} for '{1}' is not {2}."
    ParameterInvalidDefaultValue = "The default value for the parameter '{0}' is '{1}'."
    ExpressionInTemplate = "The expression '{0}' was found in the template."
    SubResourceNotFound = "A sub-resource of type '{0}' has not been specified."
    ParameterValueNotSet = "The parameter '{0}' must have a value or Key Vault reference set."
    AppGWAvailabilityZone = "The application gateway ({0}) deployed to region ({1}) should use following availability zones [{2}]."
    LBAvailabilityZone = "The load balancer ({0}) frontend IP configuration ({1}) should be zone-redundant."
    PublicIPAvailabilityZone = "The public IP ({0}) deployed to region ({1}) should be zone-redundant."
    VPNAvailabilityZoneSKU = "The VPN gateway ({0}) should be using one of the following AZ SKUs ({1})."
    ERAvailabilityZoneSKU = "The ExpressRoute gateway ({0}) should be using one of the following AZ SKUs ({1})."
    AutomationAccountDiagnosticSetting = "The diagnostic setting ({0}) should enable ({1}) or category group ({2})."
    AutomationAccountAuditDiagnosticSetting = "Minimum one diagnostic setting should have ({0}) configured or category group ({1}) configured."
    TemplateResourceWithoutComment = "The template ({0}) has ({1}) resource/s without comments."
    TemplateResourceWithoutDescription = "The template ({0}) has ({1}) resource/s without descriptions."
    PremiumRedisCacheAvailabilityZone = "The premium redis cache ({0}) deployed to region ({1}) should use a minimum of two availability zones from the following [{2}]."
    EnterpriseRedisCacheAvailabilityZone = "The enterprise redis cache ({0}) deployed to region ({1}) should be zone-redundant."
    AKSMinimumVersionReplace = "The configuration option 'Azure_AKSMinimumVersion' has been replaced with 'AZURE_AKS_CLUSTER_MINIMUM_VERSION'. The option 'Azure_AKSMinimumVersion' is deprecated and will no longer work in the next major version. Please update your configuration to the new name. See https://aka.ms/ps-rule-azure/upgrade."
    # DeprecatedSupportsTags = "The 'SupportsTags' PowerShell function has been replaced with the selector 'Azure.Resource.SupportsTags'. The 'SupportsTags' function is deprecated and will no longer work in the next major version. Please update your PowerShell rules to the selector instead. See https://aka.ms/ps-rule-azure/upgrade."
    KeyVaultAutoRotationPolicy = "The key ({0}) should enable a auto-rotation policy."
    ReplicaNotFound = "A replica was not found."
    ReplicaInSecondaryNotFound = "A replica in a secondary region was not found."
    VMSSPublicKey = "The virtual machine scale set '{0}' should have password authentication disabled."
    ACRSoftDeletePolicy = "The container registry '{0}' should have soft delete policy enabled."
    ACRSoftDeletePolicyRetention = "The container registry '{0}' should have retention period value between one to 90 days for the soft delete policy."
    AppConfigStoresDiagnosticSetting = "Minimum one diagnostic setting should have ({0}) configured or category group ({1}) configured."
    AppConfigPurgeProtection = "The app configuration store '{0}' should have purge protection enabled." 
    LiteralSensitiveProperty = "The property '{0}' uses a deterministic literal value."
}
