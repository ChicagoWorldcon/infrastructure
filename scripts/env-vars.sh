export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/${db_username}/${stage} | jq -r .SecretString)
export KANSA_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/kansa/${stage} | jq -r .SecretString)
export HUGO_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/hugo/${stage} | jq -r .SecretString)
export RAAMI_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/raami/${stage} | jq -r .SecretString)
export STRIPE_SECRET_API_KEY=$(aws secretsmanager get-secret-value --secret-id ${project}/stripe_api_key/${stage} | jq -r .SecretString)
export DB_HOSTNAME=${db_hostname}
export DB_NAME=${db_name}
export REGISTRATION_DOMAIN_NAME=${registration_domain_name}

# Other things that can go here eventually are sendgrid API keys, and session secrets
