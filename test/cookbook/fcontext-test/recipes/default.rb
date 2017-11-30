#
# Cookbook:: fcontext-test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

#package 'semanage'

service1 = '/srv/service1'
directory service1 do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

service1_file = '/srv/service1/file1.txt'
file service1_file do
  content 'test'
  mode '0644'
  owner 'root'
  group 'root'
end

fcontext service1 do
    secontext 'var_log_t'
    only_if { File.directory?(service1) }
end

service2 = '/srv/service2'
directory service2 do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

service2_file = '/srv/service2/file2.txt'
file service2_file do
  content 'test'
  mode '0644'
  owner 'root'
  group 'root'
end

service2_dir = '/srv/service2/directory'
directory service2_dir do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

service2_dir_file = '/srv/service2/directory/file3.txt'
file service2_dir_file do
  content 'test'
  mode '0644'
  owner 'root'
  group 'root'
end

fcontext service2 do
    secontext 'var_log_t'
    recursive true
    only_if { File.directory?(service2) }
end
