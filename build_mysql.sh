docker run -d --name "domain.com" \
    -p 8080:80 \
    -v /home/websites/domain.com:/var/www \
    --link mysqldb:db \
    -e "DB_USER={MYSQL_USER}" \
    -e "DB_PASS={MYSQL_PASSWORD}" \
    -e "DB_NAME={MYSQL_DB_NAME}" \
    usdaeas/lap-docker
