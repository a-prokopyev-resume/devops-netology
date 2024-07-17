#!/usr/bin/env -vS bash -li 

source aliases.sh;
rm -Rf /Homework/12-kuber-homeworks/kapitan/compiled/*;
#cd module12; 
kapitan compile  --validate  --verbose --inventory-path=.;
#--targets=task2_1;

#  --inventory-backend reclass-rs;
# --quiet;
#  --migrate             Migrate your inventory to your selected inventory backend.
#  --compose-target-name, --compose-target-name                     Create same subfolder structure from inventory/targets                        inside compiled folder
#  --search-paths JPATH [JPATH ...], -J JPATH [JPATH ...]                        set search paths, default is ["."]
#  --jinja2-filters FPATH, -J2F FPATH                        load custom jinja2 filters from any file, default is                        to put them inside lib/jinja2_filters.py
#  --verbose, -v         set verbose mode
#  --prune               prune jsonnet output
#  --quiet               set quiet mode, only critical output
#  --output-path PATH    set output path, default is "."
#  --fetch               fetch remote inventories and/or external dependencies
#  --force-fetch         overwrite existing inventory and/or dependency item
#  --force               overwrite existing inventory and/or dependency item
#  --validate            
#  --targets
#  --labels
