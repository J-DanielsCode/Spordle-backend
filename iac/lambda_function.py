import json
import boto3
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Attr
from decimal import Decimal
from boto3.dynamodb.conditions import Key

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='eu-west-2')
dynamodb_table = dynamodb.Table('nba-player-data')

status_check_path = '/status'
players_path = '/players'

def lambda_handler(event, context):
    print('Request event: ', event)
    response = None
   
    try:
        http_method = event.get('httpMethod')
        path = event.get('path')
        raw_body = event.get('body')
        body = json.loads(raw_body if raw_body is not None else '{}')
        path_params = event.get('pathParameters')

        # -- status check --
        if http_method == 'GET' and path == status_check_path:
            response = build_response(200, 'Service is operational')

        # -- players endpoints --
        elif path.startswith(players_path):

            if http_method == 'GET':
                if path_params and 'player_id' in path_params:
                    response = get_player(path_params['player_id'])
                else:
                    response = get_all_players()

            elif http_method == 'POST' and path == players_path:
                response = create_player(body)

            elif http_method == 'PATCH' and path_params and 'player_id' in path_params:  
                response = update_player(path_params['player_id'], body)

            elif http_method == 'DELETE' and path_params and 'player_id' in path_params:
                response = delete_player(path_params['player_id'])
        else:
            response = build_response(404, f"Path {path} not found")

    except Exception as e:
        print('Error:', e)
        response = "Something went wrong!"
   
    return response

# -- CRUD Helpers --
def get_player(player_id: int):
    try: 
        print('Player ID:', player_id)
        # result = dynamodb_table.get_item(Key={'player_id': int(player_id)})
        result = dynamodb_table.query(
            IndexName="player_id-index",
            KeyConditionExpression=Key("player_id").eq(int(player_id)),
        )
        print('Result:', result)
        if 'Items' in result:
            return build_response(200, result['Items'])
        return build_response(404, {'error': f"Player with ID {player_id} not found"})
    except ClientError as e:
        print('Error:', str(e))
        return handle_dynamo_error(e, 'Failed to fetch player')


def get_all_players():
    try:
        response = dynamodb_table.scan()
        items = response.get('Items', [])
        return build_response(200, items)
    except ClientError as e:
        return handle_dynamo_error(e, 'Failed to fetch players')


def create_player(body):
    try:
        if 'player_id' not in body:
            return build_response(400, {'error': 'player_id is required'})
        dynamodb_table.put_item(Item=body)
        return build_response(201, {'message': f"{body['player_id']} created successfully"})
    except ClientError as e:
        return handle_dynamo_error(e, 'Failed to create player')

def update_player(player_id, body):
    if not body:
        return build_response(400, {'error': 'No attributes to update'})

    try:
        update_expression = "SET " + ", ".join(f"#{k} = :{k}" for k in body.keys())
        expression_attribute_names = {f"#{k}": k for k in body.keys()}
        expression_attribute_values = {f":{k}": v for k, v in body.items()}

        response = dynamodb_table.update_item(
            Key={'player_id': player_id},
            UpdateExpression=update_expression,
            ExpressionAttributeNames=expression_attribute_names,
            ExpressionAttributeValues=expression_attribute_values,
            ReturnValues='UPDATED_NEW'
        )

        return build_response(200, {
            'message': f'Player {player_id} updated successfully',
            'updated_attributes': response.get('Attributes', {})
        })
    except ClientError as e:
        return handle_dynamo_error(e, 'Failed to update player')

def delete_player(player_id):
    try:
        response = dynamodb_table.delete_item(
            Key={'player_id': player_id},
            ConditionExpression=Attr('player_id').exists()  # Only delete if item exists
        )
        return build_response(200, {'message': f"Player {player_id} deleted successfully"})
    except ClientError as e:
        return handle_dynamo_error(e, 'Failed to delete player')

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            # Check if it's an int or a float
            if obj % 1 == 0:
                return int(obj)
            else:
                return float(obj)
        # Let the base class default method raise the TypeError
        return super(DecimalEncoder, self).default(obj)

def build_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps(body, cls=DecimalEncoder)
    }

def handle_dynamo_error(e, message):
    print("DynamoDB error:", e)
    # return build_response(500, {'error': message, 'details': e.response['Error']['Message']})
    return "Something has gone wrong here!"
