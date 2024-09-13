import logging
import json
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
   message = 'Hello !'
   response = {
        "statusCode": 200,
        "body": json.dumps({'result': message}),
    }
   return response
