from django.db import models
from db_connection import db, db_room, db_transaction, db_flight, db_area

hotel_collection = db["hotel"]
room_collection = db_room["room"]
transaction_collection = db_transaction["transaction"]
flight_collection = db_flight["flight"]
area_collection = db_area["area"]


# Create your models here.
