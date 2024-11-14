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
            }, {"Id": 0, "Date": 0, "NumSeat": 0, "SeatClass": 0}))

            for flight in flights:
                flight['_id'] = str(flight['_id'])  # Convert ObjectId to string

            response = {"flights": flights}
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get flights."}, status=status.HTTP_400_BAD_REQUEST)