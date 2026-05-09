import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/service/challenges_service.dart';

class ChallengesRepository {
  final ChallengesService _challengesService = ChallengesService();

  List<Challenge> challenges = [];

  Future<List<Challenge>> getAllChallenges() async {
    try {
      if (challenges.isEmpty) {
        challenges = await _challengesService.getAll();
      }
      return challenges;
    } catch (e) {
      debugPrint("Error on challenges repository, get all challenges: $e");
      return [];
    }
  }
}