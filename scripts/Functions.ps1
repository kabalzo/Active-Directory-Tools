#####################################
# Drew Kabala - IT Support Analyst	#
# The University of Iowa - 2023     #
# drew-kabala@uiowa.edu             #
# dkabala.2011@gmail.comment        #
# https://github.com/kabalzo        #
#####################################

#Call to verify that the users are valid in the domain
function VerifyUserName
{
	param ([string]$ID)
	try
	{	
		$ADInfo = Get-ADUser -Identity $ID -ErrorAction Stop
		$verifiedID = $ADInfo.SamAccountName
		Write-Host "'$verifiedID' is a valid user in this domain`n" -ForeGroundColor DarkGreen
		return $verifiedID
	}
	catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] 
	{
		while ($true) 
		{
			Write-Host "'$ID' is not recognized as a user in this domain.`n" -ForeGroundColor DarkRed
			if (QuitProgram -Exit (Read-Host "Would you like to enter a different username?`nEnter [y] to continue [n] to exit") -eq $true) {break}
		}
		return $null
	}
}

#Call to verify that the top level OU provided is valid
function VerifyOU
{
	param ([string]$UnverifiedOU)
	$ADInfo = Get-ADOrganizationalUnit -Filter "DistinguishedName -like 'OU=$UnverifiedOU,DC=iowa,DC=uiowa,DC=edu'"
	#Write-Host $ADInfo.Name
	
	while ($true)
	{
		if ($ADInfo -ne $null)
		{
			$verifiedOU = $ADInfo.Name
			return $verifiedOU
		}
		else 
		{
			Write-Host "'$UnverifiedOU' is not recognized as a top level OU in this domain.`n" -ForeGroundColor DarkRed
			if (QuitProgram -Exit (Read-Host "Would you like to enter a different OU?`nEnter [y] to continue [n] to exit") -eq 0) {return $null}
		}
	}
}

function LookForGroups
{
	param([string]$VerifiedOU,[string]$VerifiedID, [String]$Task)
	
	Write-Host "'$VerifiedOU' is a valid OU in this domain`n" -ForeGroundColor DarkGreen
	$allADGroups = Get-ADUser -Identity $VerifiedID -Properties MemberOf | Select-Object -ExpandProperty MemberOf
	$availableGroups = @()
		
	#Find the available groups
	foreach ($group in $allADGroups)
	{	
		if ($group.Contains($VerifiedOU)) 
		{
			#Write-Host $group
			$availableGroups += $group
		}
	}
		
	#OU is valid and there is 1 or more groups to copy
	if ($availableGroups.Length -gt 0)
	{
		#Display available groups to copy or remove
		if ($Task.ToLower() -eq "copy")
		{
			Write-Host "The following groups can be copied`n"
		}
		elseif ($Task.ToLower() -eq "purge")
		{
			Write-Host "The following groups can be removed`n"
		}
		else 
		{
			Write-Host "Invalid arguments for Task parameter"
			exit
		}
		
		foreach ($group in $availableGroups)
		{	
			$groupName = $group -replace ",OU=.*"
			Write-Host $groupName -ForeGroundColor Blue
		}
		return $availableGroups
	}	
	#OU is valid but there are no groups to copy
	else
	{
		while ($true)
		{
			Write-Host "$VerifiedID is not a member of any groups in '$VerifiedOU'`n" -ForeGroundColor DarkRed
			if (QuitProgram -Exit (Read-Host "Would you like to enter a different OU?`nEnter [y] to continue [n] to exit") -eq $true) {return $null}
		}	
	}	
}

function QuitProgram
{
	param([string]$Exit)
	if ($Exit -eq "y" -or $Exit -eq "Y" ) 
	{
		return $true
	}
	elseif ($Exit -eq 'n' -or $Exit -eq "N") 
	{
		Write-Host "Goodbye." -ForeGroundColor Yellow
		exit
	} 
	else 
	{
		Write-Host "You have entered an unsupported command. Please try again." -ForeGroundColor DarkRed
		return $false
	}
}