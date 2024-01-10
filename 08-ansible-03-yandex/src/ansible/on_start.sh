ansible-playbook -e @vars/main.yml on_start.yml -i inventory/prod.yml --start-at-task  "Stop and remove old containers at the beginning of the play"
# --step;
