<#
#activate windows with key
#see http://blogs.technet.com/b/rgullick/archive/2013/06/13/activating-windows-with-powershell.aspx
#$computer = gc env:computername
#$key = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" #<---put your key here
#$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
#$service.InstallProductKey($key)
#$service.RefreshLicenseStatus()
#>

#install chocolatey
#echos cause death in this automation, don't do it
#echo 'installing chocolatey'
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1

#choco install poshgit
choco install git

$oldPath = [Environment]::GetEnvironmentVariable('Path','Machine')
$newPath = $oldPath + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin;"
[Environment]::SetEnvironmentVariable('Path',$newPath,'Machine')
