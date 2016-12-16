<?php

$config['db_host'] = getenv('DB_HOST');
$config['db_user'] = getenv('DB_USER');
$config['db_pass'] = getenv('DB_PASS');
$config['db_name'] = getenv('DB_NAME');
$config['db']['extension'] = 'mysqli';

$config['user'] = 'librenms';
$config['base_url'] = getenv('BASE_URL');
$config['snmp']['community'] = array("public");
$config['auth_mechanism'] = "mysql";
$config['rrd_purge'] = 0;
$config['enable_billing'] = 1;
$config['show_services'] = 1;
$config['update'] = 0;

$config['nagios_plugins']   = "/usr/lib/nagios/plugins"

$config['memcached']['enable'] = filter_var(getenv('MEMCACHED_ENABLE'), FILTER_VALIDATE_BOOLEAN);
$config['memcached']['host'] = getenv('MEMCACHED_HOST');
$config['memcached']['port'] = getenv('MEMCACHED_PORT') ?: 11211;
$config['memcached']['ttl'] = 240;
