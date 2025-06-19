import boto3
import logging

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Tag to filter instances
TAG_KEY = 'Environment'
TAG_VALUE = 'Dev'

def lambda_handler(event, context):
    logger.info("Stop EC2 Lambda triggered.")

    ec2 = boto3.client('ec2')

    try:
        response = ec2.describe_instances(
            Filters=[
                {'Name': f'tag:{TAG_KEY}', 'Values': [TAG_VALUE]},
                {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        )

        instances_to_stop = [
            instance['InstanceId']
            for reservation in response['Reservations']
            for instance in reservation['Instances']
        ]

        if instances_to_stop:
            logger.info(f"Stopping instances: {instances_to_stop}")
            ec2.stop_instances(InstanceIds=instances_to_stop)
        else:
            logger.info("No running instances found to stop.")

        return {
            'statusCode': 200,
            'body': f"Stopped instances: {instances_to_stop}"
        }

    except Exception as e:
        logger.error(f"Error stopping EC2 instances: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
