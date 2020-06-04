export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id ${db_site_secret} | jq -r .SecretString)
