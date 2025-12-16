using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DebateTournamentTabSystem.BLL
{
    public class MatchMashup
    {
        // Method to create and return a list of pairs of teams for a given segment and list of teams
        public static List<(DebateTeam, DebateTeam)> PreliminarySegmentFirstMatchup(List<DebateTeam> teams)
        {
            List<(DebateTeam, DebateTeam)> matchups = new List<(DebateTeam, DebateTeam)>();
            // Ensure there are an even number of teams
            if (teams.Count % 2 != 0)
            {
                throw new ArgumentException("Number of teams must be even for pairing.");
            }
            // Create pairs of teams
            for (int i = 0; i < teams.Count; i += 2)
            {
                matchups.Add((teams[i], teams[i + 1]));
            }
            return matchups;
        }
        //For the second matchup, we will make list of debating pairs based on the first matchup. The winning teams will fight against the winning teams and the losing teams will fight the losing teams. Suppose there are 32 teams initilly, in the first matchup of preliminary round, 16 matched will hold ond there will be 16 winning and 16 llosing teams. The winners will fight among themselves and the losers also fight among the losers. There might be odd number of winners and losers, so there will be a match where one winner team will fight against a loser team. While sorting among the winner or loser teams, we will sort them based on their team scores. The team with the higher score will be matched against the team with the lower score.
        public static List<(DebateTeam, DebateTeam)> PreliminarySegmentWinWinLoseLoseMatchup(List<DebateTeam> teams)
        {
            List<DebateTeam> winningTeams = new List<DebateTeam>();
            List<DebateTeam> losingTeams = new List<DebateTeam>();
            List<(DebateTeam, DebateTeam)> matchups = new List<(DebateTeam, DebateTeam)>();
            
            //Add values to the winning and losing teams list
            winningTeams = teams.Where(t => t.teamStatus == DebateTeamStatus.Win).ToList();
            losingTeams = teams.Where(t => t.teamStatus == DebateTeamStatus.Lose).ToList();

            // Winning teams: sort by number of wins (descending), then team score (descending)
            winningTeams = teams
                .Where(t => t.teamStatus == DebateTeamStatus.Win)
                .OrderByDescending(t => t.teamWins)
                .ThenByDescending(t => t.teamScore)
                .ToList();

            // Losing teams: sort by number of wins (descending), then team score (ascending)
            losingTeams = teams
                .Where(t => t.teamStatus == DebateTeamStatus.Lose)
                .OrderByDescending(t => t.teamWins)
                .ThenBy(t => t.teamScore)
                .ToList();


            if (winningTeams.Count != losingTeams.Count || winningTeams.Count == 0)
            {
                throw new ArgumentException("Number of winning and losing teams must be equal and more than 0.");
            }

            // Ensure both are even AND equal
            if (winningTeams.Count % 2 != 0 && losingTeams.Count % 2 != 0)
            {
                // Move one team from winning to losing to balance pairing
                DebateTeam lastWinningTeam = winningTeams.Last();
                winningTeams.Remove(lastWinningTeam);
                losingTeams.Add(lastWinningTeam); // Add to end to maintain ordering
            }
            else if (winningTeams.Count != losingTeams.Count || (winningTeams.Count % 2 != 0 || losingTeams.Count % 2 != 0))
            {
                throw new ArgumentException("Team counts must be equal and even for proper matchup generation.");
            }

            //Build the matchups. Initially, make pairs among the winning teams. The highest scoring team will fight against the lowest scoring team.
            int n = winningTeams.Count;
            for (int i = 0; i < n; i+=2)
            {
                matchups.Add((winningTeams[i], winningTeams[i+1]));
            }
            for (int i = 0; i < n; i+=2)
            {
                matchups.Add((losingTeams[i], losingTeams[i+1]));
            }
            return matchups;
        }
        public static List<(DebateTeam, DebateTeam)> QuarterSemiFinalSegmentMatchup(List<DebateTeam> teams)
        {
            List<(DebateTeam, DebateTeam)> matchups = new List<(DebateTeam, DebateTeam)>();
            // Ensure there are an even number of teams
            int n = teams.Count;
            if (n % 2 != 0)
            {
                throw new ArgumentException("Number of teams must be even for pairing.");
            }
            // Create pairs of teams
            for (int i = 0; i < n / 2; i++)
            {
                matchups.Add((teams[i], teams[n - 1 - i]));
            }
            return matchups;
        }
        public static List<DebateMatch> GenerateMatchups(Tournament tournament)
        {
            Console.Clear();

            var teams = tournament.teamsInTheTournament;

            List<(DebateTeam, DebateTeam)> pairs;

            switch (tournament.currentSegment)
            {
                case TournamentStage.Preliminary1:
                    pairs = MatchMashup.PreliminarySegmentFirstMatchup(teams);
                    break;
                case TournamentStage.Preliminary2:
                case TournamentStage.Preliminary3:
                    pairs = MatchMashup.PreliminarySegmentWinWinLoseLoseMatchup(teams);
                    break;
                case TournamentStage.OctaFinal:
                case TournamentStage.QuarterFinal:
                case TournamentStage.SemiFinal:
                case TournamentStage.Final:
                    ScoreManager.ResetScores(teams, tournament);
                    pairs = MatchMashup.QuarterSemiFinalSegmentMatchup(teams);
                    break;
                default:
                    Console.WriteLine("Invalid tournament segment.");
                    Console.ReadKey();
                    return new List<DebateMatch>(); // Return an empty list to satisfy the return type
            }

            tournament.currentMatches.Clear();
            foreach (var (a, b) in pairs)
            {
                tournament.currentMatches.Add(new DebateMatch(a, b));
            }

            return tournament.currentMatches; // Ensure the method returns the list of matches
        }
        public static void ShowMatchups(Tournament tournament)
        {
            tournament.currentMatches = MatchMashup.GenerateMatchups(tournament);
            Console.WriteLine("Matchups generated:");
            foreach (var match in tournament.currentMatches)
            {
                Console.WriteLine($"Match: {match.TeamA.teamName} vs {match.TeamB.teamName}");
            }
            ExcelExporter.SaveMatchupToExcel(tournament.currentMatches, tournament);
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }
    }
}
