#docker-compose up mail -d;
docker-compose up mail -d;
#docker-compose exec mail setup email add user1@example.com
docker-compose exec mail setup email add user2@example.com
docker-compose exec mail setup email add user3@example.com

#docker-compose exec grafana apk add swaks;

# sh -c "python manage.py shell"


#docker run --rm 
#  -e MAIL_USER=user1@example.com \
#  -e MAIL_PASS=mypassword \
#  -it mailserver/docker-mailserver:latest \
#  /bin/sh -c 'echo "$MAIL_USER|$(doveadm pw -s SHA512-CRYPT -u $MAIL_USER -p $MAIL_PASS)"' >> docker-data/dms/config/postfix-accounts.cf

#docker exec -ti <CONTAINER NAME> setup alias add postmaster@example.com user@example.com

