Param
(
	[string]$Token,			
	[string]$Output_Path,
	[string]$Owner	
)	

Function Write_Info {
	param(
		$Message_Type,	
		$Message
	)
		
	$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)	
	write-host "$MyDate - $Message_Type : $Message"	
}
	
	
If (!(Get-Module | where { $_.name -like "*PowerShellForGitHub*" })) { 
	Try {
		# Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force 						
		Install-Module -Name PowerShellForGitHub -force -confirm:$false -ErrorAction SilentlyContinue 				
		Write_Info -Message_Type "SUCCESS" -Message "GitHub module has been successfully installed"	
		$GitHub_Module_Status = "OK"		
	}
	Catch {
		Write_Info -Message_Type "ERROR" -Message "An issue occured while installing module"	
		$GitHub_Module_Status = "KO"		
	}			
}
Else {
	Import-Module PowerShellForGitHub  -ErrorAction SilentlyContinue 	
	Write_Info -Message_Type "INFO" -Message "The module already exists"		
	$GitHub_Module_Status = "OK"				
}	
	
	
	
$Current_Folder = split-path $MyInvocation.MyCommand.Path
$xml = "$Current_Folder\GitHub_Infos.xml"
$my_xml = [xml] (Get-Content $xml)
$GitHub_Token = $my_xml.Configuration.GitHub_Token
$GitHub_Output_Path = $my_xml.Configuration.Output_Path
$GitHub_Owner = $my_xml.Configuration.GitHub_OwnerName

If (($Token -ne "") -or ($GitHub_Token -ne "")) {
	If ($Token -ne "") {
		$Get_Token = $Token			
	}
	Else {
		$Get_Token = $GitHub_Token			
	}			
}
Else {
	Write_Info -Message_Type "ERROR" -Message "Please type a GitHub token"				
}

If (($Owner -ne "") -or ($GitHub_Owner -ne "")) {
	If ($Owner -ne "") {
		$Get_OwnerName = $Owner			
	}
	Else {
		$Get_OwnerName = $GitHub_Owner			
	}			
}
Else {
	Write_Info -Message_Type "ERROR" -Message "Please type a GitHub owner name"				
}
	
If (($Output_Path -ne "") -or ($GitHub_Output_Path -ne "")) {
	If ($Output_Path -ne "") {
		$Get_Output_Path = $Output_Path			
	}
	Else {
		$Get_Output_Path = $GitHub_Output_Path			
	}			
}
Else {
	Write_Info -Message_Type "ERROR" -Message "Please type an output path where to save ZIP"			
}	

Write_Info -Message_Type "INFO" -Message "The script will download all repos from $Get_OwnerName"		
Write_Info -Message_Type "INFO" -Message "The script will download all repos in $Get_Output_Path"		
write-host ""

$GitHub_SecureToken = ConvertTo-SecureString $Get_Token -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential "Ownername is ignored", $GitHub_SecureToken
Try {
	Set-GitHubConfiguration -DisableLogging
	Set-GitHubAuthentication -Credential $cred -SessionOnly | out-null		
	Write_Info -Message_Type "SUCCESS" -Message "Successfully connected to GitHub"		
	$GitHub_IsConnected = $True
}
Catch {
	Write_Info -Message_Type "ERROR" -Message "An error occured while connecting to GitHub"		
	$GitHub_IsConnected = $False
	
	Try {
	Set-GitHubConfiguration -DisableLogging
	Set-GitHubAuthentication -Credential $cred -SessionOnly | out-null		
	Write_Info -Message_Type "SUCCESS" -Message "Successfully connected to GitHub"		
	$GitHub_IsConnected = $True
}
Catch {
	Write_Info -Message_Type "ERROR" -Message "An error occured while connecting to GitHub"		
	$GitHub_IsConnected = $False
	


}

}
write-host ""

If ($GitHub_IsConnected -eq $True) {
	$List_My_Repos = (Get-GitHubRepository | select name, html_url, owner) | where { (($_.owner.login -like "*$Get_OwnerName*")) } 	
	ForEach ($Repo in $List_My_Repos) {
		$Repo_Name = $Repo.name
		$Repo_URL = $Repo.html_url
		$Repo_Output_Path = "$Get_Output_Path\$Repo_Name.zip"		
		$Repo_Archive = "$Repo_URL\archive\master.zip" 
		write-host "Downloading the repository $Repo_Name"		
		Write_Info -Message_Type "INFO" -Message "Downloading the repository $Repo_Name"													
		$Download_EXE = new-object -typename system.net.webclient
		Try {
			$Download_EXE.Downloadfile($Repo_Archive, $Repo_Output_Path)	
			Write_Info -Message_Type "SUCCESS" -Message "$Repo_Name has been successfully downloaded"														
		}
		Catch {
			Write_Info -Message_Type "ERROR" -Message "An issue coccured while downloading $Repo_Name"														
		}
		write-host ""
	}
}
