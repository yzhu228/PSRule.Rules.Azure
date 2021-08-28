# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for module cmdlets
#

[CmdletBinding()]
param ()

BeforeAll {
    # Setup error handling
    $ErrorActionPreference = 'Stop';
    Set-StrictMode -Version latest;

    if ($Env:SYSTEM_DEBUG -eq 'true') {
        $VerbosePreference = 'Continue';
    }

    # Setup tests paths
    $rootPath = $PWD;
    Import-Module (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Rules.Azure) -Force;
    $outputPath = Join-Path -Path $rootPath -ChildPath out/tests/PSRule.Rules.Azure.Tests/Cmdlet;
    Remove-Item -Path $outputPath -Force -Recurse -Confirm:$False -ErrorAction Ignore;
    $Null = New-Item -Path $outputPath -ItemType Directory -Force;
    $here = (Resolve-Path $PSScriptRoot).Path;

    #region Mocks

    function MockContext {
        process {
            return @(
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000001'
                            Name = 'Test subscription 1'
                            State = 'Enabled'
                        }
                        Tenant = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000001'
                        }
                    }
                )),
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000002'
                            Name = 'Test subscription 2'
                            State = 'Enabled'
                        }
                        Tenant = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000002'
                        }
                    }
                ))
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000003'
                            Name = 'Test subscription 3'
                            State = 'Enabled'
                        }
                        Tenant = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000002'
                        }
                    }
                ))
            )
        }
    }

    function MockSingleSubscription {
        process {
            return @(
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000001'
                            Name = 'Test subscription 1'
                            State = 'Enabled'
                        }
                        Tenant = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000001'
                        }
                    }
                ))
            )
        }
    }

#endregion Mocks
}

#region Export-AzRuleData

Describe 'Export-AzRuleData' -Tag 'Cmdlet','Export-AzRuleData' {
    Context 'With defaults' {
        BeforeAll {
            Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith ${function:MockContext};
            Mock -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name = 'Resource1'
                        ResourceType = ''
                    }
                    [PSCustomObject]@{
                        Name = 'Resource2'
                        ResourceType = ''
                    }
                )
            }
        }

        It 'Exports resources' {
            $result = @(Export-AzRuleData -OutputPath $outputPath);

            Assert-VerifiableMock;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 3;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $False
            }
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 0 -ParameterFilter {
                $ListAvailable -eq $True
            }
            $result.Length | Should -Be 3;
            $result | Should -BeOfType System.IO.FileInfo;

            # Check exported data
            $data = Get-Content -Path $result[0].FullName | ConvertFrom-Json;
            $data -is [System.Array] | Should -Be $True;
            $data.Length | Should -Be 2;
            $data.Name | Should -BeIn 'Resource1', 'Resource2';
        }

        It 'Return resources' {
            $result = @(Export-AzRuleData -PassThru);
            $result.Length | Should -Be 6;
            $result | Should -BeOfType PSCustomObject;
            $result.Name | Should -BeIn 'Resource1', 'Resource2';
        }
    }

    Context 'With filters' {
        BeforeAll {
            Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -MockWith ${function:MockContext};
            Mock -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name = 'Resource1'
                        ResourceGroupName = 'rg-test-1'
                        ResourceType = ''
                    }
                    [PSCustomObject]@{
                        Name = 'Resource2'
                        ResourceGroupName = 'rg-test-2'
                        ResourceType = ''
                    }
                )
            }
        }

        It '-Subscription with name filter' {
            $Null = Export-AzRuleData -Subscription 'Test subscription 1' -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 1;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $True
            }
        }

        It '-Subscription with Id filter' {
            $Null = Export-AzRuleData -Subscription '00000000-0000-0000-0000-000000000002' -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 1;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $True
            }
        }

        It '-Tenant filter' {
            $Null = Export-AzRuleData -Tenant '00000000-0000-0000-0000-000000000002' -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 2;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $True
            }
        }

        It '-ResourceGroupName filter' {
            $result = @(Export-AzRuleData -Subscription 'Test subscription 1' -ResourceGroupName 'rg-test-2' -PassThru);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 1;
            $result[0].Name | Should -Be 'Resource2'
        }

        It '-Tag filter' {
            $Null = Export-AzRuleData -Subscription 'Test subscription 1' -Tag @{ environment = 'production' } -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $Tag.environment -eq 'production'
            }
        }
    }

    Context 'With data' {
        BeforeAll {
            Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -MockWith ${function:MockSingleSubscription};
        }

        It 'Microsoft.Network/connections' {
            Mock -CommandName 'Get-AzResourceGroup' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzSubscription' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name = 'Resource1'
                        ResourceType = 'Microsoft.Network/connections'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn001'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn001'
                        Properties = [PSCustomObject]@{ sharedKey = 'test123' }
                    }
                    [PSCustomObject]@{
                        Name = 'Resource2'
                        ResourceType = 'Microsoft.Network/connections'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn002'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn002'
                        Properties = [PSCustomObject]@{ dummy = 'value' }
                    }
                )
            }
            $result = @(Export-AzRuleData -OutputPath $outputPath -PassThru);
            $result.Length | Should -Be 2;
            $result[0].Properties.sharedKey | Should -Be '*** MASKED ***';
        }

        It 'Microsoft.Storage/storageAccounts' {
            Mock -CommandName 'Get-AzResourceGroup' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzSubscription' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'GetSubResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable;
            Mock -CommandName 'Get-AzResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name = 'Resource1'
                        ResourceType = 'Microsoft.Storage/storageAccounts'
                        Kind = 'StorageV2'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa001'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa001'
                    }
                    [PSCustomObject]@{
                        Name = 'Resource2'
                        ResourceType = 'Microsoft.Storage/storageAccounts'
                        Kind = 'FileServices'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa002'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa002'
                    }
                )
            }
            $Null = @(Export-AzRuleData -OutputPath $outputPath);
            Assert-MockCalled -CommandName 'GetSubResource' -ModuleName 'PSRule.Rules.Azure' -Times 1;
        }
    }
}

#endregion Export-AzRuleData

#region Export-AzRuleTemplateData

Describe 'Export-AzRuleTemplateData' -Tag 'Cmdlet','Export-AzRuleTemplateData' {
    BeforeAll {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
        $parametersPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
    }

    Context 'With defaults' {
        It 'Exports template' {
            $outputFile = Join-Path -Path $outputPath -ChildPath 'template-with-defaults.json'
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                OutputPath = $outputFile
            }
            $Null = Export-AzRuleTemplateData @exportParams;
            $result = Get-Content -Path $outputFile -Raw | ConvertFrom-Json;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].name | Should -Be 'vnet-001';
            $result[0].properties.addressSpace.addressPrefixes | Should -Be "10.1.0.0/24";
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[0].name | Should -Be 'GatewaySubnet';
            $result[0].properties.subnets[0].properties.addressPrefix | Should -Be '10.1.0.0/27';
            $result[0].properties.subnets[2].name | Should -Be 'subnet2';
            $result[0].properties.subnets[2].properties.addressPrefix | Should -Be '10.1.0.64/28';
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }

        It 'Returns file not found' {
            $exportParams = @{
                PassThru = $True
            }

            # Invalid template file
            $exportParams['TemplateFile'] = 'notafile.json';
            $exportParams['ParameterFile'] = $parametersPath;
            $errorOut = { $Null = Export-AzRuleTemplateData @exportParams -ErrorVariable exportErrors -ErrorAction SilentlyContinue; $exportErrors; } | Should -Throw -PassThru;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find the specified template file '*'.";

            # Invalid parameter file
            $exportParams['TemplateFile'] = $templatePath;
            $exportParams['ParameterFile'] = 'notafile.json';
            $errorOut = { $Null = Export-AzRuleTemplateData @exportParams -ErrorVariable exportErrors -ErrorAction SilentlyContinue; $exportErrors; } | Should -Throw -PassThru;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find the specified parameter file '*'.";
        }
    }

    Context 'With -PassThru' {
        It 'Exports template' {
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
            }
            $result = @(Export-AzRuleTemplateData @exportParams -PassThru);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].name | Should -Be 'vnet-001';
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[0].name | Should -Be 'GatewaySubnet';
            $result[0].properties.subnets[0].properties.addressPrefix | Should -Be '10.1.0.0/27';
            $result[0].properties.subnets[2].name | Should -Be 'subnet2';
            $result[0].properties.subnets[2].properties.addressPrefix | Should -Be '10.1.0.64/28';
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }
    }

    Context 'With -Subscription lookup' {
        It 'From context' {
            Mock -CommandName 'GetSubscription' -ModuleName 'PSRule.Rules.Azure' -MockWith {
                $result = [PSRule.Rules.Azure.Configuration.SubscriptionOption]::new();
                $result.SubscriptionId = '00000000-0000-0000-0000-000000000000';
                $result.TenantId = '00000000-0000-0000-0000-000000000000';
                $result.DisplayName = 'test-sub';
                return $result;
            }
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                Subscription = 'test-sub'
            }

            # With lookup
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
            $result[0].tags.role | Should -Match 'Networking';
        }
    }

    Context 'With -Subscription object' {
        It 'From hashtable' {
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                Subscription = @{
                    SubscriptionId = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn';
                    TenantId = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn';
                }
            }
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].tags.role | Should -Be 'Custom';
        }
    }

    Context 'With -ResourceGroup lookup' {
        It 'From context' {
            Mock -CommandName 'GetResourceGroup' -ModuleName 'PSRule.Rules.Azure' -MockWith {
                $result = [PSRule.Rules.Azure.Configuration.ResourceGroupOption]::new();
                $result.Name = 'test-rg';
                $result.Location = 'region'
                $result.ManagedBy = 'testuser'
                $result.Tags = @{
                    test = 'true'
                }
                return $result;
            }
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                ResourceGroup = 'test-rg'
            }

            # With lookup
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/test-rg/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/test-rg/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }
    }

    Context 'With -ResourceGroup object' {
        It 'From hashtable' {
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                ResourceGroup = @{
                    Location = 'custom';
                }
            }
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].location | Should -Be 'Custom';
        }
    }

    Context 'With Export-AzTemplateRuleData alias' {
        It 'Returns warning' {
            $outputFile = Join-Path -Path $outputPath -ChildPath 'template-with-defaults.json'
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                OutputPath = $outputFile
            }
            $Null = Export-AzTemplateRuleData @exportParams -WarningAction SilentlyContinue -WarningVariable warnings;
            $warningMessages = @($warnings);
            $warningMessages.Length | Should -Be 1;
        }
    }
}

#endregion Export-AzRuleTemplateData

#region Get-AzRuleTemplateLink

Describe 'Get-AzRuleTemplateLink' -Tag 'Cmdlet', 'Get-AzRuleTemplateLink' {
    BeforeAll {
        # Setup structure for scanning parameter files
        $templateScanPath = Join-Path -Path $outputPath -ChildPath 'templates/';
        $examplePath = Join-Path -Path $outputPath -ChildPath 'templates/example/';
        $Null = New-Item -Path $examplePath -ItemType Directory -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Parameters*.json') -Destination $templateScanPath -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Template*.json') -Destination $templateScanPath -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Parameters*.json') -Destination $examplePath -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Template*.json') -Destination $examplePath -Force;
    }

    Context 'With defaults' {
        It 'Exports template' {
            $getParams = @{
                Path = $templateScanPath
                InputPath = Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters*.json'
            }

            # Get files in specific path
            $result = @(Get-AzRuleTemplateLink @getParams);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 2;
            $result.ParameterFile | Should -BeIn @(
                (Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters.json')
                (Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters2.json')
            );
            @($result | Where-Object { $_.Metadata['additional'] -eq 'metadata' }).Length | Should -Be 1;

            # Get Resources.Parameters.json or Resources.Parameters2.json files in shallow path
            $result = @(Get-AzRuleTemplateLink -Path $templateScanPath -InputPath './Resources.Parameters?.json');
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 2;

            # Get Resources.Parameters.json or Resources.Parameters2.json files in recursive path
            $getParams['InputPath'] = 'Resources.Parameters*.json';
            $result = @(Get-AzRuleTemplateLink @getParams);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 4;

            # Get Resources.Parameters.json files in recursive path
            $result = @(Get-AzRuleTemplateLink -Path $templateScanPath -f '*.Parameters.json');
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 2;
            $result.ParameterFile | Should -BeIn @(
                (Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters.json')
                (Join-Path -Path $examplePath -ChildPath 'Resources.Parameters.json')
            );

            # Reads subscriptionParameters.json
            $result = @(Get-AzRuleTemplateLink -Path $here -InputPath './Resources.Subscription.Parameters.json');
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 1;
        }

        It 'Handles exceptions' {
            $getParams = @{
                InputPath = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail.json'
            }

            # Non-relative path
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find template referenced within parameter file '*'.";

            # File does not exist
            $getParams['InputPath'] = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail2.json';
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find template referenced within parameter file '*'.";

            # No metadata property
            $getParams['InputPath'] = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail3.json';
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "The parameter file '*' does not contain a metadata property.";

            # metadata.template property not set
            $getParams['InputPath'] = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail4.json';
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "The parameter file '*' does not reference a linked template.";
        }
    }
}

#endregion Get-AzRuleTemplateLink

#region PSRule.Rules.Azure.psm1 Private Functions

InModuleScope -ModuleName 'PSRule.Rules.Azure' {
    Describe 'VisitAKSCluster' {
        BeforeAll {
            $context = New-MockObject -Type Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext;

            Mock -CommandName 'GetResourceById' -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name = 'Resource1'
                        ResourceID = 'subnetId1'
                    }
                    [PSCustomObject]@{
                        Name = 'Resource2'
                        ResourceID = 'subnetId2'
                    }
                )
            };
        }

        Context 'Network Plugin' {
            It 'Given AzureCNI plugin it returns resource with VNET subnet IDs attached as sub resource' {
                $resource = [PSCustomObject]@{
                    Properties = [PSCustomObject]@{
                        agentPoolProfiles = @(
                            [PSCustomObject]@{
                                name = 'agentpool1'
                                vnetSubnetId = 'subnetId1'
                            }
                            [PSCustomObject]@{
                                name = 'agentpool2'
                                vnetSubnetId = 'subnetId2'
                            }
                        )
                        networkProfile = [PSCustomObject]@{
                            networkPlugin = 'azure'
                        }
                    }
                };

                $clusterResource = $resource | VisitAKSCluster -Context $context;
                $clusterResource.resources | Should -Not -BeNullOrEmpty;

                Assert-MockCalled -CommandName 'GetResourceById' -Times 2;

                $clusterResource.resources[0].Name| Should -BeExactly 'Resource1';
                $clusterResource.resources[0].ResourceID | Should -BeExactly 'subnetId1';

                $clusterResource.resources[1].Name| Should -BeExactly 'Resource2';
                $clusterResource.resources[1].ResourceID | Should -BeExactly 'subnetId2';
            }

            It 'Given kubelet plugin it returns resource with empty sub resource' {
                $resource = [PSCustomObject]@{
                    Properties = [PSCustomObject]@{
                        agentPoolProfiles = @(
                            [PSCustomObject]@{
                                name = 'agentpool1'
                            }
                            [PSCustomObject]@{
                                name = 'agentpool2'
                            }
                        )
                        networkProfile = [PSCustomObject]@{
                            networkPlugin = 'kubelet'
                        }
                    }
                };

                $clusterResource = $resource | VisitAKSCluster -Context $context;
                $clusterResource.resources | Should -BeNullOrEmpty;

                Assert-MockCalled -CommandName 'GetResourceById' -Times 0;
            }
        }
    }
}

#endregion