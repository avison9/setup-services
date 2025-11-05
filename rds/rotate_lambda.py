import json
import os
import boto3
import random
import string
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sm = boto3.client('secretsmanager')
rds = boto3.client('rds')

SECRET_ARN = os.environ['SECRET_ARN']
DB_ID      = os.environ['DB_IDENTIFIER']
REGION     = os.environ['REGION']

def lambda_handler(event, context):
    secret_id = event['SecretId']
    token     = event['ClientRequestToken']
    step      = event['Step']

    logger.info(f"Rotation step: {step}")

    if step == "createSecret":
        new_pwd = ''.join(random.choices(string.ascii_letters + string.digits, k=20))
        current = sm.get_secret_value(SecretId=secret_id, VersionStage='AWSCURRENT')
        current_dict = json.loads(current['SecretString'])
        sm.put_secret_value(
            SecretId=secret_id,
            SecretString=json.dumps({"username": current_dict['username'], "password": new_pwd}),
            VersionStages=['AWSPENDING'],
            ClientRequestToken=token
        )

    elif step == "setSecret":
        logger.info("setSecret: skipping RDS update — Terraform will handle")
        pass

    elif step == "testSecret":
        pass

    elif step == "finishSecret":
        sm.update_secret_version_stage(
            SecretId=secret_id,
            VersionStage='AWSCURRENT',
            MoveToVersionId=token,
            RemoveFromVersionId=event['CurrentVersionId']
        )

    return {'status': 'success'}