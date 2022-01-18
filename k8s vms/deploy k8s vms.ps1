## Deploy VMs from CSV File
## Much borrowed from http://communities.vmware.com/thread/315193?start=15&tstart=0  

$maxJobs = 3 
$currentJobs = 0

## Imports CSV file
Import-Csv "C:\Users\kraus\Desktop\scripts 2021\k8s-ctl1.csv" -UseCulture | %{
## Gets Customization info to set NIC to Static and assign static IP address
    Get-OSCustomizationSpec $_.Customize | Get-OSCustomizationNicMapping | ` 
## Sets the Static IP info
    Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $_.IP `
        -SubnetMask $_.Subnet -DefaultGateway $_.Gateway
## Sets the name of the VMs OS
    $cust = Get-OSCustomizationSpec -Name ubuntu20-k8s
    Set-OSCustomizationSpec -OSCustomizationSpec $cust -NamingScheme Fixed -NamingPrefix $_.Name
## Creates the New VM from the template
    $vm=New-VM -Name $_.Name -Template $_.Template -ResourcePool $_.Cluster `
        -Datastore $_.Datastore -OSCustomizationSpec $_.Customize `
        -Confirm:$false -RunAsync

    $currentJobs = Get-Job -State Running | Measure-Object | Select -ExpandProperty Count
    while($currentJobs -ge $maxJobs){
      sleep 30
      $currentJobs = Get-Job -State Running | Measure-Object | Select -ExpandProperty Count
    }
}