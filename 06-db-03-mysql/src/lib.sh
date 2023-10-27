ComposeEnv=" --env-file=env/docker-compose.env --env-file=env/super.env --env-file=env/common.env ";

env_file()
{
        local EnvName=$1;
        
        local ScriptDir="$(dirname "$(readlink -f "$0")")";
	local EnvFile=$ScriptDir/env/$EnvName.env;
        
        echo $EnvFile;
}

src_env()
{
        local EnvName=$1;
        
	local EnvFile=$(env_file $EnvName);
        
        source $EnvFile;
}

#env2json()
#{
#	jq -Rn 'inputs | split("=") | {(.[0]): .[1]}';
#	jq -Rn 'inputs | split("=") | {(.[0]): .[1]}';
#back conversion:
#echo '[{"name":"SQS_URL","value":"xyz"},{"name":"foo","value":"bar"}]' | jq -r '.[] | "\(.name)=\(.value)"'	
#}

#env2json;