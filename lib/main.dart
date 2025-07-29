import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/data/datasources/event_remote_datasource.dart';
import 'package:rovify/data/firebase/firebase_initializer.dart';
import 'package:rovify/data/repositories/auth_repository_impl.dart';
import 'package:rovify/data/repositories/event_repository_impl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rovify/domain/repositories/nft_repository.dart';
import 'package:rovify/domain/usecases/create_event.dart';
import 'package:rovify/domain/usecases/fetch_events.dart';
import 'package:rovify/domain/usecases/sign_in_user.dart';
import 'package:rovify/domain/usecases/sign_up_user.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/event/event_bloc.dart';
import 'package:rovify/presentation/blocs/event/event_event.dart';
import 'package:rovify/presentation/blocs/event/event_form_bloc.dart';
import 'package:rovify/presentation/blocs/nft/nft_bloc.dart';
import 'package:rovify/presentation/screens/home/pages/event_form_page.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final authRepository = AuthRepositoryImpl(firebaseAuth, firestore);
  
  final eventRemoteDataSource = EventRemoteDataSourceImpl(
    firestore: firestore,
    storage: storage,
  );

  final eventRepository = EventRepositoryImpl(
    firestore,
    remoteDataSource: eventRemoteDataSource,
  );

  final signUpUser = SignUpUser(authRepository);
  final signInUser = SignInUser(authRepository);

  final createEvent = CreateEvent(eventRepository);
  final fetchEvents = FetchEvents(eventRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TrendingNftBloc(nftRepository: NftRepository())),
        BlocProvider(
          create: (_) => AuthBloc(
            signUpUser: signUpUser,
            signInUser: signInUser,
            firebaseAuth: firebaseAuth,
          ),
        ),
        BlocProvider(
          create: (_) => EventBloc(
            createEventUseCase: createEvent,
            fetchEventsUseCase: fetchEvents,
          )..add(FetchEventsRequested()), // fetch events at startup
        ),
        BlocProvider(
          create: (context) => EventFormBloc(),
          child: EventFormScreen(),
        )
      ],
      child: const RovifyApp(),
    ),
  );
}

class RovifyApp extends StatelessWidget {
  const RovifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rovify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}