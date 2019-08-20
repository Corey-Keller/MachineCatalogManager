$script:ModuleName = $env:BHProjectName
$moduleRoot = $env:BHModulePath

Describe "PSScriptAnalyzer rule-sets" -Tag Build {

    $rulesToExclude = @('PSUseToExportFieldsInManifest')
    $Rules = Get-ScriptAnalyzerRule | where RuleName -NotIn $rulesToExclude
    $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse | where fullname -notmatch 'classes'

    foreach ( $Script in $scripts )
    {
        Context "Script '$($script.FullName)'" {
            $results = Invoke-ScriptAnalyzer -Path $script.FullName -includeRule $Rules
            if ($results)
            {
                foreach ($rule in $results)
                {
                    It $rule.RuleName {
                        $message = "{0} Line {1}: {2}" -f $rule.Severity, $rule.Line, $rule.message
                        $message | Should Be ""
                    }

                }
            }
            else
            {
                It "Should not fail any rules" {
                    $results | Should BeNullOrEmpty
                }
            }
        }
    }
}


Describe "General project validation FullModuleTemplate: $moduleName" -Tags Build {

    AfterAll {
        Unload-SUT
    }

    It "Module '$moduleName' can import cleanly" {
        {Import-Module ($global:SUTPath) -force } | Should Not Throw
    }
}

$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Describe "General project validation: $moduleName" -Tags Build, Unit {
    
    It "Module '$moduleName' can import cleanly" {
        { Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
    }
}