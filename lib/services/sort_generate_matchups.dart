import 'package:debate_tournament_app/models/tournament.dart';

import '../models/debate_match.dart';
import '../models/debate_team.dart';
import '../models/tournament_segment.dart';

(List<DebateMatch>, List<DebateTeam>) generateMatchups(
  Tournament currentTournament,
  TournamentSegment segment,
  List<DebateTeam> teams,
) {
  List<DebateMatch> matches = [];
  List<DebateTeam> disqualifiedTeams = [];

  int auto = segment.numberOfTeamsAutoQualifiedForNextRound;
  int start = 0, end = segment.numberOfTeamsInSegment - 1;
  int v = 1; //Venue number

  //Current round index
  int roundIndex = currentTournament.tournamentSegments!.indexOf(segment);

  //Sort teams based on wins (first priority) and teamScore (second priority)
  if (roundIndex != 0) {
    if (segment.isTabRound) {
      // split teams based on their status in the previous round and sort the winners and losers separately and create matchups within each group
      List<DebateTeam> winners = teams
          .where((team) => team.teamStatus == DebateTeamStatus.win)
          .toList();
      List<DebateTeam> losers = teams
          .where((team) => team.teamStatus == DebateTeamStatus.lose)
          .toList();
      winners.sort((a, b) {
        if (b.teamWins != a.teamWins) {
          return b.teamWins.compareTo(a.teamWins);
        } else {
          return b.teamScore.compareTo(a.teamScore);
        }
      });
      losers.sort((a, b) {
        if (b.teamWins != a.teamWins) {
          return b.teamWins.compareTo(a.teamWins);
        } else {
          return b.teamScore.compareTo(a.teamScore);
        }
      });
      List<DebateMatch> winnerMatches = [];
      List<DebateMatch> loserMatches = [];
      int wStart = 0, wEnd = winners.length - 1;
      int lStart = 0, lEnd = losers.length - 1;
      while (wStart < wEnd) {
        DebateTeam teamA = winners[wStart];
        DebateTeam teamB = winners[wEnd];

        DebateMatch match = DebateMatch(
          teamA: teamA,
          teamB: teamB,
        );

        winnerMatches.add(match);
        wStart++;
        wEnd--;
      }
      while (lStart < lEnd) {
        DebateTeam teamA = losers[lStart];
        DebateTeam teamB = losers[lEnd];

        DebateMatch match = DebateMatch(
          teamA: teamA,
          teamB: teamB,
        );

        loserMatches.add(match);
        lStart++;
        lEnd--;
      }
      matches = [...winnerMatches, ...loserMatches];
      return (matches, disqualifiedTeams);
    } else {
      //For elimination rounds, sort by teamWins first, then by teamScore
      teams.sort((a, b) {
        if (b.teamWins != a.teamWins) {
          return b.teamWins.compareTo(a.teamWins);
        } else {
          return b.teamScore.compareTo(a.teamScore);
        }
      });
    }
  }

  start = auto;
  end += auto;
  //Add first 'auto' teams to the tournamnt's autoQualifiedTeams list
  for (int i = 0; i < auto; i++) {
    currentTournament.addAutoQualifiedTeam(teams[i]);
  }

  for (int i = end + 1; i < teams.length; i++) {
    disqualifiedTeams.add(teams[i]);
  }

  while (start < end) {
    DebateTeam teamA = teams[start];
    DebateTeam teamB = teams[end];

    DebateMatch match = DebateMatch(
      teamA: teamA,
      teamB: teamB,
    );

    matches.add(match);
    start++;
    end--;
  }

  // Check match by match. If any team's teamPlayedGovernment is equal to number of rounds or 0, then swap sides.
  roundIndex++;
  for (var match in matches) {
    if (match.teamA.teamPlayedGovernment == roundIndex ||
        match.teamA.teamPlayedGovernment == 0) {
      // Swap sides
      DebateTeam temp = match.teamA;
      match.teamA = match.teamB;
      match.teamB = temp;
    }
    match.venue = v;
    v++;
  }

  (List<DebateMatch>, List<DebateTeam>) result = (matches, disqualifiedTeams);

  return result;
}
