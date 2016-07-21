docker run -d \
 --name "mysqldb508" \
 -p 3306:3306 \
 -e right="WRITE" \
 -e url="https://docker.container.accessible.url" \
 mysqldb