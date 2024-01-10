ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -e @vars/main.yml debian_template.yml -i inventory/prod.yml;
