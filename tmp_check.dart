import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

void main() async {
  final g = GoogleSignIn.instance;
  
  await g.initialize();
  
  final client = await g.authClient(scopes: ['email']);
  // wait, the extension is on `GoogleSignInClientAuthorization`. 
  // Let's guess where that is.
}
var a = GoogleSignInClientAuthorization(accessToken: '');
