#
# Cookbook Name:: sabnzbd
# Recipe:: default
#
# Copyright 2012, Alex Howells <alex@howells.me>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'git'

package 'par2'
package 'unrar'
package 'unzip'
package 'python-yenc'
package 'python-cheetah'
package 'python-openssl'			# Package contains --
package 'coreutils'				    #  nice
package 'util-linux'				  #  ionice

user node['sabnzbd']['user'] do
  shell '/bin/bash'
  comment 'Web Application - SABnzbd'
  home node['sabnzbd']['install_dir']
  system true
end

app_dirs = [
  node['sabnzbd']['install_dir'],
  node['sabnzbd']['config_dir'],
  node['sabnzbd']['run_dir'],
  node['sabnzbd']['log_dir']
]

app_dirs.each do |x|
  directory x do
    mode 0755
    owner node['sabnzbd']['user']
    group node['sabnzbd']['group']
    recursive true
  end
end

data_dirs = %w(complete incomplete logs nzb_backup scripts templates watch)

data_dirs.each do |y|
  directory "#{node["sabnzbd"]["data_dir"]}/#{y}" do
    mode 0755
    owner node['sabnzbd']['user']
    group node['sabnzbd']['group']
    recursive true
  end
end

case node["sabnzbd"]["init_style"]
when 'runit'
  include_recipe 'runit'

  runit_service 'sabnzbd' do
    owner node['sabnzbd']['user']
    group node['sabnzbd']['group']
    action :nothing
  end

when 'bluepill'
  include_recipe 'bluepill'

  template "#{node["bluepill"]["conf_dir"]}/sabnzbd.pill" do
    source 'sabnzbd.pill.erb'
    mode 0644
    notifies :load, 'bluepill_service[sabnzbd]', :immediately
    notifies :restart, 'bluepill_service[sabnzbd]', :immediately
  end

  bluepill_service 'sabnzbd' do
    action :nothing
  end
else
  Chef::Log.warn(
    'sabnzbd >> invalid init_style specified, manual intervention required to start service.'
  )
end

git node['sabnzbd']['install_dir'] do
  repository node['sabnzbd']['git_url']
  revision node['sabnzbd']['git_ref']
  action :sync
  user node['sabnzbd']['user']
  group node['sabnzbd']['group']
  case node["sabnzbd"]["init_style"]
  when 'runit'
    notifies :restart, 'runit_service[sabnzbd]', :immediately
  when 'bluepill'
    notifies :restart, 'bluepill_service[sabnzbd]', :immediately
  end
end

case node["sabnzbd"]["init_style"]
when 'runit'
  runit_service "sabnzbd" do
    action [:enable, :start]
  end
when 'bluepill'
  bluepill_service "sabnzbd" do
    action [:enable, :load, :start]
  end
end
