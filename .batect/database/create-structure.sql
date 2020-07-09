SELECT 'CREATE DATABASE myapp'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'myapp')\gexec

SELECT 'CREATE DATABASE admin'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'admin')\gexec