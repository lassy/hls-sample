#
# Cookbook:: hls-sample
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

execute "yum update" do
  user 'root'
  command "yum -y update"
  action :run
end
