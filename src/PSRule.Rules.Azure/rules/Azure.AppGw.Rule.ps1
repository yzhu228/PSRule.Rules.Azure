# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Application Gateway
#

#region Application Gateway

# Synopsis: Application Gateways should only expose frontend HTTP endpoints over HTTPS.
Rule 'Azure.AppGw.UseHTTPS' -Ref 'AZR-000059' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.ASB.v3/control' = 'DP-3' } {
    $listeners = @($TargetObject.properties.httpListeners | Where-Object { $_.properties.protocol -eq 'http' });
    $requestRoutingRules = @($TargetObject.properties.requestRoutingRules);
    if ($listeners.Length -eq 0 -or $requestRoutingRules.Length -eq 0) {
        return $Assert.Pass();
    }
    for ($i = 0; $i -lt $requestRoutingRules.Length; $i++) {
        $requestRoutingRule = $requestRoutingRules[$i];
        $path = "properties.requestRoutingRules[$i]";
        $listener = $listeners | Where-Object { $_.name -eq $requestRoutingRule.properties.httpListener.id.Split('/')[-1] };
        if ($Null -eq $listener) {
            $Assert.Pass();
        }
        else {
            $Assert.HasFieldValue($requestRoutingRule, 'properties.redirectConfiguration.id').PathPrefix($path);
        }
    }
}

# Synopsis: Application gateways deployed with should use availability zones in supported regions for high availability.
Rule 'Azure.AppGw.AvailabilityZone' -Ref 'AZR-000060' -With 'Azure.IsAppGwV2Sku' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $appGatewayProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Network', 'applicationGateways');

    $configurationZoneMappings = $Configuration.AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $appGatewayProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $Assert.HasFieldValue($TargetObject, 'zones').
        ReasonFrom('zones', $LocalizedData.AppGWAvailabilityZone, $TargetObject.name, $TargetObject.Location, ($availabilityZones -join ', '));

} -Configure @{ AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

#endregion Application Gateway
