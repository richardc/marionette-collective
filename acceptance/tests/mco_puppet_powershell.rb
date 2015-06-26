test_name "mco puppet run with powershell provider" do
  on master, puppet("module install puppetlabs-powershell")
  hosts.each do |host|
    stub_hosts_on(host, 'puppet' => master.ip)
  end
  on master, puppet("resource service puppetserver ensure=running")
  hosts.each do |h|
    on h, puppet("agent -t")
    if h[:platform] =~ /windows/
      on h, 'icacls.exe C:/ProgramData/PuppetLabs/puppet/cache/client_data'
    end
  end

  windows_hosts = []
  hosts.each do |h|
    if /windows/ =~ h[:platform]
      windows_hosts << h
    end
  end

  if windows_hosts.empty?
    skip_test "No windows hosts to test powershell on"
  end

testdir = master.tmpdir('mco_powershell')
testfile = master.tmpfile('mco_powershell').split('/')[-1]

node_str = ''
windows_hosts.each do |h|
  n =<<EOS
node #{h} {
    exec { "create-test-file":
      command => "out-file C:\\#{testfile}.txt",
      provider => powershell,
    }
}
EOS
  node_str << n
end

apply_manifest_on(master, <<-MANIFEST, :catch_failures => true)
  File {
    ensure => directory,
    mode => "0750",
    owner => #{master.puppet['user']},
    group => #{master.puppet['group']},
  }
  file {
    '#{testdir}':;
    '#{testdir}/environments':;
    '#{testdir}/environments/production':;
    '#{testdir}/environments/production/manifests':;
    '#{testdir}/environments/production/manifests/site.pp':
      ensure => file,
      mode => "0640",
      content => '
#{node_str}
';
  }
MANIFEST

master_opts = {
  'main' => {
    'environmentpath' => "#{testdir}/environments",
   }
}

with_puppet_running_on(master, master_opts) do
  if mco_master.platform =~ /windows/ then
    if mco_master[:ruby_arch] == 'x86' then
      mco_bin = 'cmd.exe /c C:/Program\ Files\ \(x86\)/Puppet\ Labs/Puppet/bin/mco.bat'
    else
      mco_bin = 'cmd.exe /c C:/Program\ Files/Puppet\ Labs/Puppet/bin/mco.bat'
    end
  else
   mco_bin = '/opt/puppetlabs/bin/mco'
  end
  on(mco_master, "#{mco_bin} puppet runonce")
  sleep 30
  windows_hosts.each do |h|
    binding.pry
    on h, "dir C:/#{testfile}.txt"
  end
end



end
