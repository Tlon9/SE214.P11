import pymongo

url = "mongodb://localhost:27017"
client = pymongo.MongoClient(url)
db = client["travelowkey_hotel"]
db_room = client["travelowkey_room"]