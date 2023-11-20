$host.ui.RawUI.WindowTitle = 'Clone User AD Access'
Import-Module ActiveDirectory
. "$PSScriptRoot.\scripts\Clone-Functions.ps1"

$donorID = $null
$receiverID = $null
#Verify that the ID you want to copy groups FROM is valid and give the user a chance to re-enter if it is not
while ($true) 
{
	$donorID = VerifyUserName -ID (Read-Host "Enter a userID to copy groups from")
	if ($donorID -ne $null) {break}
}

#Verify that the ID you want to copy groups TO is valid and give the user a chance to re-enter if it is not
while ($true) 
{
	$receiverID = VerifyUserName -ID (Read-Host "Enter a userID to copy security groups to")
	if ($receiverID -ne $null) {break}
}

#After both IDs have been verified, prompt for the OU you to copy and then copy groups
#If the user chooses to exit the program from within the InvalidUserName function, this code will never run
while ($true)
{
	$verifiedOU = VerifyOU -UnverifiedOU (Read-Host "Enter the OU for which you want to copy groups. Only top level orgs are valid")
	
	#Execute if the OU is valid top level
	if ($verifiedOU -ne $null) 
	{
		$groupsToCopy = LookForGroupsToCopy -VerifiedOU $verifiedOU -VerifiedID $donorID
		if ($groupsToCopy -ne $null) 
		{
			#Give user an option to cancel and exit the program or continue and copy groups
			while ($true)
			{
				if (QuitProgram -Exit (Read-Host "`nProceed [y] [n]?") -eq $true) 
				{
					foreach ($group in $groupsToCopy) 
					{
						Add-ADGroupMember -Identity $group -Members $receiverID
						$shortName = $group -replace ",OU=.*", ""
						Write-Host "Added '$receiverID' to '$shortName'" -ForeGroundColor DarkGreen
					}
					Write-Host "`nFinished copying security groups from '$donorID' to '$receiverID'`n" -ForeGroundColor DarkGray
					Write-Host "Goodbye" -ForeGroundColor Yellow
					break
				}
			}
			break
		}
	}	
}