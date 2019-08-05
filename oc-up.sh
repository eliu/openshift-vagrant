#!/bin/bash
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
#!/bin/bash

# resolve links - $0 may be a softlink
PRG="$0"
RETCODE=0

while [ -h "$PRG" ]; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`/"$link"
    fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

readonly openshift_release=`cat Vagrantfile | grep '^OPENSHIFT_RELEASE' | awk -F'=' '{print $2}' | sed 's/^[[:blank:]\"]*//;s/[[:blank:]\"]*$//'`

. "$PRGDIR/common.sh"

vagrant up
vagrant provision --provision-with master-key,node01-key,node02-key
# Fix permission issue on Windows host (#13)
vagrant ssh master -c 'chmod 600 /home/vagrant/.ssh/*.key'

if [ "$(version $openshift_release)" -gt "$(version 3.7)" ]; then
    vagrant ssh master \
        -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/prerequisites.yml &&
            ansible-playbook /home/vagrant/openshift-ansible/playbooks/deploy_cluster.yml'
else
    vagrant ssh master \
        -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/byo/config.yml'
fi
