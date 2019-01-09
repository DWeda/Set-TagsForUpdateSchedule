<#
.Synopsis
   Script to tag VM's for dynamic groups in Azure Update management
.DESCRIPTION
   To separate your VM's in a different dynamic schedule in Azure update management 
.EXAMPLE
   Set-TagsForUpdateSchedule -Subscription "ota" -ResourceGroup Daan-RG -PatchWindowOne monday -PatchWindowTwo Thursday
#>


Param
    (
        # Input your subscription
        [Parameter(Mandatory=$true,
                   Position=0)]
        $Subscription,
        [Parameter(Mandatory=$true)]
        $ResourceGroup,
        [Parameter(Mandatory=$true)]
        $PatchWindowOne,
        [Parameter(Mandatory=$true)]
        $PatchWindowTwo
    )

try{

    #get azure vm from resource group and set tag
    $RG = Get-AzureRmResourceGroup -Name $ResourceGroup -ErrorAction Stop
    $vms = Get-AzureRmVM -ResourceGroupName $RG.resourcegroupname
    
    if($vms.count -gt 1){
    
        #foreach vm in vms take first and set tag sunday take second and set Wednesday
        $i=0
        $VMNumbers=@()
        
        foreach($VM in $VMS){
        $i =$i+1
        
        $VMNumbers += $VM|Select-object * , @{Name = "Number"; Expression = {$i.ToString()}}
        
        }
        
        
        foreach($VM in $VMNumbers){
        
                if (($VM.number)%2 -eq 0){
                     Write-output "$($VM.name) The number is even"
                     $tags = (Get-AzureRmResource -ResourceGroupName $RG.resourcegroupname -Name $VM.Name).Tags
                     $tags += @{PatchWindow="$PatchWindowOne"}
                     Write-output $tags
                     Set-AzureRmResource -ResourceGroupName $RG.resourcegroupname -Name $VM -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags -WhatIf
                
                }
                else{
                	Write-output "$($VM.name) This is not an even number"
                    $tags = (Get-AzureRmResource -ResourceGroupName $RG.resourcegroupname -Name $VM.Name).Tags
                    $tags += @{PatchWindow="$PatchWindowTwo"}
                    Write-output $tags
                    Set-AzureRmResource -ResourceGroupName $RG.resourcegroupname -Name $VM -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags -WhatIf
                }
        }
    }
}
catch [Exception] {
                  write-output $_.Exception.Message; 

}


