import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../model/Orders.dart';

class PredictionService {
  late Interpreter _interpreter;
  late List<String> _dishVocabulary;

  PredictionService._privateConstructor();
  static final PredictionService _instance = PredictionService._privateConstructor();
  factory PredictionService() => _instance;

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset('AI/dish_time_predictor_model.tflite');

    final String vocabJson = await rootBundle.loadString('AI/mlb_mapping.json');
    _dishVocabulary = List<String>.from(json.decode(vocabJson));
  }

  /// Devuelve el tiempo estimado en minutos
  Future<int> predictPreparationTime(Orders order) async {
    // Crear lista expandida de nombres según cantidad
    final expandedDishes = <String>[];
    for (var od in order.dishes) {
      expandedDishes.addAll(List.filled(od.quantity, od.dish.name));
    }

    // Vector binario de entrada
    final inputVector = List<double>.filled(_dishVocabulary.length, 0.0);
    for (var dishName in expandedDishes) {
      final index = _dishVocabulary.indexOf(dishName);
      if (index != -1) inputVector[index] = 1.0;
    }

    final input = [inputVector]; // input shape [1, vocab_length]
    final output = List.filled(1, 0.0).reshape([1, 1]);

    _interpreter.run(input, output);

    return output[0][0].round(); // Tiempo en minutos
  }
}