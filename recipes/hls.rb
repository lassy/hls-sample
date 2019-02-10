#
# Cookbook:: hls-sample
# Recipe:: hls
#
# Copyright:: 2019, The Authors, All Rights Reserved.

directory "/var/www/vhosts/live" do
  owner 'nginx'
  group 'nginx'
  recursive true
  mode 0755
  action :create
  not_if { ::File.exist? "/var/www/vhosts/live" }
end

template "/etc/nginx/conf.d/live.conf" do
  source 'live.conf.erb'
  owner 'nginx'
  group 'nginx'
  mode 0644
  notifies :run, 'execute[restart Nginx service]'
end

template "/var/www/vhosts/player.html" do
  source 'player.html.erb'
  owner 'nginx'
  group 'nginx'
  mode 0644
end

template "/usr/lib/firewalld/services/rtmp.xml" do
  source 'rtmp.xml.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :run, 'execute[reload firewalld]', :immediately
end

execute 'enable rtmp access' do
  user 'root'
  command 'firewall-cmd --add-service=rtmp --zone=public --permanent'
  notifies :run, 'execute[reload firewalld]'
end
