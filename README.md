# Getting Started

Ensure you have AWS credentials for your target account. You need AWS_REGION, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY

## Terraform setup

This site requires terraform 0.14. You'll want to initialize the state:

### modules

```
terraform init
```

That will install all of the modules.

## Inputs

The variables you'll need probably differ from Chicago's. Currently all inputs
and defaults are defined in `vars.tf` but you can override some or all of these
by createing a variables file and including it when planning.

## Order of creation

This site probably has a bad chicken and egg issue with credentials; getting the
actual AWS secretsmanager secrets used for the DB password and site session
secrets.

```
terraform plan -out plan -target module.prod-creds -target module.dev-creds
terraform apply plan
```

Next, go to the [console](https://us-west-2.console.aws.amazon.com/secretsmanager/home?region=us-west-2#/listSecrets) (you may need a different region in there) and actually put secrets into all of the values.

After this, you can instantiate the whole account:

```
terraform plan -out plan
terraform apply plan
```

To log into the hosts:

dev:

```
ssh $(terraform output -json reg_public_dns | jq -r ".dev")
```

prod:

```
ssh $(terraform output -json reg_public_dns | jq -r ".prod")
```

## Initializing the DB

One time per reg stage, you need to do this:

```
# psql.admin postgres
postgres=> CREATE ROLE <stage-site-user> WITH LOGIN CREATEDB PASSWORD '<stage-site-password>';
postgres=> \q

# cd /opt/chicago/app
# sudo docker-compose run web bundle exec rake db:create db:structure:load db:migrate db:seed:chicago:production
```
