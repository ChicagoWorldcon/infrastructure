import json
from pathlib import Path
from getpass import getpass
from invoke import task
import boto3
from botocore.exceptions import ClientError


def get_pass(secret, stage):
    return getpass(f"Enter a password to use for [{stage}] {secret}: ")


def get_sendgrid_key(secret, stage):
    return getpass(f"Enter the {stage} Sendgrid API key: ")


def get_stripe_keys(secret, stage):
    pk = getpass(f"Enter the {stage} stripe publishable key: ")
    sk = getpass(f"Enter the {stage} stripe secret key: ")
    return json.dumps({"sk": sk, "pk": pk})


SECRETS = {
    "dev": {
        "Chicon8/tokens/session/dev": get_pass,
        "Chicon8/tokens/jwt/dev": get_pass,
        "Chicon8/sendgrid_api_key/dev": get_sendgrid_key,
        "Chicon8/db/registration_dev/registration_dev_admin/dev": get_pass,
        "Chicon8/sidekiq_password/dev": get_pass,
        "Chicon8/stripe_api_key/dev": get_stripe_keys,
    },
    "staging": {
        "Chicon8/tokens/session/staging": get_pass,
        "Chicon8/tokens/jwt/staging": get_pass,
        "Chicon8/sendgrid_api_key/staging": get_sendgrid_key,
        "Chicon8/db/registration_dev/registration_dev_admin/staging": get_pass,
        "Chicon8/sidekiq_password/staging": get_pass,
        "Chicon8/stripe_api_key/staging": get_stripe_keys,
    },
    "prod": {
        "Chicon8/db/registration/registration_admin/prod": get_pass,
        "Chicon8/tokens/jwt/prod": get_pass,
        "Chicon8/sendgrid_api_key/prod": get_pass,
        "Chicon8/tokens/session/prod": get_pass,
        "Chicon8/sidekiq_password/prod": get_pass,
        "Chicon8/stripe_api_key/prod": get_stripe_keys,
    },
}
UNSAFE_SECRETS = []


@task
def verify_secrets(c, stage):
    """Verify the presence of secrets for all required stage secrets

    --stage <dev|staging|prod>"""

    client = boto3.client("secretsmanager")

    missing_secrets = []

    for secret_name in SECRETS[stage]:
        secret = client.describe_secret(SecretId=secret_name)
        try:
            client.get_secret_value(SecretId=secret_name, VersionStage="AWSCURRENT")
        except ClientError as error:
            if error.response["Error"]["Code"] == "ResourceNotFoundException":
                missing_secrets.append(secret_name)

    for secret in missing_secrets:
        print(f"Missing {secret}")


@task
def rotate_secret(c, stage, secret_name):
    """Rotate a credential"""
    assert secret_name not in UNSAFE_SECRETS, "Can't rotate an unsafe secret"
    assert secret_name in SECRETS[stage], "Can't rotate an unconfigured secret"

    secret_method = dict(SECRETS[stage])[secret_name]

    client = boto3.client("secretsmanager")
    secret_string = secret_method(secret_name, stage)
    client.put_secret_value(SecretId=secret_name, SecretString=secret_string)


@task
def plan_site(c):
    """Generate a plan for the main site"""
    c.run("terraform plan -out main-site.plan")


@task
def apply_site(c):
    """Execute an update to the main infrastructure"""
    c.run("terraform apply main-site.plan")


@task(plan_site, apply_site)
def update_site(c):
    """Perform a full update of the site"""
    ...


@task
def plan_dns(c):
    """Plan DNS changes"""
    with c.cd("dns"):
        c.run("terraform plan -out dns.plan")


@task
def apply_dns(c):
    """Apply DNS changes"""
    with c.cd("dsn"):
        c.run("terraform apply dns.plan")
