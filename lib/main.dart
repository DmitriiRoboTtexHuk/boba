import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewWithLoader(),
    );
  }
}

class WebViewWithLoader extends StatefulWidget {
  @override
  _WebViewWithLoaderState createState() => _WebViewWithLoaderState();
}

class _WebViewWithLoaderState extends State<WebViewWithLoader>
    with SingleTickerProviderStateMixin {
  late InAppWebViewController webViewController;
  bool isLoading = true; // Указывает, отображается ли загрузчик
  late Timer backgroundTimer; // Таймер для смены цвета фона
  Color backgroundColor = Colors.blue; // Начальный цвет фона
  late AnimationController fruitController;
  List<Fruit> fallingFruits = []; // Список падающих фруктов
  final List<IconData> fruitIcons = [
    Icons.apple,
    Icons.cake,
    Icons.local_pizza,
    Icons.local_drink, // Иконки фруктов/еды
  ];

  @override
  void initState() {
    super.initState();

    // Таймер для смены цвета фона каждые 200 миллисекунд
    backgroundTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!isLoading) {
        timer.cancel(); // Остановить таймер, если загрузка завершена
      } else {
        setState(() {
          backgroundColor = Color((Random().nextDouble() * 0xFFFFFF).toInt())
              .withOpacity(1.0); // Генерация случайного цвета
        });
      }
    });

    // Анимация падения фруктов
    fruitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      if (isLoading) {
        setState(() {
          fallingFruits.add(Fruit(
            icon: fruitIcons[Random().nextInt(fruitIcons.length)],
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
            position: Random().nextDouble(),
          ));
        });
      }
    });

    fruitController.repeat();
  }

  @override
  void dispose() {
    backgroundTimer.cancel();
    fruitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Загрузчик
          if (isLoading)
            Stack(
              children: [
                // Меняющийся цвет фона
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: backgroundColor,
                ),
                // Анимация падающих фруктов
                ...fallingFruits.map((fruit) => FallingFruitWidget(fruit: fruit)),
              ],
            ),
          // WebView
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://swift-bonan.online/sb-ios/"),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false; // Загрузка завершена, скрываем загрузчик
              });
            },
          ),
        ],
      ),
    );
  }
}

// Класс для фруктов
class Fruit {
  final IconData icon;
  final Color color;
  final double position; // Позиция по горизонтали

  Fruit({required this.icon, required this.color, required this.position});
}

// Виджет для отображения падающих фруктов
class FallingFruitWidget extends StatelessWidget {
  final Fruit fruit;

  const FallingFruitWidget({required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: Random().nextDouble() * MediaQuery.of(context).size.height,
      left: fruit.position * MediaQuery.of(context).size.width,
      child: Icon(
        fruit.icon,
        color: fruit.color,
        size: 30.0,
      ),
    );
  }
}