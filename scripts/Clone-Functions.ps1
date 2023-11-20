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

function LookForGroupsToCopy
{
	param([string]$VerifiedOU,[string]$VerifiedID)
	
	Write-Host "'$VerifiedOU' is a valid OU in this domain`n" -ForeGroundColor DarkGreen
	$allDonorADGroups = Get-ADUser -Identity $VerifiedID -Properties MemberOf | Select-Object -ExpandProperty MemberOf
	$availableGroups = @()
		
	#Find the available groups
	foreach ($group in $allDonorADGroups)
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
		#Display available groups to copy
		Write-Host "The following groups can be copied`n"
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
			Write-Host "$verifiedID is not a member of any groups in '$verifiedOU'`n" -ForeGroundColor DarkRed
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