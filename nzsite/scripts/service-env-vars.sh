# AWS always needs this
${export}AWS_DEFAULT_REGION=${aws_region}

# DB Passwords
${export}KANSA_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/kansa/${stage} | jq -r .SecretString)

# Hostnamees
${export}DB_HOSTNAME=${db_hostname}
${export}DB_NAME=${db_name}

# Web Secrets
${export}DEVISE_SECRET=$(aws secretsmanager get-secret-value --secret-id ${devise_secret} | jq -r .SecretString)
${export}JWT_SECRET=$(aws secretsmanager get-secret-value --secret-id ${jwt_secret} | jq -r .SecretString)
${export}SMTP_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${sendgrid_secret} | jq -r .SecretString)
${export}POSTGRES_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${postgres_secret} | jq -r .SecretString)
${export}SIDEKIQ_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${sidekiq_secret} | jq -r .SecretString)

${export}STRIPE_PUBLIC_KEY=$(aws secretsmanager get-secret-value --secret-id ${stripe_secret} | jq -r '.SecretString | fromjson | .pk')
${export}STRIPE_PRIVATE_KEY=$(aws secretsmanager get-secret-value --secret-id ${stripe_secret} | jq -r '.SecretString | fromjson | .sk')
