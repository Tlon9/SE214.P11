from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from .models import flight_collection
from django.http import HttpResponse
from bson import ObjectId

class getSearchInfo(APIView):
    def get(self, request):
        try:
            departures = list(flight_collection.distinct("From"))
            destinations = list(flight_collection.distinct("To"))
            seatClasses = list(flight_collection.distinct("SeatClass"))
            passengerCounts = [1, 2, 3, 4]
            data = {
                "departures": departures,
                "destinations": destinations,
                "seatClasses": seatClasses,
                "passengerCounts": passengerCounts
            }
            response = Response(data, status=status.HTTP_200_OK)
            response['Content-Type'] = 'application/json; charset=utf-8'
            return response
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get search info."}, status=status.HTTP_400_BAD_REQUEST)

class addFlight(APIView):
    def post(self, request):
        try:
            flight = request.data
            flight_collection.insert_one(flight)
            return Response({"message": "Flight added successfully."}, status=status.HTTP_201_CREATED)
        except:
            return Response({"message": "Failed to add flight."}, status=status.HTTP_400_BAD_REQUEST)
        

class updateFlight(APIView):
    def put(self, request):
        try:
            id = request.query_params.get('id')
            passenger = int(request.query_params.get('passenger'))
            flight_collection.update_one(
                {"Id": id},
                {"$inc": {'NumSeat': -passenger}}
            )
            return Response({"message": "Flight updated successfully."}, status=status.HTTP_200_OK)
        except:
            return Response({"message": "Failed to update flight."}, status=status.HTTP_400_BAD_REQUEST)
    

class getFlights(APIView):
    def get(self, request):
        try:
            departure = request.query_params.get('departure')
            destination = request.query_params.get('destination')
            seatClass = request.query_params.get('seatClass')
            passengerCount = request.query_params.get('passengers')
            date = request.query_params.get('date').split('-')[::-1]  
            date = '-'.join(date) 
            print(departure, destination, seatClass, passengerCount, date)
            flights = list(flight_collection.find({
                "From": departure,
                "To": destination,
                "SeatClass": seatClass,
                "Date": date
            }, {"Date": 0, "NumSeat": 0, "SeatClass": 0}))

            for flight in flights:
                flight['_id'] = str(flight['_id']) # Convert ObjectId to string

            response = {"flights": flights}
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get flights."}, status=status.HTTP_400_BAD_REQUEST)
        
class getFlightId(APIView):
    def get(self, request):
        try:
            flight_id = request.query_params.get('id')
            flight = flight_collection.find_one({"Id": flight_id})
            response = {
                "From": flight['From'],
                "To": flight['To'],
                "Date": flight['Date'],
                "DepartureTime": flight['DepartureTime'],
                "ArrivalTime": flight['ArrivalTime'],
                "SeatClass": flight['SeatClass'],
            }
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get flight."}, status=status.HTTP_400_BAD_REQUEST)
        
class updateDB(APIView):
    def put(self, request):
        try:
            # flight_collection.update_many(
            #         {"Date": {"$regex": r"-11-"}},  # Match documents where "Date" has '-11-' (November)
            #         {
            #             "$set": {
            #                 "Date": {
            #                     "$function": {
            #                         "body": """
            #                         function(date) {
            #                             return date.replace("-11-", "-12-");
            #                         }
            #                         """,
            #                         "args": ["$Date"],
            #                         "lang": "js"
            #                     }
            #                 }
            #             }
            #         }
            #     )
            flight_collection.delete_many({})
            return Response({"message": "Flight updated successfully."}, status=status.HTTP_200_OK)
        except:
            return Response({"message": "Failed to update flight."}, status=status.HTTP_400_BAD_REQUEST)