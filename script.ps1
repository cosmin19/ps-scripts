#######################################
###
### USAGE: powershell.exe .\script.ps1 -env <ENVIRONMENT> -path <JSON_DATA_FILE_PATH> -target <DATA_FACTORY_SECTION_TARGET> [, <DATA_FACTGORY_SECTION_TARGET_NAME>]
###
### ENVIRONMENT: testing, production
### DATA_FACTORY_SECTION_TARGET: linkedservice, dataset, pipeline
### DATA_FACTGORY_SECTION_TARGET_NAME is optional. If not specified, all entities will be targeted
###
#######################################

# Read params
param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$env,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$path,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$target
)

# Global vars
$errorOccured = $false
$errorObj = $NULL

# Check if valid arguments
## Check environment
if(!$env -or !($env -eq 'testing') -and !($env -eq 'production')) {
    throw "Environment argument is invalid"
}

## Check data factory section targeted
if(!$target -or !($target[0] -eq 'linkedservice') -and !($target[0] -eq 'dataset') -and !($target[0] -eq 'pipeline')) {
    throw "Data Factory Section argument is invalid"
}
if($target.length -gt 2) {
    throw "Too many arguments for target param"
}
if($target.length -eq 2) {
    $targetEntity = $target[1]

    if(!$targetEntity) {
        throw "Target second argument is invalid"
    }
}

# Read data from jsonfile
try {
    # Read json
    $jsonData = Get-Content -Raw -Path $path -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    
    $jsonObject = $jsonData | where environment -eq $env
    if(!$jsonObject) {
        throw "Can't find json object for environment [$env]"
    }

    # Get firstname
    $firstname = $jsonObject.firstname
    if(!$firstname) {
        throw "Can't find json variable [firstname]"
    }

    # Get lastname
    $lastname = $jsonObject.lastname
    if(!$lastname) {
        throw "Can't find json variable [lastname]"
    }

    # Get linkedservicePath
    $linkedservicePath = $jsonObject.linkedservicePath
    if(!$linkedservicePath) {
        throw "Can't find json variable [linkedservicePath]"
    }

    # Get datasetPath
    $datasetPath = $jsonObject.datasetPath
    if(!$datasetPath) {
        throw "Can't find json variable [datasetPath]"
    }


    # Get pipelinePath
    $pipelinePath = $jsonObject.pipelinePath
    if(!$pipelinePath) {
        throw "Can't find json variable [pipelinePath]"
    }
}
catch {
    $errorOccured = $true
    $errorObj = $_
}
finally {
    if($errorOccured -eq $true){
        throw $errorObj
    }
}

# Initialize decision
$message  = "The data provided is:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
firstname: $firstname
lastname: $lastname
linkedservicePath: $linkedservicePath
datasetPath: $datasetPath
pipelinePath: $pipelinePath
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

$question = 'Do you want to proceed with this data?'
$choices  = '&Yes', '&No'

# Show decision
$decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)

if ($decision -eq 0) {
    Write-Host 'Confirmed'
} else {
    Write-Host 'Cancelled'
}