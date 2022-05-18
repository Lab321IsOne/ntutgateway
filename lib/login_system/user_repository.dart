import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireuser/login_system/api.dart';

// admin/staff logins to firebase via UserRepository
class UserRepository {
  final FirebaseAuth _auth;
  final String _address = "@vghtpe.tw"; // fake domain to fit email
  String _jwtToken; // token for fetching api from api.dart

  // constructor signs out as default status
  UserRepository({
    FirebaseAuth firebaseAuth,
  }) : _auth = (firebaseAuth ?? FirebaseAuth.instance)..signOut();

  // login to firebase, returns loginResult
  Future<Map<String, String>> logInWithUsernameAndPassword({
    String username,
    String password,
  }) async {
    try {
      // login to firebase with email and password
      await _auth.signInWithEmailAndPassword(
        email: username + _address,
        password: password,
      );
      // save jwt token to user repository and get data of user
      _jwtToken = await _auth.currentUser.getIdToken();
      final Map userData = await getStaffData(_jwtToken);
      return userData;
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> logOut() async {
    return await _auth.signOut();
  }

  bool isLoggedIn() {
    print('@user_repository.dart -> isLoggedIn() -> ' +
        _auth.currentUser.toString());
    return _auth.currentUser != null;
  }

  String getJwtToken() {
    if (_auth.currentUser != null) {
      return _jwtToken;
    }
    return null;
  }
}

// init UserRepository instance
final UserRepository userRepository = UserRepository();
