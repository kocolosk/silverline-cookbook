include_recipe 'apt'

directory "/etc/update-motd.d"

cookbook_file '/etc/update-motd.d/50-landscape-sysinfo' do
  owner 'root'
  group 'root'
  mode '755'
end

apt_repository "librato" do
  uri "http://apt.librato.com/#{node[:platform]}"
  distribution node['lsb']['codename']
  components [node[:silverline][:component]]
  key "http://apt.librato.com/packages.librato.key"
  action :add
end

apt_package "librato-silverline" do
  action :install
end

template "/etc/load_manager/lmd.conf" do
  source 'lmd.conf.erb'
  owner 'root'
  group 'root'
  mode '600'
  variables({
              :api_token => node[:silverline][:api_token],
              :server_id_cmd => node[:silverline][:server_id_cmd],
              :template_id => node[:silverline][:template_id]
            })
  action :create
end

case node[:platform]
  when "ubuntu"
    service 'silverline' do
      provider Chef::Provider::Service::Upstart
      action [:enable, :start]
      subscribes :restart, resources(:template => "/etc/load_manager/lmd.conf")
    end
  when "debian"
    execute "start silverline agent" do
      command "telinit q"
      action :nothing
      subscribes :run, resources(:template => "/etc/load_manager/lmd.conf")
    end
end

template "/etc/load_manager/lmc.conf" do
  source 'lmc.conf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables :email => node[:silverline][:email_address]
  action :create
end
