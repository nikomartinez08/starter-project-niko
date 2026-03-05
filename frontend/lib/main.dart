import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'config/theme/app_themes.dart';
import 'core/services/deep_link_service.dart';
import 'features/streaming/domain/usecases/get_stream_by_id_usecase.dart';
import 'injection_container.dart' as di;
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_event.dart';
import 'features/streaming/presentation/bloc/streaming_bloc.dart';
import 'features/streaming/presentation/bloc/streaming_event.dart';
import 'injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializacion de Supabase para Storage
  await Supabase.initialize(
    url: 'https://cbnsxizfdiksuhiuzkbm.supabase.co',
    anonKey: 'sb_publishable_c-nCjnsHBUrSQEpRMXl5fQ_AQcj5HNb',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _deepLinkService = DeepLinkService(
      navigatorKey: _navigatorKey,
      getStreamByIdUseCase: di.sl<GetStreamByIdUseCase>(),
    );
    _deepLinkService.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleState changed to: \$state');
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl()..add(const GetArticles()),
        ),
        BlocProvider<FavoritesBloc>(
          create: (context) => sl()..add(GetFavorites()),
        ),
        BlocProvider<StreamingBloc>(
          create: (context) => sl()..add(const LoadActiveStreams()),
        ),
      ],
      child: MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: theme(),
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          home: const AuthGate(),
        ),
    );
  }
}

