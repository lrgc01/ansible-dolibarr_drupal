#!/bin/sh

# Check base packages to continue
which sudo > /dev/null 2>&1
[ "$?" != 0 ] && ( echo "You must install sudo to run this script"; exit 1 )

# Check release
[ -f /etc/os-release ] && . /etc/os-release

which ansible > /dev/null 2>&1
if [ "$?" != 0 ]; then
  case "$ID" in
    'debian')
       grep "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" /etc/apt/sources.list > /dev/null 2>&1 
       if [ "$?" != 0 ]; then
          sudo sh -c "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' >> /etc/apt/sources.list"
       fi
       # Followed instructions in https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-debian
       sudo apt install dirmngr
       sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
       sudo apt-get update
       sudo apt-get -y install ansible
    ;;
    'ubuntu')
       sudo apt-get update
       sudo apt-get -y install software-properties-common
       sudo apt-add-repository ppa:ansible/ansible
       sudo apt-get update
       sudo apt-get -y install ansible
    ;;
  esac
fi

PLAYDIR="`dirname $0`"

cd "$PLAYDIR"

BASEDIR="`pwd`"
CONFDIR="${BASEDIR}/conf.d"
SSHCONF="${CONFDIR}/ssh_config"
FACTSDIR="${BASEDIR}/facts.d"

[ ! -d ${FACTSDIR} ] && mkdir -p ${FACTSDIR}

export BASEDIR CONFDIR SSHCONF FACTSDIR

export DISPLAY_SKIPPED_HOSTS="false"

# First check base local pre-requisites, but becoming root with password:
echo "Local sudo to install local base requirements (may comment line after first run)"
ansible-playbook -i hosts --ask-become-pass base_AWS.yml
# can comment the line after first successfull run

# The rest of AWS stuff may work with a local non-root user
#ansible-playbook -i hosts --extra-vars "gather_y_n=false basedir=${BASEDIR} confdir=${CONFDIR} facts_out_dir=${FACTSDIR} sshconf=${SSHCONF}" --tags "base_config" AWS.yml
ansible-playbook -i hosts --extra-vars "gather_y_n=false basedir=${BASEDIR} confdir=${CONFDIR} facts_out_dir=${FACTSDIR} sshconf=${SSHCONF}" AWS.yml

rm -f *.retry
