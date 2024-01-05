#!/usr/bin/env python3

import os

Envs = {
#  'deb': { 'name': 'debian', 'image': 'pycontribs/debian' },
  'ub': { 'name': 'ubuntu', 'image': 'pycontribs/ubuntu' },
  'el': { 'name': 'centos7', 'image': 'pycontribs/centos:7' },
  'fd': { 'name': 'fedora', 'image': 'pycontribs/fedora' }
}

# Print all values 
#for E in Envs:
#  print(E)
#  for K in Envs[E]:
#    print(f"{K}: {Envs[E][K]}")

for E in Envs:
  Name=Envs[E]['name'];
  Image=Envs[E]['image'];
  print(Name, Image);
  os.system(f'docker run -dit --name {Name} {Image} sleep 100h');

os.system('ansible-playbook -i inventory/prod.yml site.yml --vault-password-file .secrets')

for E in Envs:
  Name=Envs[E]['name'];
  Image=Envs[E]['image'];
  print(Name, Image);
  os.system(f'docker stop {Name}');

