Function Get-SFSpbmPolicyName{
<#
    .Synopsis
	
 	 Creates a string based on values related to a SolidFire volume that can be used to generate 
     VMware Storage Policy Based Management policies. 
	 
	.Description 
	 Creates a string name based on values related to a SolidFire volume.
     Pulls the QoS profile for the volume.  Substitutes 000 with a K.
     Prefixes the policy name with a workload attribute if it exists.
     Ability to choose different attribute name lookup

     Returns the Volume name and resulting policy name.
	 
	.Parameter Volume
	
	 Represents a SolidFire volume object as returned by Get-SFVolume
	
	.Parameter Attribute
	 
	 Allows user to specify the attribute name they would like to use if different than default.
     Default attribute name is "Workload"
     The attribute value is pulled from the volume attribute and used as a prefix for the policy name.
     If volume attribute is: Workload = Oracle
     Policy name will be: Oracle-Min-Max-Burst
	 
	.Example
	
	 Get-SFVolume Volume1 | Get-SFSpbmPolicyName

     Returns the derived policy name for SolidFire volume Volume1

	.Example
	 
	 Get-SFVolume | Get-SFSpbmPolicyName

     Returns the derivied policy name for all SolidFire volumes returned.
    .Example

     Get-SFVolume Volume1 | Get-SFSpbmPolicyName -Attribute Application

     Returns the derived policy name for the SolidFire volume Volume1 with the value for Application as prefix
     <Application>-Min-Max-Burst
     Oracle-1K-3K-5K

	 
	.Link
	 http://www.github.com/solidfire/powershell
	 
	.Notes
	
	====================================================================
	Disclaimer: This script is written as best effort and provides no 
	warranty expressed or implied. Please contact the author(s) if you 
	have questions about this script before running or modifying
	====================================================================
#>
[CmdletBinding(ConfirmImpact="Low")]
param(
		[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$True,
        HelpMessage="Enter the SolidFire volume")]
		[SolidFire.Core.Objects.SFVolume[]]
        $Volume,
        [Parameter(
        ValueFromPipeline=$false,
        Position=1,
        Mandatory=$false,
        HelpMessage="Enter the attribute name if different from Workload")]
        [String]
        $AttributeName = "Workload"
)


# Runs Once
BEGIN {
$result = @()
}

# Runs one time for every object piped in
PROCESS {
$qos = $Volume | Select -ExpandProperty QoS
$attribute = $Volume | Select -ExpandProperty Attributes

$min = Replace-TrailingZeroesWithK -name $qos.MinIOPS
$max = Replace-TrailingZeroesWithK -name $qos.MaxIOPS
$burst = Replace-TrailingZeroesWithK -name $qos.BurstIOPS


#$min = ($qos.MinIOPS.ToString()).Replace("000","K")
#$max = ($qos.MaxIOPS.ToString()).Replace("000","K")
#$burst = ($qos.BurstIOPS.ToString()).Replace("000","K")

if($attribute.$($attributename)){
$policy = "$($attribute.Workload)-$min-$max-$burst"
}else{
$policy = "$min-$max-$burst"
}
$row = "" | Select Name,PolicyName
$row.Name = $Volume.Name
$row.PolicyName = $policy

$result += $row
}

# Runs once
END {
$result
}

}
function Replace-TrailingZeroesWithK{

param(
		[Parameter(
        Mandatory=$True)]
        $name
)

If($name.ToString().EndsWith("000")){
$front = $name.ToString().SubString(0,$name.ToString().Length-3)
$end = ($name.ToString()).Substring($name.ToString().Length-3)

$replace = $front + ($end).Replace("000","K")
}Else{
$replace = $name.ToString()
}
Return $replace
}