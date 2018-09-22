#!/bin/sh

PLAYDIR="`dirname $0`"

cd "$PLAYDIR"

BASEDIR="`pwd`"
CONFDIR="${BASEDIR}/conf.d"
SSHCONF="${CONFDIR}/ssh_config"

# Ensure priv keys in conf.d dir are protected
chmod go-w,o-rwx ${CONFDIR}/*

export BASEDIR CONFDIR SSHCONF

export DISPLAY_SKIPPED_HOSTS="false"

export ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto -o ControlPersist=60s -F ${SSHCONF}"

# Use --tags "__TAG_NAME__" to restrict ansible-playbook in the following useful tags:
#  - bootstrap_python
#  - base_users
#  - auth_keys
#  - deploy_templates
#  - install_dep_pkg
#  - cron_config
#  - config_files
#  - databases
#  - php_config,drupal_site

# update_cache_y_n=yes or no

ansible-playbook -i hosts --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" --tags "deploy_templates" Site.yml
#ansible-playbook -i hosts --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" --tags "php_config,drupal_site,deploy_templates,config_files" Site.yml
#ansible-playbook -i hosts --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" --skip-tags "bootstrap_python,install_dep_pkg,base_users,auth_keys" Site.yml 
#ansible-playbook -i hosts --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" --skip-tags "bootstrap_python" Site.yml 

rm -f *.retry
