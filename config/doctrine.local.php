<?php

return array(
    'doctrine' => array(
        'connection' => array(
            // default connection name
            'orm_default' => array(
                'driverClass' => 'Doctrine\DBAL\Driver\PDOPgSql\Driver',
                'params' => array(
                    'host'     => '127.0.0.1',
                    'port'     => '5432',
                    'user'     => 'sharengo',
                    'password' => 'Sharengo1',
                    'dbname'   => 'sharengo',
                )
            ),
            // default Mongo connection name
            'odm_default' => array(
                'server'           => 'localhost',
                'port'             => '27017',
                'user'             => null,
                'password'         => null
            )
        ),        
    ),
);
