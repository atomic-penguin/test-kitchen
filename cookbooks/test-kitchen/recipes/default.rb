#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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

# Make sure that the package list is up to date
case node[:platform]
when 'debian', 'ubuntu'
  include_recipe "apt"
when 'centos','redhat'
  include_recipe "yum::epel"
end

include_recipe 'git'

project = node['test-kitchen']['project']
source_root = project['source_root']
test_root = project['test_root']

package "rsync" do
  action :install
end

execute "stage project source to test root" do
  command "rsync -aHv --update --progress --checksum #{source_root}/ #{test_root} "
end

# make the project_root available to other recipes
node.run_state[:project] = project

language = project['language'] || 'chef'

# ensure projects declared language toolchain is present
include_recipe "test-kitchen::#{language}"
