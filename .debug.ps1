
Get-ChildItem -Path $PSScriptRoot -Directory |
    ForEach-Object { '{0}\{1}.psd1'-f $_.FullName, $_.Name } |
        Where-Object { Test-Path -Path $_ } |
            Import-Module -Verbose -Force

<# ------------------ PLACE DEBUG COMMANDS AFTER THIS LINE ------------------ #>

# Connect to the public demo portal
$url = 'https://web.demo.reportportal.io'
Connect-RPServer -Url $url -Credential 'default' -ProjectName 'default_personal' -Verbose


## Case 1: Errors

Launch 'Error Launch' {

    Suite 'Error Suite' {

        Test 'Error Test A' {

            Test 'Error Test B' {

                Step 'Error Step' {

                    throw 'Step Error'
                }

                throw 'Test B Error'
            }

            throw 'Test A Error'
        }

        throw 'Suite Error'
    }

    throw 'Launch Error'
}


## Case 2: Complex structure

Launch 'Complex Launch' {

    Suite 'Suite 1' {

        Test 'Test 1.1' {

            Step 'Step 1.1.1' {
                1 | Should -Be 1
            }

            Step 'Step 1.1.2' {
                1 | Should -Be 2
            }

            Step 'Step 1.1.3' -Skip {
                1 | Should -Be 1
            }

            Step 'Step 1.1.4' -Pending {
                1 | Should -Be 1
            }
        }

        Test 'Test 1.2' {

            $testCases = @(
                @{ Number = 1 }
                @{ Number = 2 }
                @{ Number = 3 }
            )

            Step 'Step 1.2.<Number>' -TestCases $testCases {
                param ($Number)
                $Number | Should -Be 2
            }
        }

        Test 'Test 1.3' {

            Test 'Test 1.3.1' {

                Step 'Step 1.3.1.1' {
                    1 | Should -Be 1
                }
            }
        }
    }

    foreach ($suite in 2..3)
    {
        Suite "Suite $suite" {

            Test "Test $suite.1" {

                Step "Step $suite.1.1" {
                    1 | Should -Be 1
                }
            }
        }
    }
}
