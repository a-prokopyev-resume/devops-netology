CollectionDir="../collections/alex_pro/debian_clickhouse";
( 
	cd $CollectionDir;
	ansible-galaxy collection build --force;
);

#ansible-galaxy collection install $CollectionDir/alex_pro-debian_clickhouse-1.0.0.tar.gz;
ansible-galaxy collection install -r requirements.yml --force;
