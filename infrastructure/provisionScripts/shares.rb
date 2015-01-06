require 'fileutils'
require 'erb'

=begin
/infrastructure
    /importContainers
    /exportContainers
    /provisionScripts
/projects
/global
    /data
    /secrets
    /dockerfiles
    /templates
/local/{machine name}
    /config
    /scripts
=end

$project_root = File.expand_path('..',Dir.pwd)
$container_home = '/home'
$vm_home = 'c:/'


$local_directories = {}
$local_directories[:local_config] = {
    #this needs to be a function in order to inject the machine name
    host: lambda do |vm_name|
        File.join($project_root,'local',vm_name,'config')
    end,
    vm: File.join($vm_home,'local', 'config'),
    vm_share_id: 'localConfig',
    container: File.join($container_home,'local','config')
}
$local_directories[:local_scripts] = {
    #this needs to be a function in order to inject the machine name
    host: lambda do |vm_name|
        File.join($project_root,'local',vm_name,'scripts')
    end,
    vm: File.join($vm_home,'local', 'scripts'),
    vm_share_id: 'localScripts',
    container: File.join($container_home,'local','scripts')
}

$global_directories = {}

$global_directories[:infrastructure] = {
    host: File.join($project_root,'infrastructure'),
    vm: File.join($vm_home,'infrastructure'),
    vm_share_id: 'infrastructure',
    container: File.join($container_home,'infrastructure')
}

$global_directories[:projects] = {
    host: File.join($project_root,'projects'),
    vm: File.join($vm_home,'projects'),
    vm_share_id: 'projects',
    container: File.join($container_home,'projects')
}

$global_directories[:global] = {
    host: File.join($project_root,'global'),
    vm: File.join($vm_home,'global'),
    vm_share_id: 'global',
    container: File.join($container_home,'global')
}

def list_project_directories()
    arr = []

    $global_directories.each do |key,value|
        arr.push(value[:host])
    end

    return arr
end

def setup_project_directories
    list_project_directories.each do |d|
        FileUtils.mkdir_p(d)
    end
end

def setup_machine_directories(machine_name)
    $local_directories.each do |key,value|
        FileUtils.mkdir_p(value[:host].call(machine_name))
    end
end

def get_template(template_name)
    ERB.new(File.read(File.join($project_templates,template_name)))
end

def setup_host_global_shares(config,i)
    $global_directories.each do |key,value|
        config.vm.synced_folder value[:host], value[:vm], id: (value[:vm_share_id] + i.to_s)
    end
end

def setup_host_local_shares(config,machine_name,i)

    $local_directories.each do |key,value|
        config.vm.synced_folder value[:host].call(machine_name), value[:vm], id: (value[:vm_share_id] + i.to_s)
    end

end
