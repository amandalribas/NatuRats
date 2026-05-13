import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/service/challenges_service.dart';

class ChallengesRepository {
  final ChallengesService _challengesService = ChallengesService();

  List<Challenge> _challenges = [];

  ChallengesRepository();

  Future<void> _fetchAllChallenges() async {
    try {
      _challenges = await _challengesService.getAll();
    } catch (e) {
      debugPrint("Error on challenges repository, get all challenges: $e");
    }
  }

  Future<void> startChallenge(String userId, String challengeId) async {
    try {
      await _challengesService.startChallenge(userId, challengeId);
    } catch (e) {
      debugPrint("Error on challenges repository, start new challenge: $e");
      rethrow;
    }
  }

  Future<List<Challenge>> getChallenges() async {
    if (_challenges.isEmpty) {
      await _fetchAllChallenges();
    }
    return _challenges;
  }

  Future<List<Challenge>> getUsersActiveChallenges(String userId) async {
    try {
      if (_challenges.isEmpty) {
        await _fetchAllChallenges();
      }

      final ids = await _challengesService.getAllUsersChallenges(userId);
      return _challenges.where((challenge) {
        return ids.contains(challenge.id);
      }).toList();
    } catch (e) {
      debugPrint("Error on challenges repository, get users active challenges: $e");
      return [];
    }
  }

  Future<void> finishChallenge(String userId, String challengeId) async {
    await _challengesService.finishChallenge(userId, challengeId);
  }


}