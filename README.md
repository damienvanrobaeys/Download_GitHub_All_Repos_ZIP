# Download GitHub repos ZIP

Run this command first

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine


A PowerShell script that allows you to download all ZIP archives from your GitHub account

To proceed run the file **Download_Repos.ps1**.

You will first need to fill below informations in GitHub_infos.xml:
- GitHub_Token: Token to access to your itHub account
- GitHub_OwnerName: Type your GitHub account name
- Output_Path: Specify the path where to save ZIP files

You can also add parameters to the script, as below:
- Token: Token to access to your itHub account
- Output_Path: Specify the path where to save ZIP files
- Owner: Type your GitHub account name
