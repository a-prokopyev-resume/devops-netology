# ===> Recreate all (destroy and apply):
#ansible-playbook main.yml --skip-tags "ignore";

# ===> Only apply without destroy to get IP addresses and reinit local IaC tooling container
#ansible-playbook main.yml --skip-tags "destroy, ignore";

# ===> Recreate VMs without installing services
#ansible-playbook main.yml --skip-tags "provision";

# ===> Only get VMs IPs and wait for SSH connections
#ansible-playbook main.yml --skip-tags "destroy, provision";

# ===> Skip all Terraform tasks, it is useless for now
#ansible-playbook main.yml --skip-tags terraform

# ===> Only wait, upgrade and install some packages, and do some few preparations like updating /etc/hosts:
#ansible-playbook -i infrastructure/inventory/cicd/hosts.yml prepare.yml;
#prepare.yml;

# ===> Only provision:
#ansible-playbook -i infrastructure/inventory/cicd/hosts.yml infrastructure/site.yml;


# === UNUSED:
#--extra-vars "TF_State=planned"

yc compute instance-group list;
yc compute instance list;
