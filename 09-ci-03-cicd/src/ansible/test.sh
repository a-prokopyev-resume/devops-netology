cd infrastructure;
#ansible-playbook ../test.yml -i inventory/cicd/hosts.yml
ansible-playbook site.yml -i inventory/cicd/hosts.yml
