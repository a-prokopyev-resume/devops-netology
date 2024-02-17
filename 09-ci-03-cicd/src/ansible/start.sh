# ===> Recreate all (destroy and apply):
#ansible-playbook main.yml;

# ===> Only apply without destroy to get IP addresses and reinit local IaC tooling container
ansible-playbook main.yml --skip-tags "destroy"  --extra-vars "TF_State=planned";
#ansible-playbook main.yml --skip-tags "destroy, provision"  --extra-vars "TF_State=planned";

# ===> Skip all Terraform tasks, it is useless for now
#ansible-playbook main.yml --skip-tags terraform
