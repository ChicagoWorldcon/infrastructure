export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id ${db_site_secret} | jq -r .SecretString)
export KANSA_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/kansa/${stage} | jq -r .SecretString)
export HUGO_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/hugo/${stage} | jq -r .SecretString)
export RAAMI_PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${project}/db/${db_name}/raami/${stage} | jq -r .SecretString)
