# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Copyright 2017 Liu Hongyu
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

OPENSHIFT_RELEASE = "3.11"
OPENSHIFT_ANSIBLE_BRANCH = "release-#{OPENSHIFT_RELEASE}"
NETWORK_BASE = "192.168.150"
INTEGRATION_START_SEGMENT = 101

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "centos/7"
  config.vm.box_check_update = false

  # if Vagrant.has_plugin?('landrush')
  #   config.landrush.enabled = true
  #   config.landrush.tld = 'example.com'
  #   config.landrush.guest_redirect_dns = false
  # end

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false

  config.vm.provision "shell", inline: <<-SHELL
    /vagrant/all.sh #{OPENSHIFT_RELEASE}
  SHELL

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus   = "1"
  end

  # Define nodes
  (1..2).each do |i|
    config.vm.define "node0#{i}" do |node|
      node.vm.network "private_network", ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + i}"
      node.vm.hostname = "node0#{i}.example.com"

      if "#{i}" == "1"
        node.hostmanager.aliases = %w(lb.example.com)
      end
    end
  end

  # Define master
  config.vm.define "master", primary: true do |node|
    node.vm.network "private_network", ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT}"
    node.vm.hostname = "master.example.com"
    node.hostmanager.aliases = %w(etcd.example.com nfs.example.com)
    
    # 
    # Memory of the master node must be allocated at least 2GB in order to
    # prevent kubernetes crashed-down due to 'out of memory' and you'll end
    # up with 
    # "Unable to restart service origin-master: Job for origin-master.service 
    #  failed because a timeout was exceeded. See "systemctl status 
    #  origin-master.service" and "journalctl -xe" for details."
    #
    # See https://github.com/kubernetes/kubernetes/issues/13382#issuecomment-154891888
    # for mor details.
    #
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "3096"
    end

    node.vm.provision "shell", inline: <<-SHELL
      /vagrant/master.sh #{OPENSHIFT_RELEASE} #{OPENSHIFT_ANSIBLE_BRANCH} #{NETWORK_BASE}
    SHELL

    # Deploy private keys of each node to master
    if File.exist?(".vagrant/machines/master/virtualbox/private_key")
      node.vm.provision "master-key", type: "file", run: "never", source: ".vagrant/machines/master/virtualbox/private_key", destination: "/home/vagrant/.ssh/master.key"
    end

    if File.exist?(".vagrant/machines/node01/virtualbox/private_key")
      node.vm.provision "node01-key", type: "file", run: "never", source: ".vagrant/machines/node01/virtualbox/private_key", destination: "/home/vagrant/.ssh/node01.key"
    end

    if File.exist?(".vagrant/machines/node02/virtualbox/private_key")
      node.vm.provision "node02-key", type: "file", run: "never", source: ".vagrant/machines/node02/virtualbox/private_key", destination: "/home/vagrant/.ssh/node02.key"
    end
  end
end
