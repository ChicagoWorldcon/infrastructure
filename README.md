# Getting Started

Ensure you have AWS credentials for your target account. You need AWS_REGION, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY

Set your workspace; if you're working on the production website, then use `prod` otherwise use `dev`:

```
terraform workspace select <workspace>
```

First, you need to ensure the credentials everything else will use are populated:

```
terraform plan -out plan -target module.creds
terraform apply plan
```

Next, go to the [console](https://us-west-2.console.aws.amazon.com/secretsmanager/home?region=us-west-2#/listSecrets) (you may need a different region in there) and actually put secrets into all of the values.
  
After this, you can instantiate the whole account:

```
terraform plan -out plan
terraform apply plan
```
  
Thanks to a weird instance IP bug, you have to run apply a second time to get the right reg host address:

```
terraform apply
```

If you're creating the registration DB for the first time, you need to init it from the reg host. First, shell in:

```
./reg.sh
```

On the reg host, the init scripts are in `/postgres/init.d`. Executing them is a bit of a manual process; I wish I could say I wrote down everything (I think I did?) but it's pretty close to what's there. First you have to run the ones in `chicagoadmin/` to create the `admin` user:

```
for f in /postgres/init.d/chicagoadmin/*.sql; do psql.reg -f $f; done
```

The rest *should* work:

```
for f in /postgres/init.d/admin/*.sql; do psql.admin -f $f; done
```

Seriously watch that for errors, though.

I recommend granting access by the `chicagoadmin` user to `admin` and `api_access` for convenience:

```
psql.admin
api=> grant admin to chicagoadmin;
GRANT ROLE
api=> grant api_access to chicagoadmin;
GRANT ROLE
```

You'll want to create a user for your admin:

```
db
api> INSERT INTO admin.admins VALUES ('YOUR@EMAIL', TRUE, TRUE, TRUE, TRUE, TRUE);
api> INSERT INTO members.keys VALUES ('YOUR@EMAIL', 'AN_ADMIN_PASSWORD');
api> INSERT INTO members.People (legal_name, email, membership, member_number, can_hugo_nominate, can_hugo_vote)
    VALUES ('Admin', 'YOUR@EMAIL', 'NonMember', NULL, false, false)
```

Next, start up the site. You'll need a docker-compose.aws.yml from the registration-api site, which looks like this:
```yaml
version: '2'

# Usage:  docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
# For hints on proper values for environment variables, see docker-compose.override.yml
# DO NOT COMMIT PRODUCTION SECRETS TO ANY REPOSITORY

services:
  nginx:
    environment:
      JWT_SECRET: prod secret
      SERVER_NAME: ${REGISTRATION_DOMAIN_NAME}
      SSL_CERTIFICATE: /etc/letsencrypt/live/chicagoworldcon.org/fullchain.pem
      SSL_CERTIFICATE_KEY: /etc/letsencrypt/live/chicagoworldcon.org/privkey.pem
    ports:
      - "80:80"
      - "443:443"
    restart: always
    volumes:
      - /opt/hugo-packet:/srv/hugo-packet:ro
      - /opt/letsencrypt/etc:/etc/letsencrypt:ro

  hugo:
    environment:
      DATABASE_URL: postgres://hugo:${HUGO_PG_PASSWORD}@${DB_HOSTNAME}/${DB_NAME}
      JWT_SECRET: prod secret
      SESSION_SECRET: prod secret
    restart: always

  members:
    environment:
      DATABASE_URL: postgres://members:${KANSA_PG_PASSWORD}@${DB_HOSTNAME}/${DB_NAME}
      DEBUG: kansa:errors
      SESSION_SECRET: prod secret
      STRIPE_SECRET_APIKEY: ${STRIPE_SECRET_API_KEY}
    restart: always

  art:
    environment:
      DATABASE_URL: postgres://raami:${RAAMI_PG_PASSWORD}@${DB_HOSTNAME}/${DB_NAME}
      SESSION_SECRET: prod secret

  kyyhky:
    environment:
      LOGIN_URI_ROOT:
      SENDGRID_APIKEY:
    restart: always
```

```
./reg.sh
# accept SSH keys as appropriate here; if you've recently replaced the reg EC2 instance, you'll need to clean it up by doing this: `ssh-keygen -R $(terraform output reg_hostname)`

# if this is your first use of the new registration instance, do this:
git clone git clone https://github.com/ChicagoWorldcon/registration-api

# after that, these steps:
. /etc/chicago/service-env.sh
docker-compose -f docker-compose.yml -f docker-compose.aws.yml up

# If that command completes without errors and the site works (see below) then you can run it instead with the `-d` flag to detach:
. /etc/chicago/service-env.sh
docker-compose -f docker-compose.yml -f docker-compose.aws.yml up -d
```

If you see lines like this:

```
WARNING: The REGISTRATION_DOMAIN_NAME variable is not set. Defaulting to a blank string.
WARNING: The HUGO_PG_PASSWORD variable is not set. Defaulting to a blank string.
WARNING: The DB_HOSTNAME variable is not set. Defaulting to a blank string.
WARNING: The DB_NAME variable is not set. Defaulting to a blank string.
WARNING: The KANSA_PG_PASSWORD variable is not set. Defaulting to a blank string.
WARNING: The STRIPE_SECRET_API_KEY variable is not set. Defaulting to a blank string.
WARNING: The RAAMI_PG_PASSWORD variable is not set. Defaulting to a blank string.
```

you forgot to `. /etc/chicago/service-env.sh` :)

Now you should be able to login by opening this URL:

```
open https://$(terraform output site)/login/YOUR@EMAIL/AN_ADMIN_PASSWORD
```

