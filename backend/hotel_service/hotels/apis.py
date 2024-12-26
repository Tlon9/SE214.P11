from rest_framework import status
from datetime import datetime
from .models import hotel_collection, room_collection
from django.http import HttpResponse
from rest_framework.response import Response
from rest_framework.views import APIView

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