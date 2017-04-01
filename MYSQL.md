If you don't have an existing MySQL instance running then you can use docker to create one (replace supersecret with your own password):

```bash
docker run \
        --name librenms-mysql \
        -d \
        -e MYSQL_ROOT_PASSWORD=secret \
        -p 127.0.0.1:3306:3306 \
        -v /my/persistent/directory/mysql:/var/lib/mysql \
        mysql:5.6 --sql-mode=""
```

Now you need to create a user and the database (replace supersecret with your root password and secret with the password you will use within your librenms container):

```bash
mysql --host=127.0.0.1 --user=root -psecret -e "create database librenms;"
mysql --host=127.0.0.1 --user=root -psecret -e "GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'%' IDENTIFIED BY 'secret';"
```
