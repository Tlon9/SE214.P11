# SE214.P11- Final project

Travelowkey is a mobile application designed to help users find and manage travel itineraries with ease. The app allows users to search for travel options, create and manage custom itineraries, and access real-time data for better planning. <br>
Link demo: https://youtu.be/wjYwdbTvLY0

## Features

- User authentication and authorization
- Search and filter travel itineraries
- Create and manage custom itineraries
- Integration with external APIs for real-time data
- Responsive design for mobile and desktop

## Preparation
1. <a href="https://www.python.org/downloads/">Python</a> 
2. <a href="https://docs.flutter.dev/get-started/install">Flutter</a>
3. <a href="https://dev.mysql.com/downloads/installer/">MySQL</a>
4. <a href="https://www.mongodb.com/try/download/shell">MongoDB Compass</a>
5. <a href="https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/">Redis</a>

## Installation

Follow these steps to set up the project locally:

1. Clone the repository:
    ```bash
   git clone https://github.com/yourusername/SE347.P12.git
   cd travelowkey

2. Create and activate a virtual environment:
    ```bash
   python3 -m venv venv
    source venv/bin/activate

3. Install the required dependencies:
    ```bash
   pip install -r requirements.txt

4. Create database in MongoDBCompass:
- travelowkey_flight/flight: import data/flight/flight_v2.json
- travelowkey_hotel/hotel: import data/hotel/hotel.json
- travelowkey_room/room: import data/hotel/room.json
- travelowkey_payment/transaction
- travelowkey_payment/notification

5. Create database in MySQL:
    ```bash 
    create database mydb;


## Usage
### Backend
1. Flight service:
    ```bash
    cd backend/flight_service/
    python manage.py runserver 8000
2. Hotel service:
    ```bash
    cd backend/hotel_service/
    python manage.py runserver 8008
3. Payment service:
    ```bash
    cd backend/payment_service/
    python manage.py runserver 8080
4. User service:
    ```bash
    sudo service redis-server start
    cd backend/flight_service/
    python manage.py migrate
    python manage.py runserver 8800

### Frontend
     ```bash
     cd frontend/travelowkey
     flutter run