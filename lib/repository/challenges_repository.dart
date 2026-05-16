import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/service/challenges_service.dart';

class ChallengesRepository {
  final ChallengesService _challengesService = ChallengesService();

  List<Challenge> _challenges = [];
  List<Challenge> _currentUserActiveChallenges = [];

  ChallengesRepository();

  Future<void> _fetchAllChallenges() async {
    try {
      _challenges = await _challengesService.getAll();
    } catch (e) {
      debugPrint("Error on challenges repository, get all challenges: $e");
    }
  }

  Future<List<Challenge>> getChallenges() async {
    if (_challenges.isEmpty) {
      await _fetchAllChallenges();
    }
    return _challenges;
  }

  Future<void> _fetchUsersActiveChallenges(String userId) async {
    try {
      if (_challenges.isEmpty) {
        await _fetchAllChallenges();
      }

      final ids = await _challengesService.getAllUsersChallenges(userId);
      _currentUserActiveChallenges = _challenges.where((challenge) {
        return ids.contains(challenge.id);
      }).toList();
    } catch (e) {
      debugPrint("Error on challenges repository, fetch users active challenges: $e");
    }
  }

  Future<List<Challenge>> getActiveChallenges(String userId) async {
    try {
      if (_currentUserActiveChallenges.isEmpty) {
        await _fetchUsersActiveChallenges(userId);
      }
      return _currentUserActiveChallenges;
    } catch (e) {
      debugPrint("Error on challenges repository, get users active challenges: $e");
      return [];
    }
  }

  Future<void> startChallenge(String userId, String challengeId) async {
    try {
      await _challengesService.startChallenge(userId, challengeId);
      Challenge challenge = _challenges.firstWhere((c) => c.id == challengeId);
      _currentUserActiveChallenges.add(challenge);
    } catch (e) {
      debugPrint("Error on challenges repository, start new challenge: $e");
      rethrow;
    }
  }

  Future<void> finishChallenge(String userId, String challengeId) async {
    await _challengesService.finishChallenge(userId, challengeId);
  }


}