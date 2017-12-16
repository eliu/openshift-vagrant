# OpenShift Vagrant

## 概述

`OpenShift Vagrant` 项目旨在通过针对目前 OpenShift Origin 各个主流版本进行预配置的 `Vagrantfile` 文件，使开发者在本机快速搭建真正的 OpenShift Origin 集群环境。

## 先决条件

- 主机的内存至少4GB
- 预装 Oracle VirtualBox (v5.1.30)
- 预装 Vagrant (v2.0或更高)
- 预装 Vagrant 插件 vagrant-hostmanager (v1.8.7)

## OpenShift Origin 版本支持

目前本项目预配置且支持以下3个 OpenShift Origin 主版本，他们是：

- [OpenShift Origin release v3.6.0](https://github.com/openshift/origin/releases/tag/v3.6.0)
- [OpenShift Origin release v3.6.1 （默认配置）](https://github.com/openshift/origin/releases/tag/v3.6.1)
- [OpenShift Origin release v3.7.0](https://github.com/openshift/origin/releases/tag/v3.7.0)

不过，支持以后的其他主版本也非常容易，只需要修改对应文件中的版本戳之后另存为新的文件即可。

The `Vagrantfile` uses Origin `v3.6.1` and openshift-ansible `release-3.6` branch by default. Feel free to adjust your versions by updating the following 2 variables in Vagrantfile:
Vagrant 配置文件默认使用 OpenShift Origin v3.6.1 和 openshift-ansible release-3.6 分支做为集群安装部署的版本。不过您也可以很容易更改这个默认值，只需要调整以下两个变量即可：

1. `OPENSHIFT_VERSION`
2. `OPENSHIFT_ANSIBLE_BRANCH`

调整时请注意 Origin 版本和 openshift-ansible 分支的对应关系，具体见下表：

| OpenShift Origin 版本 | openshift-ansible 分支 |
| --- | --- |
| v3.6.0 | release-3.6 |
| v3.6.1 | release-3.6 |
| v3.7.0 | release-3.7 |


## 使用方法

在调整了对应的版本之后，接下来就可以准备启动 Vagrant 虚拟机和部署 OpenShift Origin 集群了。Vagrant 会创建并启动三台 VirtualBox 虚拟机，具体信息如下表：

| VM 节点 | 节点 IP | 角色 |
| --- | --- | --- |
| master | 192.168.101.101 | master, etcd |
| node01 | 192.168.101.102 | node, lb |
| node02 | 192.168.101.103 | node |

### 启动 Vagrant 虚拟机

```bash
$ vagrant up
```

### 设置节点间互访的 SSH 秘钥

```bash
$ vagrant provision --provision-with master-key,node01-key,node02-key
```

### 安装并部署 OpenShift Origin 集群

```bash
$ vagrant ssh master -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/byo/config.yml'
```

### 访问 Web Console

在浏览器中打开 https://master.example.com:8443/ ，若一切正常，您将会看见 Origin 的登陆页面。默认的登陆账户为 **admin/handhand**

*Have fun with OpenShift Origin and Vagrant :p*