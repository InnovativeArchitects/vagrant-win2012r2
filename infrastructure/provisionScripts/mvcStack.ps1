<#
#these commands are previous notes aimed at setting up an mvc application and building it on the box w/out having VS installed

choco WindowsFeatures IIS-WebServerRole
choco WindowsFeatures IIS-ISAPIFilter
choco WindowsFeatures IIS-ISAPIExtensions
choco WindowsFeatures IIS-NetFxExtensibility
choco WindowsFeatures IIS-ASPNET

choco install aspnetmvc.install

get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring,versionstring

choco install poshgit

$env:path += ";" + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin"

$oldPath = [Environment]::GetEnvironmentVariable('Path','Machine')
$npmBin = (npm config get prefix)
$newPath = $oldPath + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin;"
[Environment]::SetEnvironmentVariable('Path',$newPath,'Machine')

mkdir c:\projects

git clone https://github.com/JediMindtrick/mvc-plus-mongodb.git c:\projects\mvc-plus-mongodb

#New-WebApplication -Name 'MvcTemplateApp' -Site 'Default Web Site' -PhysicalPath c:\test -ApplicationPool DefaultAppPool

mkdir c:\www
mkdir c:\www\mvctemplateapp

remove-website -Name 'Default Web Site'

#see
#http://surroundingthecode.wordpress.com/2011/02/24/scripting-iis7-application-pool-configuration-in-powershell/

$myNewPool = New-Item IIS:\AppPools\MvcTemplateApp

$myNewPool.processModel.userName = 'vagrant'
$myNewPool.processModel.password = 'vagrant'
$myNewPool.processModel.identityType = "SpecificUser"
$myNewPool.processModel.idleTimeout = [TimeSpan] "0.00:00:00"
$myNewPool.managedRuntimeVersion = "4.0"   # or 2.0
$myNewPool.recycling.periodicRestart.time = [TimeSpan] "00:00:00"

$myNewPool | Set-Item

#New-WebSite -Name 'MvcTemplateApp' -Port 80 -HostHeader 'MvcTemplateApp' -PhysicalPath "$env:systemdrive\www\mvctemplateapp" -Force -ApplicationPool 'MvcTemplateApp'
New-WebSite -Name 'MvcTemplateApp' -Port 80 -PhysicalPath "$env:systemdrive\www\mvctemplateapp" -Force -ApplicationPool 'MvcTemplateApp'

get-website

choco install nuget.commandline
choco install microsoft-build-tools -Version 12.0.21005.1

nuget restore c:\projects\mvc-plus-mongodb\MvcTemplateApp\MvcTemplateApp.sln

#restore packages before build
#make sure target processor is correct one (x64)


#may need to install vs integrated or isolated shell
#choco install vs2012.shellintegratedredist

#see
#http://geekswithblogs.net/dwdii/archive/2011/05/20/automating-a-visual-studio-build-with-powershell---part-1.aspx

#$MsBuild = $env:systemroot + "\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe";
$MsBuild = $env:systemroot + "\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe";
#ArgumentList = $SlnFilePath, "/t:rebuild", ("/p:Configuration=" + $Configuration), "/v:minimal"

$SlnFilePath = 'c:\projects\mvc-plus-mongodb\MvcTemplateApp\MvcTemplateApp.sln'

$BuildArgs = @{
FilePath = $MsBuild
ArgumentList = "/t:rebuild", "/p:Configuration=Debug", "/v:minimal", "/p:OutputPath=c:\www\mvctemplateapp", $SlnFilePath
#RedirectStandardOutput = $BuildLog
Wait = $true
}

#MSBuild "/t:rebuild" "/p:Configuration=Debug" "/v:minimal" "/p:OutputPath=c:\www\mvctemplateapp" "c:\projects\mvc-plus-mongodb\MvcTemplateApp\MvcTemplateApp\MvcTemplateApp.csproj"

# Start the build
Start-Process @BuildArgs

#>
