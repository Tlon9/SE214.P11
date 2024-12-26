import pymongo
import redis

url = "mongodb://localhost:27017"
client = pymongo.MongoClient(url)
db = client["travelowkey_payment"]

redis_client = redis.StrictRedis(
    host='localhost',
    port=6379,
    db=0,
    decode_responses=True
)
