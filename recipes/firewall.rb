#
# Cookbook:: hls-sample
# Recipe:: firewall
#
# Copyright:: 2019, The Authors, All Rights Reserved.

execute 'reload firewalld' do
  user 'root'
  command 'firewall-cmd --reload'
  action :nothing
end

execute 'restart firewalld' do
  user 'root'
  command 'systemctl restart firewalld'
  action :run
end
