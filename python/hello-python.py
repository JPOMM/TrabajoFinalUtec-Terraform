def lambda_handler(event, context):
    message = 'hello {} !'.format(event['key1'])
    return {
        'message' : message
    }