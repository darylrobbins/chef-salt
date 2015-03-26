
include_recipe 'salt::default'

include_recipe "ohai"

ohai 'reload_salt' do
  plugin 'salt'
  action :nothing
end

cookbook_file "#{node['ohai']['plugin_path']}/salt.rb" do
  source 'salt_plugin.rb'
  owner  'root'
  group  node['root_group'] || 'root'
  mode   '0755'
  notifies :reload, 'ohai[reload_salt]', :immediately
end

case node['platform_family']
when 'debian'
  include_recipe 'apt'

  case node['platform']
  when 'ubuntu'
    apt_repository 'saltstack-salt' do
      uri          'http://ppa.launchpad.net/saltstack/salt/ubuntu'
      distribution node['lsb']['codename']
      components   ['main']
      keyserver    'keyserver.ubuntu.com'
      key          '0E27C0A6'
    end
  when 'debian'
    apt_repository 'saltstack-salt' do
      uri          'http://debian.saltstack.com/debian'
      distribution "#{node['lsb']['codename']}-saltstack"
      components   ['main']
      key          'http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key'
    end
  end

when 'rhel'
  if node['platform_version'].to_i > 5
    include_recipe 'yum-epel'
  elsif node['platform_version'].to_i == 5
    #EPEL for CentOS/RHEL 5 removed the python26-distribute package,
    #so salt on CentOS/RHEL 5 only requires the salt COPR repo to install
    yum_repository 'copr' do
      description 'COPR Salt repo'
      baseurl 'https://copr-be.cloud.fedoraproject.org/results/saltstack/salt-el5/epel-5-x86_64/'
      gpgkey 'https://copr-be.cloud.fedoraproject.org/results/saltstack/salt-el5/pubkey.gpg'
      sslverify false
      action :create
    end
  end
end

