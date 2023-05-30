abstract class AuthenticationModel {
  Future<void> login(String email, String password);

  Future<void> register(String email, String userName, String password);
}
