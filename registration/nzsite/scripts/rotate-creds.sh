#!/bin/bash
export AWS_DEFAULT_REGION=us-west-2
cat<<EOF > /opt/chicago/etc/creds.env
DEVISE_SECRET=$(aws secretsmanager get-secret-value --secret-id ${devise_secret} | jq -r .SecretString)
JWT_SECRET=$(aws secretsmanager get-secret-value --secret-id ${jwt_secret} | jq -r .SecretString)
SMTP_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${sendgrid_secret} | jq -r .SecretString)
POSTGRES_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${postgres_secret} | jq -r .SecretString)
SIDEKIQ_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${sidekiq_secret} | jq -r .SecretString)
STRIPE_PUBLIC_KEY=$(aws secretsmanager get-secret-value --secret-id ${stripe_secret} | jq -r '.SecretString | fromjson | .pk')
STRIPE_PRIVATE_KEY=$(aws secretsmanager get-secret-value --secret-id ${stripe_secret} | jq -r '.SecretString | fromjson | .sk')
EOF
chmod 600 /opt/chicago/etc/creds.env
