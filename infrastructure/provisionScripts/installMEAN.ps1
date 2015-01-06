#echos cause death in this automation, don't do it
#echo 'installing MongoDB'
choco install mongodb
choco install nodejs
$oldPath = [Environment]::GetEnvironmentVariable('Path','Machine')
$npmBin = (npm config get prefix)
$newPath = $oldPath + 'C:\Users\Administrator\AppData\Roaming\npm;' + $npmBin + ';'
[Environment]::SetEnvironmentVariable('Path',$newPath,'Machine')
npm install -g express
npm install -g express-generator
npm install -g bower
npm install -g grunt-cli
npm install -g supervisor
