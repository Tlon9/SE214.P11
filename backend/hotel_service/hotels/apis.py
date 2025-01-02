from itertools import groupby
from rest_framework import status
from datetime import datetime
from .models import hotel_collection, room_collection, transaction_collection, flight_collection, area_collection
from django.http import HttpResponse
from rest_framework.response import Response
from rest_framework.views import APIView
from datetime import datetime, timedelta, timezone
from collections import Counter, defaultdict

class getSearchInfo(APIView):
    def get(self, request):
        try:
            areas = list(hotel_collection.distinct("Area"))
            customerCounts = [1, 2, 3, 4]
            data = {
                "areas": areas,
                "customerCounts": customerCounts
            }
            response = Response(data, status=status.HTTP_200_OK)
            response['Content-Type'] = 'application/json; charset=utf-8'
            # print(areas)
            return response
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get search info."}, status=status.HTTP_400_BAD_REQUEST)
        
# class getHotels(APIView):
#     def get(self, request):
#         try:
#             area = request.query_params.get('area')
#             print(area)
#             hotels = list(hotel_collection.find({
#                 "Area": area,
#             }))

#             for hotel in hotels:
#                 hotel['_id'] = str(hotel['_id'])  # Convert ObjectId to string

#             response = {"hotels": hotels}
#             return Response(response, status=status.HTTP_200_OK)
#         except Exception as e:
#             print(f"Error: {e}")
#             return Response({"message": "Failed to get hotels."}, status=status.HTTP_400_BAD_REQUEST)


class getHotels(APIView):
    def get(self, request):
        try:
            area = request.query_params.get('area')
            offset = int(request.query_params.get('offset', 0))  # Default to 0 if not provided
            limit = int(request.query_params.get('limit', 5))  # Default to 5 if not provided

            # Find hotels by area, with pagination
            hotels = list(hotel_collection.find({
                "Area": area,
            }).limit(offset+limit))  # Apply skip and limit for pagination

            # Convert ObjectId to string for each hotel
            for hotel in hotels:
                hotel['_id'] = str(hotel['_id'])

            response = {
                "hotels": hotels
            }

            return Response(response, status=status.HTTP_200_OK)

        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get hotels."}, status=status.HTTP_400_BAD_REQUEST)
        
class getExploreHotels(APIView):
    def getFlights(self, result_most_frequent_area):
        # Placeholder for the result
        cheapest_flights_per_area = {}
        for item in result_most_frequent_area:
            # Query flights where "To" matches the area, NumSeat > 0, and Date is after today
            area = item[0]
            if area == "Thành phố Hồ Chí Minh":
                area = "TP HCM"
            flights = list(
                flight_collection.aggregate([
                    {
                        "$match": {
                            "To": {"$regex": f"^{area}"},
                            "NumSeat": {"$gt": 0}
                        }
                    },
                    {
                        "$addFields": {
                            "ParsedDate": {
                                "$dateFromString": {
                                    "dateString": "$Date",
                                    "format": "%d-%m-%Y"
                                }
                            }
                        }
                    },
                    {
                        "$match": {
                            "ParsedDate": {"$gt": datetime.now()}
                        }
                    },
                    {
                        "$sort": {"Price": 1}  # Sort by price (ascending)
                    },
                    {
                        "$limit": 4  # Limit to 4 cheapest flights
                    },
                    {
                        "$project": {"_id": 0, "ParsedDate": 0}  # Exclude ParsedDate from the result
                    }
                ])
            )
            
            # Add to the result dictionary
            cheapest_flights_per_area[area] = flights

        # Output the result
        # Combine all flights into a single array
        all_cheapest_flights = [flight for flights in cheapest_flights_per_area.values() for flight in flights]
        return all_cheapest_flights
    def getHotels(self, hotels_id, frequency_hotel_id_list, area_filter):
        # Fetch all hotels from the database that match the area filter
        hotels_cursor = hotel_collection.find(area_filter, {"_id": 0, "Id": 1, "Name": 1, "Area": 1})
        # Convert the cursor to a list of dictionaries
        hotels = list(hotels_cursor)
        # Create a dictionary for easy hotel lookup by hotel_id
        hotels_dict = {hotel["Id"]: hotel for hotel in hotels}

        # Filter and enrich frequency list with hotel details
        filtered_frequency_list = [
            {**item, **hotels_dict.get(item["hotel_id"], {})} for item in frequency_hotel_id_list if item["hotel_id"] in hotels_dict
        ]
        # sorted_frequency_list = sorted(filtered_frequency_list, key=lambda x: x["frequency"], reverse=True)[:5]

        # Group items by area
        grouped_by_area = groupby(filtered_frequency_list, key=lambda x: x["Area"])

        # Create a new list with a maximum of 4 items per area
        top_hotels_per_area = []

        area_frequency = defaultdict(int)

        for area, group in grouped_by_area:
            # Get the top 4 items for each area
            group_list = list(group) 
            top_hotels = sorted(group_list, key=lambda x: x["frequency"], reverse=True)[:4]
            top_hotels_per_area.extend(top_hotels)

            # Convert group iterator to a list
            # Calculate the total frequency for the area
            total_frequency = sum(item["frequency"] for item in group_list)
            area_frequency[area] = total_frequency
        
        result_hotels_id = [
            doc["Id"] for doc in top_hotels_per_area
        ]
        hotels = list(hotel_collection.find({"Id": {"$in": result_hotels_id}}))
        # Convert ObjectId to string for each hotel
        for hotel in hotels:
            hotel['_id'] = str(hotel['_id'])

        # Get the top 4 areas by total frequency
        top_areas = sorted(area_frequency.items(), key=lambda x: x[1], reverse=True)[:5]
        if len(hotels) == 0:
            hotels_cursor = hotel_collection.find(area_filter, {"_id": 0}).sort("price", 1).limit(7) 
            # Convert the cursor to a list of dictionaries
            hotels = list(hotels_cursor)
        return hotels, top_areas
    def get(self, request):
        try:
            area = request.query_params.get('area')
            if area == "TP HCM":
                area = "Thành phố Hồ Chí Minh"
            # Find hotels by area, with pagination
            two_months_ago = datetime.now(timezone.utc) - timedelta(days=60)
            recent_transactions = transaction_collection.find({"created_at": {"$gte": two_months_ago}, "service": {"$regex": "hotel"}}, {"info": 1, "_id": 0})

            # Extract the first part of the 'info' value before the first underscore
            hotels_id = [
                doc["info"].split('_')[0] for doc in recent_transactions if "info" in doc
            ]

            hotel_frequency = Counter(hotels_id)
            frequency_hotel_id_list = sorted(
                [{"hotel_id": hotel_id, "frequency": count} for hotel_id, count in hotel_frequency.items()],
                key=lambda x: x["frequency"],
                reverse=True
            )
            # Build the query filter for area
            area_filter = {} if (area is None or area == "") else {"Area": area}

            hotels, top_areas = self.getHotels(hotels_id, frequency_hotel_id_list, area_filter)

            # result_most_frequent_area = self.getAreas(hotels_id)

            all_cheapest_flights = self.getFlights(top_areas)

            list_areas = list(area_collection.find({}, {"_id": 0}))
            # print(list_areas)

            response = {
                "hotels": hotels,
                "flights": all_cheapest_flights,
                "areas": list_areas,
            }

            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get hotels."}, status=status.HTTP_400_BAD_REQUEST)


def is_room_available(room, new_check_in, new_check_out):
    # Parse dates
    new_check_in = datetime.strptime(new_check_in, "%Y-%m-%d")
    new_check_out = datetime.strptime(new_check_out, "%Y-%m-%d")
    
    # Check if room has bookings
    if "State" not in room or "Bookings" not in room["State"]:
        return True  # No existing bookings, the room is available

    # Check for overlap with existing bookings
    for booking in room["State"]["Bookings"]:
        existing_check_in = datetime.strptime(booking["check_in"], "%Y-%m-%d")
        existing_check_out = datetime.strptime(booking["check_out"], "%Y-%m-%d")
        
        # Overlap condition
        if new_check_in < existing_check_out and new_check_out > existing_check_in:
            return False  # Overlap detected

    return True  # No overlap, room is available

class getRooms(APIView):
    def get(self, request):
        try:
            hotel_id = request.query_params.get('Hotel_id')
            check_in = request.query_params.get('checkInDate')
            check_out = request.query_params.get('checkOutDate')
            
            if not (hotel_id and check_in and check_out):
                return Response(
                    {"message": "Hotel_id, checkInDate, and checkOutDate are required."},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Fetch all rooms for the given hotel_id
            rooms = list(room_collection.find({"Hotel_id": hotel_id}))

            # Filter available rooms
            available_rooms = []
            for room in rooms:
                if is_room_available(room, check_in, check_out):
                    room['_id'] = str(room['_id'])  # Convert ObjectId to string
                    available_rooms.append(room)

            response = {"rooms": available_rooms}
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response(
                {"message": "Failed to get rooms.", "error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        
class getRoom(APIView):
    def get(self, request):
        try:
            room_id = request.query_params.get('room_id')
            room = room_collection.find_one({"Id": room_id})
            if room:
                room['_id'] = str(room['_id'])  # Convert ObjectId to string
                return Response(room, status=status.HTTP_200_OK)
            else:
                return Response({"message": "Room not found."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get room."}, status=status.HTTP_400_BAD_REQUEST)
        
class initializeState(APIView):
    def post(self, request):
        try:
            room_collection.update_many(
                {},  # Match all documents
                {
                    "$set": {
                        "State": {"Bookings": []}  # Initialize State with an empty Bookings array
                    }
                }
            )
            return Response({"message": "State initialized."}, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to initialize state."}, status=status.HTTP_400_BAD_REQUEST)
        
def is_valid_booking(room, new_check_in, new_check_out):
    # Check if room has bookings
    if "State" not in room or "Bookings" not in room["State"]:
        return True  # No existing bookings, it's valid

    # Parse dates
    new_check_in = datetime.strptime(new_check_in, "%Y-%m-%d")
    new_check_out = datetime.strptime(new_check_out, "%Y-%m-%d")

    # Check for overlap with existing bookings
    for booking in room["State"]["Bookings"]:
        existing_check_in = datetime.strptime(booking["check_in"], "%Y-%m-%d")
        existing_check_out = datetime.strptime(booking["check_out"], "%Y-%m-%d")
        
        # Overlap condition
        if new_check_in < existing_check_out and new_check_out > existing_check_in:
            return False  # Overlap detected

    return True  # No overlap

class updateRoom(APIView):
    def put(self, request):
        try:
            room_id = request.query_params.get('room_id')
            hotel_id = request.query_params.get('hotel_id')
            check_in = request.query_params.get('check_in')
            check_out = request.query_params.get('check_out')
            print(room_id, hotel_id, check_in, check_out)
            if not (room_id and hotel_id and check_in and check_out):
                return Response(
                    {"message": "room_id, hotel_id, check_in, and check_out are required."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Fetch the room
            room = room_collection.find_one({"Id": room_id, "Hotel_id": hotel_id})
            if room:
                print('room found') 
            else: 
                print('room not found')
            if not room:
                return Response({"message": "Room not found."}, status=status.HTTP_404_NOT_FOUND)

            # Validate the booking dates
            if not is_valid_booking(room, check_in, check_out):
                return Response(
                    {"message": "Booking overlaps with an existing booking. Please choose different dates."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Update the room's bookings
            if "State" not in room:
                room["State"] = {"Bookings": []}

            room["State"]["Bookings"].append({
                "check_in": check_in,
                "check_out": check_out
            })

            # Update the room in the database
            room_collection.update_one(
                {"Id": room_id},
                {"$set": {"State": room["State"]}}
            )

            return Response({"message": "Room updated successfully."}, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response(
                {"message": "Failed to update room.", "error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )