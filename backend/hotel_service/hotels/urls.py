from django.urls import path
from hotels.apis import *

urlpatterns = [
    path('searchInfo/', getSearchInfo.as_view(), name='searchInfo'),
    # path('addHotel', addFlight.as_view(), name='addFlight'),
    path('results', getHotels.as_view(), name='getHotels'),
    path('results_room', getRooms.as_view(), name='getRooms'),
    path('initializeState', initializeState.as_view(), name='initializeState'),
    path('updateRoom', updateRoom.as_view(), name='updateRoom'),
    path('getRoom', getRoom.as_view(), name='getRoom'),
    path('recommendation', getRecommendedHotels.as_view(), name='getRecommendations'),
    path('getExploreHotel', getExploreHotels.as_view(), name='getExploreHotel'),
]