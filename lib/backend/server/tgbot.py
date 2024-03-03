import os
import pyotp
import asyncio
import threading
import pymysql.cursors
from flask import Flask, request
from telethon.sync import TelegramClient, events

# Replace 'API_ID', 'API_HASH', and 'CHANNEL_USERNAME' with your actual values
API_ID = '29027876'
API_HASH = '5a7c567d1189a0f3f3a4f29ab88f919d'
GROUP_ID = -1001897504464
# Channel(id=1897504464, title='CRYPTO BOT BOXES', photo=ChatPhoto(photo_id=5461098230679982537, dc_id=2, has_video=False, stripped_thumb=b"\x01\x08\x08\xcc\xc2\xec'w>\x94QE\x00\x7f"), date=datetime.datetime(2023, 8, 28, 16, 41, 29, tzinfo=datetime.timezone.utc), creator=False, left=True, broadcast=False, verified=False, megagroup=True, restricted=False, signatures=False, min=False, scam=False, has_link=True, has_geo=False, slowmode_enabled=False, call_active=False, call_not_empty=False, fake=False, gigagroup=False, noforwards=False, join_to_send=True, join_request=False, forum=False, stories_hidden=False, stories_hidden_min=True, stories_unavailable=True, access_hash=-4388831035861312581, username='cryptobot_boxes', restriction_reason=[], admin_rights=None, banned_rights=None, default_banned_rights=ChatBannedRights(until_date=datetime.datetime(2038, 1, 19, 3, 14, 7, tzinfo=datetime.timezone.utc), view_messages=False, send_messages=False, send_media=True, send_stickers=True, send_gifs=True, send_games=True, send_inline=True, embed_links=True, send_polls=True, change_info=True, invite_users=False, pin_messages=True, manage_topics=False, send_photos=True, send_videos=True, send_roundvideos=True, send_audios=True, send_voices=True, send_docs=True, send_plain=False), participants_count=None, usernames=[], stories_max_id=None, color=None, profile_color=None, emoji_status=None, level=None)

# Create a lock
tgClientIsRunning = False  # Store the status of the Telegram client
loopIsRunning = False # Store the status of the loop
unFinishedCodes = []  # Store the codes that are not yet finished


# Set up the Flask server
app = Flask(__name__)
# Set up the Telegram client
# client = TelegramClient('CedMain', API_ID, API_HASH)

def get_db_connection():
    return pymysql.connect(
        db="appdata",
        user="avnadmin",
        port=int(18592),
        cursorclass=pymysql.cursors.DictCursor,
        host="xclout-mysql-db-xclout.a.aivencloud.com",
        password=os.environ.get("MYSQL_PASSWORD", ""),
        
    )

def formatMessage(message):
    global loopIsRunning; global unFinishedCodes
    # Check if the message has is all capital letters
    if message.text.isupper():
        # Store it
        code = message.text.strip('`')  # Strip backticks from the start and end
        unFinishedCodes.append(code)

        # Store the code in the database
        if loopIsRunning:
            print(f'Working on a code, now {len(unFinishedCodes)} please wait...')
        else:
            processCodes()
    else:
        print(message.text, message.date)

def processCodes():
    global loopIsRunning; global unFinishedCodes
    loopIsRunning = True
    while unFinishedCodes:
        index = 0
        code = unFinishedCodes[index]
        # with db_lock:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO `cryptorewards_binanceboxes` (`Code`, `DateAdded`) VALUES (%s, CURRENT_TIMESTAMP);",
                    (code,)
                )
                conn.commit()
            # print(f'Stored {code}')
            # Remove the code from the list
            unFinishedCodes.remove(code)
            index += 1
            print(f'Finished {code}, {len(unFinishedCodes)} left')
    loopIsRunning = False

    # Check if there are any remaining codes
    if unFinishedCodes:
        processCodes()

# Verify TOTP and return PostId if valid
def verifyTOTP(code:str):
    secret:str = 'HF4U2TBCN7LZ6QIE7AK6OFHI7LOWA4PG';

    # The first 3 and last 3 characters are the code
    actual_code = code[:3] + code[-3:]
    print(f'Actual code: {actual_code}')

    # Get the last post ID which is everything in the middle
    lastCodeId = int(code[3:-3])

    if pyotp.TOTP(secret).verify(actual_code, valid_window=1): # +- 30 seconds from the current time
        print(f'Verified {actual_code} to access {lastCodeId}')
        return True, lastCodeId
    else:
        print(f'FAILED to verify {actual_code} to access {lastCodeId}')
        return False, None
    
# Get the codes to show
def getCodes(lastCodeId):
    # Check if is Authorised
    isAuthorised, lastCodeId = verifyTOTP(lastCodeId)

    if not isAuthorised: return [], 403
    with get_db_connection() as conn:
        with conn.cursor() as cursor:
            if lastCodeId == 0: cursor.execute(
                    "SELECT * FROM `cryptorewards_binanceboxes` ORDER BY Id DESC LIMIT 100;"
                )
            else: cursor.execute(
                    "SELECT * FROM `cryptorewards_binanceboxes` WHERE Id < %s ORDER BY Id DESC LIMIT 100;",
                    (lastCodeId,)
                )
            results = cursor.fetchall()

    # Convert the date to ISO format
    for result in results:
        result['DateAdded'] = result['DateAdded'].isoformat()
    return results, 200  # Return a tuple with a status code

@app.route('/binancepacketcodes', methods=['GET'])
def codes():
    lastCodeId:str = str(request.args.get('lastCodeId'))
    # If the lastCodeId is not provided or length is 0 , return [], 403
    if not lastCodeId or len(lastCodeId) == 0: return [], 403
    return getCodes(lastCodeId)

def run_telethon_client():
    # Create a new event loop
    loop = asyncio.new_event_loop()
    # Set the new event loop as the event loop for the current thread
    asyncio.set_event_loop(loop)

    # Start the Telethon client
    client = TelegramClient('LycaTelegram', API_ID, API_HASH)
    client.start()
    print(f'Client started as {client.get_me().username}')

    # Set up the Telegram client
    @client.on(events.NewMessage(chats=GROUP_ID))
    async def new_message_handler(event):
    # Process or store the new message
        formatMessage(event.message)

    # Run the client
    client.run_until_disconnected()

# Check if the lock file exists
if not os.path.exists('tgClient.lock'):
    # Create the lock file
    with open('tgClient.lock', 'w') as f:
        f.write('LOCKED')

    # Run the Telethon client
    thread = threading.Thread(target=run_telethon_client, args=())
    thread.start()


if __name__ == '__main__':
    # Start the Telethon client in a separate thread
    # threading.Thread(target=run_telethon_client).start()
    app.run(debug=True, port=8001, host='0.0.0.0')
    # client.start()
    # client.run_until_disconnected()