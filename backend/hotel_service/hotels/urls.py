from django.urls import path
from hotels.apis import *

urlpatterns = [
    path('searchInfo/', getSearchInfo.as_view(), name='searchInfo'),
    # path('addHotel', addFlight.as_view(), name='addFlight'),
    path('results', getHotels.as_view(), name='getHotels'),
    path('results_room', getRooms.as_view(), name='getRooms'),
]