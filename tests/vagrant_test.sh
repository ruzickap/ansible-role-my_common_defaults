#!/bin/bash -eu

TEMP_PATH="/tmp/mytest/"
VAGRANT_BOXES="peru/windows-server-2016-standard-x64-eval peru/windows-10-enterprise-x64-eval peru/windows-server-2012-r2-standard-x64-eval"

HOSTS=""
for VAGRANT_BOX in $VAGRANT_BOXES; do
  BOX="${VAGRANT_BOX##*/}"
  echo "*** $VAGRANT_BOX : $BOX"

  HOSTS="$HOSTS,$BOX"

  if [ ! -f $TEMP_PATH/$BOX/Vagrantfile ]; then
    test -d "$TEMP_PATH/$BOX" || mkdir -v -p "$TEMP_PATH/$BOX"
    cd "$TEMP_PATH/$BOX"
    vagrant init $VAGRANT_BOX
    sed -i "/^Vagrant\.configure/a \ \ config.hostmanager.enabled = true\n \ config.hostmanager.manage_host = true\n \ config.hostmanager.aliases = \"$BOX\"" Vagrantfile
    VAGRANT_DEFAULT_PROVIDER=libvirt vagrant up
    cd -
  else
    echo "*** $TEMP_PATH/$BOX/Vagrantfile exists... skipping provisioning"
  fi
done

ansible-playbook --extra-vars "ansible_user=Administrator ansible_password=vagrant ansible_port=5986 ansible_connection=winrm ansible_winrm_server_cert_validation=ignore" -i "$HOSTS," ./test.yml

echo "Press ENTER to Destroy all VMs (or CRTL+C to cancel)"
read A

for VAGRANT_BOX in $VAGRANT_BOXES; do
  BOX="${VAGRANT_BOX##*/}"
  echo "*** Removing $VAGRANT_BOX : $BOX: $TEMP_PATH/$BOX"

  cd "$TEMP_PATH/$BOX"
  vagrant destroy -f
  cd -
  rm -rf "$TEMP_PATH/$BOX"
done
