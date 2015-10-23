#
# Author:: Sander Botman <sander.botman@gmail.com>
# Cookbook Name:: polkitd
# Recipe:: _rhel
#
# Copyright (C) 2015, Sander Botman
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
return if node['init_package'].nil?
return if node['init_package'] != ('systemd')

group 'polkitd'
group 'ssh_keys'

user 'polkitd'

package 'polkit'
package 'polkit-pkla-compat'

service 'polkit' do
  action :nothing
  supports :restart => true
end

service 'dbus' do
  action :nothing
  supports :reload => true
  notifies :restart, 'service[polkit]', :immediately
end

file '/usr/libexec/openssh/ssh-keysign' do
  mode  02111
  owner 'root'
  group 'ssh_keys'
  notifies :reload, 'service[dbus]', :delayed
end

%w(ssh_host_ed25519_key ssh_host_ecdsa_key ssh_host_rsa_key).each do |k|
  file "/etc/ssh/#{k}" do
    mode  0640
    owner 'root'
    group 'ssh_keys'
  end
end

directory '/var/lib/polkit-1' do
  mode  0700
  owner 'root'
  group 'polkitd'
  notifies :reload, 'service[dbus]', :delayed
end

directory '/usr/share/polkit-1/rules.d' do
  mode  0700
  owner 'polkitd'
  group 'root'
  notifies :reload, 'service[dbus]', :delayed
end

directory '/etc/polkit-1/rules.d' do
  mode  0700
  owner 'polkitd'
  group 'root'
  notifies :reload, 'service[dbus]', :delayed
end

directory '/etc/polkit-1/localauthority' do
  mode  0750
  owner 'root'
  group 'polkitd'
  notifies :reload, 'service[dbus]', :delayed
end
