from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from .models import flight_collection
from django.http import HttpResponse, JsonResponse
from bson import ObjectId
import requests
from datetime import datetime

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
            #         {"Date": {"$regex": r"-12-"}},  # Match documents where "Date" has '-11-' (November)
            #         {
            #             "$set": {
            #                 "Date": {
            #                     "$function": {
            #                         "body": """
            #                         function(date) {
            #                             return date.replace("-12-", "-01-");
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
        
class getRecommendedFlights(APIView):
    def get(self, request):
        try:
            today = datetime.today().strftime('%d-%m-%Y')
            
            user_id = request.query_params.get('user_id', None)
            user_location = request.query_params.get('user_location', None)
            is_new_user = requests.get(f'http://127.0.0.1:8080/payment/new_user?user_id={user_id}').json()['is_new_user'] if user_id else True
            
            recommendations = []
            
            if is_new_user:
                # New user - recommend cheap flights to popular destinations
                popular_destinations = ["TP HCM (SGN)", "Hà Nội (HAN)", "Đà Nẵng (DAD)"]
                for dest in popular_destinations:
                    flights = list(
                        flight_collection.find({"To": dest, "Date": {"$gte": today}})
                            .sort("Price", 1)
                            .limit(3)
                    )
                    recommendations.extend(flights)
            elif user_location:
                # Known user location - recommend flights starting from user's location
                recommendations = list(
                    flight_collection.find({"From": user_location, "Date": {"$gte": today}})
                        .sort("Price", 1)
                        .limit(10)
                )
            else:
                # Default recommendation logic (trending destinations)
                recommendation_destinations = list(
                    flight_collection.aggregate([
                        {"$match": {"Date": {"$gte": today}}},
                        {"$group": {"_id": "$To", "count": {"$sum": 1}}},
                        {"$sort": {"count": -1}},
                        {"$limit": 10}
                    ])
                )
                sum_of_count = sum([dest['count'] for dest in recommendation_destinations])
                recommendations = []
                for dest in recommendation_destinations:
                    count = int(dest['count'] / sum_of_count * 10)
                    if count > 0:
                        flights = list(
                            flight_collection.find({"To": dest['_id'], "Date": {"$gte": today}})
                                .sort("Price", 1)
                                .limit(count)
                        )
                        recommendations.extend(flights)
            for recommendation in recommendations:
                recommendation['_id'] = str(recommendation['_id'])
            response_data = {
                "recommendations": recommendations
            }
            response = JsonResponse(response_data, status=status.HTTP_200_OK)
            return response
        except Exception as e:
            print(f"Error: {e}")
            return Response({"message": "Failed to get recommended flights."}, status=status.HTTP_400_BAD_REQUEST)
