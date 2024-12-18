import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/user_model.dart';


class UserResultRepository {
  final UserDataProvider dataProvider;

  UserResultRepository({required this.dataProvider});

  Future<User> fetchUser() async {
    try {
          // Get all Users from the data provider
      User user = await dataProvider.fetchUser();
      // if (user == null) {
      //   throw Exception("No Users found");
      // }
      return user;
    } catch (e) {
      print("Error: $e"); // Catch and handle the exception
      throw Exception("Error: $e");
    }
  }
}
