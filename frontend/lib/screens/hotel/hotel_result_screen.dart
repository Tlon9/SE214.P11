import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/hotel/hotel_results/HotelResultBloc.dart';
import 'package:travelowkey/bloc/hotel/hotel_results/HotelResultEvent.dart';
import 'package:travelowkey/bloc/hotel/hotel_results/HotelResultState.dart';
import 'package:travelowkey/repositories/hotelResult_repository.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/hotel_model.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HotelResultScreen extends StatelessWidget {
  final String area;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int customers;

  const HotelResultScreen({
    required this.area,
    required this.checkInDate,
    required this.checkOutDate,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    final searchInfo = {
      'area': area,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'customers': customers.toString(),
    };
    // int offset = 0; // Start offset at 0
    // final int limit = 5; // Load 5 items at a time
    // final apiUrl =
    //     'http://10.0.2.2:8000/hotels/results?area=${Uri.encodeComponent(searchInfo['area']!)}';

    return BlocProvider(
        create: (context) => HotelResultBloc(
            repository: HotelResultRepository(
                dataProvider: HotelResultDataProvider(
                    ))) // Pass the apiUrl to the data provider
          ..add(
            LoadHotelResults(
              searchInfo: searchInfo,
            ),
          ),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                '$area\n${checkInDate.toString().substring(0, 10)} -> ${checkOutDate.toString().substring(0, 10)}\n$customers khách',
                // maxLines: 2,
              ),
              actions: [
                IconButton(
                  icon:
                      Icon(Icons.notifications, color: Colors.white, size: 30),
                  onPressed: () {
                    // Navigate to notification screen
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, const Color(0xFF007AFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      // Sort and Filter Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            icon: Icon(Icons.filter_list),
                            label:
                                Text("Bộ lọc", style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              // Open filter options and send event to bloc
                              final filterOption = await showFilterDialog(context);
                              if (filterOption != null) {
                                // print(filterOption);
                                BlocProvider.of<HotelResultBloc>(context).add(
                                  ApplyFilter(filterOption, searchInfo),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            icon: Icon(Icons.sort),
                            label: Text(
                              "Sắp xếp",
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () async {
                              // Open sort options and send event to bloc
                              String? sortOption =
                                  await showSortDialog(context);
                              if (sortOption != null) {
                                // print(sortOption);
                                BlocProvider.of<HotelResultBloc>(context).add(
                                  ApplySort(sortOption, searchInfo),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Hotel Result List
                      Expanded(
                        child: BlocBuilder<HotelResultBloc, HotelResultState>(
                          builder: (context, state) {
                            if (state is HotelResultLoading) {
                              return Center(child: CircularProgressIndicator());
                            } else if (state is HotelResultLoaded) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                // child: ListView.builder(
                                //   itemCount: state.hotels.length,
                                //   itemBuilder: (context, index) {
                                //     final hotel = state.hotels[index];
                                //     return HotelCard(
                                //         hotel: hotel, customers: customers);
                                //   },
                                // ),
                                child: LazyLoadScrollView(
                                  onEndOfPage: () async {
                                    await Future.delayed(Duration(seconds: 2));
                                    // Trigger loading more hotels on reaching the end
                                    BlocProvider.of<HotelResultBloc>(context).add(LoadMoreHotels(
                                      searchInfo: searchInfo,
                                      // offset: currentState.offset!,
                                    ));
                                  },
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(bottom: 10), // Padding at the bottom to avoid content touching the bottom
                                    itemCount: state.hotels.length,
                                    itemBuilder: (context, index) {
                                      final hotel = state.hotels[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding around each hotel card
                                        child: HotelCard(
                                          hotel: hotel, 
                                          customers: customers,
                                          checkinDate: checkInDate,
                                          checkoutDate: checkOutDate,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            } else if (state is HotelResultError) {
                              return Center(child: Text(state.message));
                            }
                            return Center(child: Text("No Hotels found."));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}


Future<Map<String, dynamic>?> showFilterDialog(BuildContext context) async {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final Set<int> selectedStars = {}; // Track selected star ratings

  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Filter Options',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                // Min and Max Price Inputs in Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min Price',
                          border: OutlineInputBorder(),
                          prefixText: 'VND ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('-', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Price',
                          border: OutlineInputBorder(),
                          prefixText: 'VND ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Multi Star Rating Selection
                const Text(
                  "Đánh giá sao",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final starCount = index + 1;
                    return GestureDetector(
                      onTap: () {
                        // Toggle star selection
                        if (selectedStars.contains(starCount)) {
                          selectedStars.remove(starCount);
                        } else {
                          selectedStars.add(starCount);
                        }
                        (context as Element).markNeedsBuild(); // Trigger rebuild
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: selectedStars.contains(starCount)
                                  ? Colors.amber.shade100
                                  : Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                Text(
                                  "$starCount",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "(${(100 / starCount).toInt()})", // Example count
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Close dialog
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Validate price input
                        String? minPrice = minPriceController.text.trim();
                        String? maxPrice = maxPriceController.text.trim();
                        if (minPrice.isEmpty || maxPrice.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please enter both minimum and maximum prices'),
                            ),
                          );
                          return;
                        }
                        int min = int.tryParse(minPrice) ?? 0;
                        int max = int.tryParse(maxPrice) ?? 0;
                        if (max < min) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Maximum price must be greater than or equal to minimum price'),
                            ),
                          );
                          return;
                        }

                        // Pass selected filters
                        Navigator.pop(context, {
                          'minPrice': minPrice,
                          'maxPrice': maxPrice,
                          'selectedStars': selectedStars.toList(),
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<String?> showSortDialog(BuildContext context) async {
  final sortOptions = [
    'price_asc',
    'price_desc',
  ];
  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Choose a sort option'),
        children: sortOptions.map((option) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, option); // Return selected option
            },
            child: Text(option),
          );
        }).toList(),
      );
    },
  );
}

String formatPrice(String price) {
  // Parse the string to an integer
  int value = int.tryParse(price) ?? 0;

  // Format the integer with a thousand separator
  return NumberFormat("#,###", "en_US").format(value).replaceAll(",", ".");
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final int customers;
  final DateTime checkinDate;
  final DateTime checkoutDate;

  const HotelCard({required this.hotel, required this.customers, required this.checkinDate, required this.checkoutDate});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/room_result',
          arguments: {
            'hotel': hotel as Hotel,
            'hotel_name': hotel.name,
            'customers': customers,
            'checkInDate': checkinDate,
            'checkOutDate': checkoutDate,
          },
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.white,
        elevation: 5,
        shadowColor: Colors.black,
        child: SizedBox(
          // width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                child: Image.network(
                  hotel.img.toString(), // Replace with your image URL
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 120,
                      color: Colors.grey, // Background color for the placeholder
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ), // Placeholder widget
                    );
                  },
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "${hotel.name.toString()}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    // Star Rating
                    Row(
                      children: List.generate(
                        hotel.rating!.toInt(),
                        (index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 20, color: Colors.grey),
                        SizedBox(width: 5),
                        Expanded( // Wrap the Text in an Expanded to constrain it
                          child: Text(
                            "${hotel.address.toString()}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                            maxLines: 2, // Limit to 2 lines
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight, // Price
                      child:Text(
                        "VND ${formatPrice(hotel.price.toString())}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}