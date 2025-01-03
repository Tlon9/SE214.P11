import pymongo

url = "mongodb://localhost:27017"
client = pymongo.MongoClient(url)
db = client["travelowkey_hotel"]
db_room = client["travelowkey_room"]
db_transaction = client["travelowkey_payment"]
db_flight = client["travelowkey_flight"]
db_area = client["travelowkey_area"]