from django.urls import path
from flights.apis import *

urlpatterns = [
    path('searchInfo/', getSearchInfo.as_view(), name='searchInfo'),
    path('addFlight', addFlight.as_view(), name='addFlight'),
    path('results', getFlights.as_view(), name='getFlights'),
]