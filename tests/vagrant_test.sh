#!/bin/bash -eu

TEMP_PATH="/tmp/mytest/"
VAGRANT_BOXES="peru/windows-server-2016-standard-x64-eval peru/windows-10-enterprise-x64-eval peru/windows-server-2012-r2-standard-x64-eval"

IP_ADDRESSES=""
for VAGRANT_BOX in $VAGRANT_BOXES; do
  BOX="${VAGRANT_BOX##*/}"
  echo "*** $VAGRANT_BOX : $BOX"

  test -d "$TEMP_PATH/$BOX" || mkdir -v -p "$TEMP_PATH/$BOX"
  cd "$TEMP_PATH/$BOX"
  test -f Vagrantfile || vagrant init $VAGRANT_BOX
  VAGRANT_DEFAULT_PROVIDER=libvirt vagrant up
  IP_ADDRESSES="`vagrant winrm-config | awk '/HostName/ { print $2 }'`,$IP_ADDRESSES"
  cd -
done

ansible-playbook --extra-vars "ansible_user=vagrant ansible_password=vagrant ansible_port=5986 ansible_connection=winrm ansible_winrm_server_cert_validation=ignore" -i "$IP_ADDRESSES" ./test.yml
ansible-playbook --extra-vars "ansible_user=Administrator ansible_password=vagrant ansible_port=5986 ansible_connection=winrm ansible_winrm_server_cert_validation=ignore" -i "$IP_ADDRESSES" ./test.yml

echo "Press ENTER to Destroy all VMs"
read A

for VAGRANT_BOX in $VAGRANT_BOXES; do
  BOX="${VAGRANT_BOX##*/}"
  echo "*** Removing $VAGRANT_BOX : $BOX: $TEMP_PATH/$BOX"

  cd "$TEMP_PATH/$BOX"
  vagrant destroy -f
  cd -
  rm -rf "$TEMP_PATH/$BOX"
done
