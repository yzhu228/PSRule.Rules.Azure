# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Database for MariaDB
#

#region Rules

# Synopsis: Azure Database for MariaDB should store backups in a geo-redundant storage.
Rule 'Azure.MariaDB.GeoRedundantBackup' -Ref 'AZR-000329' -Type 'Microsoft.DBforMariaDB/servers' -If { HasMariaDBTierSupportingGeoRedundantBackup } -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.storageProfile.geoRedundantBackup', 'Enabled').
    Reason($LocalizedData.MariaDBGeoRedundantBackupNotConfigured, $PSRule.TargetName)
}

# Synopsis: Enable Microsoft Defender for Cloud for Azure Database for MariaDB.
Rule 'Azure.MariaDB.DefenderCloud' -Ref 'AZR-000330' -Type 'Microsoft.DBforMariaDB/servers', 'Microsoft.DBforMariaDB/servers/securityAlertPolicies' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers') {
        $defenderConfigs = @(GetSubResources -ResourceType 'Microsoft.DBforMariaDB/servers/securityAlertPolicies')
        if ($defenderConfigs.Length -eq 0) {
            $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.DBforMariaDB/servers/securityAlertPolicies')
        }
        foreach ($defenderConfig in $defenderConfigs) {
            $Assert.HasFieldValue($defenderConfig, 'properties.state', 'Enabled').
            PathPrefix('resources')
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers/securityAlertPolicies') {
        $Assert.HasFieldValue($TargetObject, 'properties.state', 'Enabled')
    }
}

#endregion Rules

#region Helper functions

function global:HasMariaDBTierSupportingGeoRedundantBackup {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $Assert.in($TargetObject, 'sku.tier', @('GeneralPurpose', 'MemoryOptimized')).Result
    }
}

#endregion Helper functions
