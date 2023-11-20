$userToRemoveGroupsFrom = Read-Host 'Enter hawkid to remove groups'
while ($true) {
	$OU_ToRemoveGroupsFrom = Read-Host "Enter OU from which to remove all groups from '"$userToRemoveGroupsFrom"'"

	$listOfGroupsToRemoveFromUser = Get-ADUser -Identity $userToRemoveGroupsFrom -Properties memberof | Select-Object -ExpandProperty memberof | Select-String $OU_ToRemoveGroupsFrom

	if ($null -eq $listOfGroupsToRemoveFromUser) {
		#Write-Host "One"
		Write-Host "No groups found under " $OU_ToRemoveGroupsFrom " for " $userToRemoveGroupsFrom
	}
	else {
		#Write-Host "Two"
		#Write-Host $listOfGroupsToRemoveFromUser

		$newListOfGroupsToRemoveFromUser = New-Object -TypeName 'System.Collections.ArrayList'
		 foreach ($g in $listOfGroupsToRemoveFromUser) {
			$newListOfGroupsToRemoveFromUser.add($g.ToString())
		}
		
		foreach ($group in $newListOfGroupsToRemoveFromUser){
			Remove-ADGroupMember -Identity $group -Members $userToRemoveGroupsFrom -Confirm:$false
		}
		
	}
	while ($true) {
		$endProgram = Read-Host "Would you like to remove groups from another OU?:`n Enter [y] to continue [n] to exit"
		if ($endProgram -eq "y" -or $endProgram -eq "Y" ) {
			break
		}
		elseif ($endProgram -eq 'n' -or $endProgram -eq "N") {
			Write-Host "Goodbye"
			exit
		} 
		else {
			Write-Host "You have entered an unsupported command. Please try again."
		}
	}
}



