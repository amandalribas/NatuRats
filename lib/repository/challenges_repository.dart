import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/service/challenges_service.dart';

class ChallengesRepository {
  final ChallengesService _challengesService = ChallengesService();

  List<Challenge> challenges = [];

  ChallengesRepository() {
    _initialize();
  }

  Future<void> _initialize() async {
    challenges = await _challengesService.getAll();
  }

  Future<List<Challenge>> getAllChallenges() async {
    try {
      if (challenges.isEmpty) {
        await _initialize();
      }

      return challenges;
    } catch (e) {
      debugPrint("Error on challenges repository, get all challenges: $e");
      return [];
    }
  }

  Future<void> startChallenge(String userId, String challengeId) async {
    try {
      await _challengesService.startChallenge(userId, challengeId);
    } catch (e) {
      debugPrint("Error on challenges repository, start new challenge: $e");
    }
  }

  Future<List<Challenge>> getUsersActiveChallenges(String userId) async {
    try {
      if (challenges.isEmpty) {
        await _initialize();
      }

      final ids = await _challengesService.getAllUsersChallenges(userId);
      return challenges.where((challenge) {
        return ids.contains(challenge.id);
      }).toList();
    } catch (e) {
      debugPrint("Error on challenges repository, get users active challenges: $e");
      return [];
    }
  }

}