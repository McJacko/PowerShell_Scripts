# Using PowerShell Get
Get-Command -Module PowerShellGet

# View Registered Repos
Get-PSRepository

(Get-Module Az -ListAvailable).Version # what do I have 
Get-InstalledModule -Name Az -AllVersions
Find-Module -Name Az # what is available

Get-Module Az* -ListAvailable # note the install location and meta module

# Remove the old
Get-Module Az* -ListAvailable | Uninstall-Module -Force # elevated command prompt needed

# Look at path for modules
$env:PSModulePath

# To update
Update-Module Az 

# To sign-in
Connect-AzAccount # will populate the browser and populate the token automatically using browser control
Connect-AzAccount -UseDeviceAuthentication # will show a token and you can type in any broswer i.e. device authorization grant code flow

Connect-AzAccount -Tenant <name.com> # to get context against another tenant than default for the security principal being used i.e. a guest in a tenant

# Once authenticated will have a default context based on your tenant and subscription
Get-AzContext 
Get-AzContext -ListAvailable
Get-AzSubscription

Select-AzSubscription -Name "Jack Mc Tech"
Get-Alias Select-AzSubscription | JmcD

$contexts= Get-AzContext -ListAvailable 
$contexts[0]

$contexts[1] | Rename-AzContext -TargetName "Jack Dev"
$contexts[2] | Rename-AzContext -TargetName "Jack Lab"
$contexts[3] | Rename-AzContext -TargetName "Jack Prod"
Get-AzContext -ListAvailable 

Select-AzContext "Jack Lab"
Get-Alias Select-AzSubscription | JmcD 

Get-AzContextAutosaveSetting 
Enable-AzContextAutosave 
Clear-AzContext | -WhatIf 

# CloudShell
Get-PSDrive

# Commands
Get-Command -Module Az.Resources | Select-Object -Unique noun | Sort-Object Noun   # Look at all the Az Resources Nouns you can use
Get-Command -Module Az.Resources -Noun AzResourceGroup 

Get-AzResourceGroup | Format-Table ResourceGroupName, Location -AutoSize

# View VMs 
Get-AzVM 

# View VM Status
Get-AzVM -Status | Format-Table Name, ResourceGroupName, Location, PowerState -AutoSize

# Can use regular Piplining and features like what if
Get-AzVM -Status | Where PowerState -ne "VM Running" | Start-AzVM -WhatIf 

# the various azure clouds. Get-AzContext shows the environment you are using 
Get-AzEnvironment

# View Regions
Get-AzLocation

# View VM sizes in a region 
Get-AzVMSize -Location southcentralus 

# Currently using against allowed core counts
Get-AzVMUsage -Location southcentralus | Sort-Object -Property CurrentValue -Descending

# Looking at images in marketplace
$loc = 'SouthCentralUS'

#View the templates available
Get-AzVMImagePublisher -Location $loc 
Get-AzImageOffer -Location $loc -PublisherName "MicrosoftWindowsServer"
Get-AzVMImageSku -Location $loc -PublisherName "MicrosoftWindowsServer" -Offer "WindowServer"
Get-AzVMImage -Location $loc -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019 Datacenter-Core"

# View Extensions available
Get-AzVMImagePublisher -Location $loc 
Get-AzVMExtensionImageType | 
Get-AzVMExtensionImage | Select-Object Type, Version

# Resource Graph
Install-Module Az.ResourceGroup 
Import-Module Az.ResourceGraph 

$ComputerName = "jackmcwin10"
$GraphSearchQuery = "Resources
| where type =~ 'Microsoft.Compute/VirtualMachines
| where properties.osprofile.computername =~ '$ComputerName'
| join (ResourceContainers | where type=='microsoft.resources/subscriptions' | project SubName=Name, subscriptionID) on subscriptionID
| project VMName = Name, CompName = properties.osprofile.computerName, RGName = resourceGroup, SubName, SubID = subscriptionID"

try {
    $VMResource = Search-AzGraph -Query $GraphSearchQuery
}
catch { 
    Write-Error "Failure running Search-AzGraph, $_"
}

# Deploy templates etc 
New-AzResourceGroupDeployment -ResourceGroupName RG-0001
    -TemplateFile "StorageAccount.json"
    -TemplateParameterFile "StorageAccount.parameters.json"
    -WhatIf

# Azure Documentation has PowerShell commands for nearly everything
Get-Command -Module Az.Compute -Noun *VM* -Verb New  #to find
Get-Help new-azvm -Examples 
Get-Help new-azvm -online  

