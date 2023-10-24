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

