If you don't have an existing MySQL instance running then you can use docker to create one (replace supersecret with your own password):

```bash
docker run \
        --name librenms-mysql \
        -d \
        -e MYSQL_ROOT_PASSWORD=supersecret \
        -P mysql:5.6 --sql-mode=""
```

Now you need to create a user and the database (replace supersecret with your root password and secret with the password you will use within your librenms container):

```bash
docker exec librenms-mysql mysqladmin -u root -psupersecret create test
docker exec librenms-mysql  sh -c  "echo \"GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'%' IDENTIFIED BY 'secret';FLUSH PRIVILEGES;\" | mysql -u root -psupersecret"
```
