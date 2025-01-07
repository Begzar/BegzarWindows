import 'package:begzar_windows/screens/home_screens.dart';
import 'package:begzar_windows/screens/logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:begzar_windows/model/sing_status.dart';
import 'package:begzar_windows/widgets/navigation_rail_widget.dart';
import 'package:begzar_windows/screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:begzar_windows/screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('fa', 'IR'),
          Locale('en', 'US'),
          Locale('zh', 'CH'),
          Locale('ru', 'RU')
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        saveLocale: true,
        startLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final defaultTextStyle =
        TextStyle(fontFamily: 'sm', color: Color(0xffF7FAFF));
    return MaterialApp(
      title: 'Begzar VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          titleLarge: defaultTextStyle,
          titleMedium: defaultTextStyle,
          titleSmall: defaultTextStyle,
          bodyLarge: defaultTextStyle,
          bodyMedium: defaultTextStyle,
          bodySmall: defaultTextStyle,
          labelLarge: defaultTextStyle,
          labelMedium: defaultTextStyle,
          labelSmall: defaultTextStyle,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff192028),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xff192028),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontFamily: 'sm', fontSize: 12),
          unselectedLabelStyle: TextStyle(fontFamily: 'sm', fontSize: 12),
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final singStatus = ValueNotifier<SingStatus>(SingStatus());
  final languageNotifier = ValueNotifier<Locale>(const Locale('en', 'US'));
  final logsNotifier = ValueNotifier<String>('');
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(
        mainSingStatus: singStatus,
        logsNotifier: logsNotifier,
        languageNotifier: languageNotifier,
      ),
      SettingsScreen(
        onLanguageChanged: (Locale newLocale) {
          setState(() {
            languageNotifier.value = newLocale;
            context.setLocale(newLocale);
          });
        },
        onSettingsChanged: () {
          final homePage = pages[0] as HomePage;
          homePage.updateSettings();
        },
      ),
      LogsScreen(
        logs: logsNotifier,
        languageNotifier: languageNotifier,
      ),
      AboutScreen(
        languageNotifier: languageNotifier,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    languageNotifier.value = context.locale;
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: isWideScreen ? Offset.zero : const Offset(1, 0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isWideScreen ? 1 : 0,
              child: isWideScreen
                  ? ValueListenableBuilder<Locale>(
                      valueListenable: languageNotifier,
                      builder: (context, locale, child) {
                        return NavigationRailWidget(
                          selectedIndex: _selectedIndex,
                          singStatus: singStatus,
                          onDestinationSelected: (index) {
                            setState(() => _selectedIndex = index);
                          },
                        );
                      },
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? Container(
              decoration: BoxDecoration(
                color: const Color(0xff192028),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationBar(
                backgroundColor: const Color(0xff192028),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Iconsax.home, color: Colors.grey),
                    selectedIcon: Icon(Iconsax.home, color: Colors.white),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.setting, color: Colors.grey),
                    selectedIcon: Icon(Iconsax.setting, color: Colors.white),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.stickynote, color: Colors.grey),
                    selectedIcon: Icon(Iconsax.stickynote, color: Colors.white),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.info_circle, color: Colors.grey),
                    selectedIcon:
                        Icon(Iconsax.info_circle, color: Colors.white),
                    label: '',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
