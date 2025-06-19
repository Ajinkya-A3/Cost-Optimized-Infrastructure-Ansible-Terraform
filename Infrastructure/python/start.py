import boto3
import logging

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Tag to filter instances
TAG_KEY = 'Environment'
TAG_VALUE = 'Dev'

def lambda_handler(event, context):
    logger.info("Start EC2 Lambda triggered.")

    ec2 = boto3.client('ec2')

    try:
        response = ec2.describe_instances(
            Filters=[
                {'Name': f'tag:{TAG_KEY}', 'Values': [TAG_VALUE]},
                {'Name': 'instance-state-name', 'Values': ['stopped']}
            ]
        )

        instances_to_start = [
            instance['InstanceId']
            for reservation in response['Reservations']
            for instance in reservation['Instances']
        ]

        if instances_to_start:
            logger.info(f"Starting instances: {instances_to_start}")
            ec2.start_instances(InstanceIds=instances_to_start)
        else:
            logger.info("No stopped instances found to start.")

        return {
            'statusCode': 200,
            'body': f"Started instances: {instances_to_start}"
        }

    except Exception as e:
        logger.error(f"Error starting EC2 instances: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
