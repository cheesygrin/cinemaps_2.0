import 'package:flutter/material.dart';

class TriviaQuestion {
  final String id;
  final String locationId;
  final String question;
  final List<String> options;
  final int correctOption;
  final String explanation;
  final int points;

  TriviaQuestion({
    required this.id,
    required this.locationId,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.explanation,
    required this.points,
  });
}

class Riddle {
  final String id;
  final String locationId;
  final String riddle;
  final String answer;
  final List<String> hints;
  final int points;
  final String successMessage;

  Riddle({
    required this.id,
    required this.locationId,
    required this.riddle,
    required this.answer,
    required this.hints,
    required this.points,
    required this.successMessage,
  });
}

class TriviaService extends ChangeNotifier {
  final Map<String, List<TriviaQuestion>> _locationTrivia = {
    'Central Perk': [
      TriviaQuestion(
        id: 'friends_1',
        locationId: 'Central Perk',
        question: 'What was the name of the Central Perk manager who had a crush on Rachel?',
        options: ['Gunther', 'Terry', 'Eddie', 'Mark'],
        correctOption: 0,
        explanation: 'Gunther worked at Central Perk throughout the series and had an unrequited crush on Rachel.',
        points: 10,
      ),
    ],
    'Ghostbusters HQ': [
      TriviaQuestion(
        id: 'ghostbusters_1',
        locationId: 'Ghostbusters HQ',
        question: 'What is the real-life function of the Ghostbusters HQ building?',
        options: ['Police Station', 'Fire Station', 'Library', 'Post Office'],
        correctOption: 1,
        explanation: 'Hook & Ladder 8 is a working New York City Fire Department station.',
        points: 10,
      ),
    ],
  };

  final Map<String, List<Riddle>> _locationRiddles = {
    'Central Perk': [
      Riddle(
        id: 'friends_riddle_1',
        locationId: 'Central Perk',
        riddle: 'Orange couch and coffee steam,\nWhere six friends lived their dream.\nPhoebe\'s songs would make you laugh,\nWhile Rachel served with gaffe.',
        answer: 'central perk',
        hints: [
          'It\'s a coffee shop',
          'The name suggests it\'s in the middle of something',
          'Think of NYC\'s famous park',
        ],
        points: 20,
        successMessage: 'Congratulations! You\'ve found the iconic coffee shop where the Friends gang spent countless hours!',
      ),
    ],
  };

  final Set<String> _completedTrivia = {};
  final Set<String> _completedRiddles = {};
  int _triviaPoints = 0;

  List<TriviaQuestion> getTriviaForLocation(String locationId) =>
      _locationTrivia[locationId] ?? [];

  List<Riddle> getRiddlesForLocation(String locationId) =>
      _locationRiddles[locationId] ?? [];

  bool isTriviaSolved(String triviaId) => _completedTrivia.contains(triviaId);
  bool isRiddleSolved(String riddleId) => _completedRiddles.contains(riddleId);

  bool checkTriviaAnswer(String triviaId, int selectedOption) {
    final question = _findTriviaById(triviaId);
    if (question == null) return false;

    final isCorrect = selectedOption == question.correctOption;
    if (isCorrect && !_completedTrivia.contains(triviaId)) {
      _completedTrivia.add(triviaId);
      _triviaPoints += question.points;
      notifyListeners();
    }
    return isCorrect;
  }

  bool checkRiddleAnswer(String riddleId, String answer) {
    final riddle = _findRiddleById(riddleId);
    if (riddle == null) return false;

    final isCorrect = answer.trim().toLowerCase() == riddle.answer.toLowerCase();
    if (isCorrect && !_completedRiddles.contains(riddleId)) {
      _completedRiddles.add(riddleId);
      _triviaPoints += riddle.points;
      notifyListeners();
    }
    return isCorrect;
  }

  TriviaQuestion? _findTriviaById(String triviaId) {
    for (final questions in _locationTrivia.values) {
      for (final question in questions) {
        if (question.id == triviaId) return question;
      }
    }
    return null;
  }

  Riddle? _findRiddleById(String riddleId) {
    for (final riddles in _locationRiddles.values) {
      for (final riddle in riddles) {
        if (riddle.id == riddleId) return riddle;
      }
    }
    return null;
  }

  int get totalPoints => _triviaPoints;
  int get completedTriviaCount => _completedTrivia.length;
  int get completedRiddlesCount => _completedRiddles.length;
}
