CREATE ROLE ${db_site_username} WITH CREATEROLE PASSWORD '@@DB_SITE_PASSWORD@@' login;
GRANT ALL PRIVILEGES ON DATABASE "${db_name}" to ${db_site_username};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${db_site_username};
