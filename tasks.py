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
    "prod": [],
}
UNSAFE_SECRETS = []


@task
def verify_secrets(c, stage):
    """Verify the presence of secrets for all required stage secrets

    --stage <dev|prod>"""

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
