$moduleName = $env:BHProjectName

Describe "FullModuleTemplate Help tests for $moduleName" -Tags Build {

    BeforeAll {
        Unload-SUT
        Import-Module ($global:SUTPath)
    }

    AfterAll {
        Unload-SUT
    }

    $functions = Get-Command -Module $moduleName
    $help = $functions | % {Get-Help $_.name}
    foreach ($node in $help)
    {
        Context $node.name {

            it "has a description" {
                $node.description | Should Not BeNullOrEmpty
            }
            it "has an example" {
                $node.examples | Should Not BeNullOrEmpty
            }
            foreach ($parameter in $node.parameters.parameter)
            {
                if ($parameter -notmatch 'whatif|confirm')
                {
                    it "parameter $($parameter.name) has a description" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}

Describe "AutoDocumentsExample Help tests for $moduleName" -Tags Build {
    
    $functions = Get-Command -Module $moduleName -CommandType Function
    foreach($Function in $Functions){
        $help = Get-Help $Function.name
        Context $help.name {
            it "Has a HelpUri" {
                $Function.HelpUri | Should Not BeNullOrEmpty
            }
            It "Has related Links" {
                $help.relatedLinks.navigationLink.uri.count | Should BeGreaterThan 0
            }
            it "Has a description" {
                $help.description | Should Not BeNullOrEmpty
            }
            it "Has an example" {
                 $help.examples | Should Not BeNullOrEmpty
            }
            foreach($parameter in $help.parameters.parameter)
            {
                if($parameter -notmatch 'whatif|confirm')
                {
                    it "Has a Parameter description for '$($parameter.name)'" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}