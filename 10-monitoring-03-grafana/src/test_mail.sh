#docker-compose up mail -d;
docker-compose up -d;

# works:
#docker-compose exec mail swaks --to user3@example.com --from user2@example.com --server localhost  --body "This is a test email sent using swaks.";

#fails:
#docker-compose exec --user root grafana apk add swaks
docker-compose exec grafana swaks --to user3@example.com --from user2@example.com --server mail  --body "This is a test email sent using swaks.";

#--auth-user user1@example.com --auth-password xxx

#example:
#swaks --to john@example.com --from jane@example.com --server smtp.gmail.com --auth-user jane@gmail.com --auth-password mypassword --body "This is a test email sent using swaks with authentication."

