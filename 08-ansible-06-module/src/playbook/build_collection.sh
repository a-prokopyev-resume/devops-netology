CollectionDir="../collection/alex_pro/netology";
( 
	cd $CollectionDir;
	ansible-galaxy collection build --force;
);

ansible-galaxy collection install -r requirements.yml --force;
