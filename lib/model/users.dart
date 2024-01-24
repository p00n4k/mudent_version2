class User {
  final int user_id;
  final String user_fullname;
  final String user_email;
  final int user_role_id;

  User({
    required this.user_id,
    required this.user_fullname,
    required this.user_email,
    required this.user_role_id,
  });
}

List<User> parseJsonData(dynamic jsonData) {
  List<User> userList = [];

  for (var userJson in jsonData) {
    User user = User(
      user_id: userJson['user_id'],
      user_fullname: userJson['user_fullname'],
      user_email: userJson['user_email'],
      user_role_id: userJson['user_role_id'],
    );
    userList.add(user);
  }

  return userList;
}
