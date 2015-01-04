<#
Based off of: http://www.hurryupandwait.io/blog/in-search-of-a-light-weight-windows-vagrant-box
with some slight modification
#>

#Getting Started
#0
    <#
    Run gpedit from a command prompt
    Navigate to Computer Configuration -> Windows Settings -> Security Settings -> Account Policies -> Password Policy
    Select 'Password must meet complexity requirements' and disable
    #>
#1 copy the contents of this file to a file named initialbuild.ps1
#2 in powershell run 'Set-ExecutionPolicy -ExecutionPolicy Unrestricted' (without quotes)
#3 run ./initialbuild.ps1

<#
FURTHER NOTES:
#this looks handy, allows for using powershell to do windows updates
#choco install pswindowsupdate
would first have to install chocolatey via

#install chocolatey
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
#>

#uninstall product key, if any exists
slmgra /upk

#rename Adminstrator account, change password
#don't forget to change password complexity rules
$admin=[adsi]"WinNT://./Administrator,user"
$admin.psbase.rename("vagrant")
$admin.SetPassword("vagrant")
$admin.UserFlags.value = $admin.UserFlags.value -bor 0x10000
$admin.CommitChanges()

#WinRM settings for vagrant
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

#rdp settings for vagrant
$obj = Get-WmiObject -Class "Win32_TerminalServiceSetting" -Namespace root\cimv2\terminalservices
$obj.SetAllowTsConnections(1,1)

#firewall rules
Enable-WSManCredSSP -Force -Role Server
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-TCP -Enabled True

#change pagefile
$System = GWMI Win32_ComputerSystem -EnableAllPrivileges
$System.AutomaticManagedPagefile = $False
$System.Put()
$CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
$CurrentPageFile.InitialSize = 512
$CurrentPageFile.MaximumSize = 512
$CurrentPageFile.Put()
