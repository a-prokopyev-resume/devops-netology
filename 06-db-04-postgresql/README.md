# [Домашнее задание](https://github.com/a-prokopyev-resume/virt-homeworks/tree/virt-11/06-db-04-postgresql) к [занятию 4. «PostgreSQL»](https://netology.ru/profile/program/bd-dev-27/lessons/275713/lesson_items/1477607)
++ docker-compose --env-file=env/docker-compose.env --env-file=env/super.env --env-file=env/common.env stop pg1
++ docker-compose --env-file=env/docker-compose.env --env-file=env/super.env --env-file=env/common.env up -d pg1
++ docker inspect pg1
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d super -c '\pset pager off' -c '\?'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d super -c '\pset pager off' -c '\l+'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d super -c '\pset pager off' -c '\conninfo'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d super -c '\pset pager off' -c '\dtS'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d super -c '\pset pager off' -c '\dS+'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d super -c '\pset pager off' -c '\q'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d super -c '\pset pager off' -c 'CREATE DATABASE test_database'
++ return 0
++ docker exec -it pg1 psql -U super -d test_database -c '\pset pager off' -f /mnt/backup/test_dump.sql
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d test_database -c '\pset pager off' -c '\dt'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d test_database -c '\pset pager off' -c 'ANALYZE VERBOSE public.orders;'
++ return 0
++ docker exec -it pg1 psql -v ON_ERROR_STOP=1 -U super -d test_database -c '\pset pager off' -c 'SELECT avg_width FROM pg_stats WHERE tablename='\''orders'\'''
++ return 0
++ docker exec -i pg1 psql -v ON_ERROR_STOP=1 -U super -d test_database
++ return 0
++ docker exec -it pg1 bash -lc '