import 'dart:convert';
import 'package:http/http.dart' as http;

const rootDomain = 'https://us-central1-ntutlab321-23ddb.cloudfunctions.net';
const userPath = rootDomain + '/user';

// get particular staff data
Future<Map<String, String>> getStaffData(String jwtToken) async {
  final http.Response response =
      await http.get(Uri.parse(userPath + '?jwtToken=' + jwtToken));

  if (response.statusCode == 200) {
    final Map data = json.decode(response.body);
    final Map<String, String> userData = {
      'uid': data['uid'],
      'email': data['email'],
      'displayName': data['displayName'],
      'role': data['role'],
    };
    return userData;
  } else {
    print('@api.dart -> getStaffData() -> message = ${response.body}');
    return null;
  }
}
