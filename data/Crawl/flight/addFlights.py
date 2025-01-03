import json
from datetime import datetime, timedelta

# Read the existing flights data from the JSON file
with open('path/to/flights.json', 'r', encoding='utf-8') as file:
    flights = json.load(file)

# Function to create new flight entries for given dates
def create_new_flights(base_flight, new_dates):
    new_flights = []
    for date in new_dates:
        new_flight = base_flight.copy()
        new_flight['Date'] = date.strftime('%d-%m-%Y')
        new_flight['Id'] = f"{base_flight['Id'][:2]}{date.strftime('%d%m%Y')}{base_flight['Id'][10:]}"
        new_flights.append(new_flight)
    return new_flights

# Base date and new dates to create
base_date = datetime.strptime('06-01-2024', '%d-%m-%Y')
new_dates = [base_date - timedelta(days=i) for i in range(1, 6)]

# Create new flight entries
new_flight_entries = []
for flight in flights:
    if flight['Date'] == '06-01-2024':
        new_flight_entries.extend(create_new_flights(flight, new_dates))

# Append new flight entries to the existing flights data
flights.extend(new_flight_entries)

# Write the updated flights data back to the JSON file
with open('path/to/flights_ver2.json', 'w', encoding='utf-8') as file:
    json.dump(flights, file, ensure_ascii=False, indent=4)