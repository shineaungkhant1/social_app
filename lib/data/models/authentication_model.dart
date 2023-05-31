import 'dart:io';

import 'package:social_media_app/data/vos/user_vo.dart';

abstract class AuthenticationModel {
  Future<void> login(String email, String password);

  Future<void> register(String email, String userName, String password,File? userProfile);

  bool isLoggedIn();

  Future<UserVO> getUserProfileById(String id);

  UserVO getLoggedInUser();

  Future<void> logOut();
}
