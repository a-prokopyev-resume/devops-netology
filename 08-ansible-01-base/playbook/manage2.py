#!/usr/bin/env python3

import os
from dataclasses import dataclass

@dataclass
class Container:
    name: str
    image: str

Envs = {
  "ub": Container("ubuntu", "pycontribs/ubuntu"),
  "el": Container("centos7", "pycontribs/centos:7"),
  "fd": Container( "fedora", "pycontribs/fedora")
}

for E in Envs:
  Name=Envs[E].name;
  Image=Envs[E].image;
  print(Name, Image);
  os.system(f"docker run -dit --name {Envs[E].name} {Envs[E].image} sleep 100h");

os.system("ansible-playbook -i inventory/prod.yml site.yml --vault-password-file .secrets")

for E in Envs:
  print(Name, Image);
  os.system(f"docker stop {Envs[E].name}");

