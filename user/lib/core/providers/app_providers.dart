import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

final appProviders = <Provider>[
  Provider<AuthService>(create: (_) => AuthService()),
  Provider<FirestoreService>(create: (_) => FirestoreService()),
];
