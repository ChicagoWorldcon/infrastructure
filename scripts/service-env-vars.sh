# DB Passwords
${export}KANSA_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/kansa/${stage} | jq -r .SecretString)
${export}HUGO_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/hugo/${stage} | jq -r .SecretString)
${export}RAAMI_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/raami/${stage} | jq -r .SecretString)

# Hostnamees
${export}DB_HOSTNAME=${db_hostname}
${export}DB_NAME=${db_name}
${export}REGISTRATION_API_DOMAIN_NAME=${registration_api_domain_name}
${export}REGISTRATION_WWW_DOMAIN_NAME=${registration_www_domain_name}

# Web Secrets
${export}SESSION_SECRET=$(aws secretsmanager get-secret-value --secret-id ${session_secret} | jq -r .SecretString)
${export}JWT_SECRET=$(aws secretsmanager get-secret-value --secret-id ${jwt_secret} | jq -r .SecretString)
${export}STRIPE_SECRET_API_KEY=$(aws secretsmanager get-secret-value --secret-id ${project}/stripe_api_key/${stage} | jq -r .SecretString)
${export}SENDGRID_API_KEY=$(aws secretsmanager get-secret-value --secret-id ${sendgrid_api_key} | jq -r .SecretString)

