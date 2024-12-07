from rest_framework import status
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


class getRooms(APIView):
    def get(self, request):
        try:
            hotel_id = request.query_params.get('Hotel_id')
            rooms = list(room_collection.find({
                "Hotel_id": hotel_id,
            }, {"Id": 0}))

            for room in rooms:
                room['_id'] = str(room['_id'])  # Convert ObjectId to string

            response = {"rooms": rooms}
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get rooms."}, status=status.HTTP_400_BAD_REQUEST)