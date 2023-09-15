source /utils/docker/lib.sh;

set -x;

Container1ImageName="centos";
Container1Name="C1";
Container2ImageName="debian";
Container2Name="C2";
RealDataPath=$(realpath "data");

clean_all()
{
	docker stop C1 C2; 
#	docker rmi centos debian -f; 
	/utils/docker/clean_stopped.sh;
}

clean_all;

docker_run $Container1ImageName $Container1Name "bash" -v $RealDataPath:/data;

docker_run $Container2ImageName $Container2Name "bash" -v $RealDataPath:/data;

touch data/c1_reply.txt; #  Wiping this file

echo "Hello from host to C1 via shell pipe!" | docker_exec $Container1Name bash -lc /workspace/c1.sh;

echo "Hello from host to C2 via /data volume!" > data/message_for_c2.txt

docker_exec $Container2Name bash -lc /workspace/c2.sh;

clean_all;
