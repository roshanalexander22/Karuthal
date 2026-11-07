class AuthRepository {
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
  Future<bool> register(String email, String password, String fullName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
