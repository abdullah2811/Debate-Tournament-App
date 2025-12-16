using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DebateTournamentTabSystem.BLL
{
    public class ScoreManager
    {
        public static List<Debater> GetTopDebaters(List<DebateTeam> teams, Tournament tournament, int topN=5)
        {
            List<Debater> allDebaters = new List<Debater>();
            foreach (var team in teams)
            {
                allDebaters.AddRange(team.teamMembers);
            }
            // Sort debaters by individual score and take the top N
            List<Debater> sortedDebaters = allDebaters.OrderByDescending(debater => debater.individualScore).ToList();
            ExcelExporter.SaveTopDebatersToExcel(sortedDebaters, tournament);
            // If there are fewer debaters than topN, return all of them
            if (sortedDebaters.Count < topN)
            {
                return sortedDebaters;
            }
            return allDebaters.OrderByDescending(debater => debater.individualScore)
                              .Take(topN)
                              .ToList();
        }
        public static List<DebateTeam> GetTopTeams(List<DebateTeam> teams, Tournament tournament, int topN = 3)
        {
            // Sort by number of wins first, then by team score
            List<DebateTeam> sortedTeams = teams
                .OrderByDescending(team => team.teamWins)
                .ThenByDescending(team => team.teamScore)
                .ToList();

            // Export to Excel
            ExcelExporter.SaveTopDebateTeamsToExcel(sortedTeams, tournament);

            // Return all if less than topN
            if (sortedTeams.Count < topN)
            {
                return sortedTeams;
            }

            return sortedTeams.Take(topN).ToList();
        }
        public static void EnterMatchResults(Tournament tournament)
        {
            if (tournament.currentMatches == null || tournament.currentMatches.Count == 0)
                tournament.currentMatches = MatchMashup.GenerateMatchups(tournament);
            while (true)
            {
                Console.Clear();

                var incompleteMatches = tournament.currentMatches
                    .Where(m => !m.IsCompleted)
                    .ToList();

                if (incompleteMatches.Count == 0)
                {
                    Console.WriteLine("✅ All match results have already been submitted.");
                    Console.Write("Do you want to advance to the next segment? (y/n): ");
                    string input = Console.ReadLine().ToLower();
                    if (input == "y" || input == "yes")
                    {
                        AdvanceSegment(tournament);
                    }
                    else
                    {
                        Console.WriteLine("Tournament stays in current segment.");
                        Console.ReadKey();
                    }
                    return;
                }

                Console.WriteLine("📋 Incomplete Matches:");
                for (int i = 0; i < incompleteMatches.Count; i++)
                {
                    var match = incompleteMatches[i];
                    Console.WriteLine($"{i + 1}. {match.TeamA.teamName} vs {match.TeamB.teamName}");
                }

                Console.WriteLine("0. 🔙 Return to Tournament Menu");
                Console.Write("Select a match number to enter result: ");
                string choice = Console.ReadLine();

                if (choice == "0")
                    return;

                if (int.TryParse(choice, out int matchIndex) &&
                    matchIndex >= 1 &&
                    matchIndex <= incompleteMatches.Count)
                {
                    var selectedMatch = incompleteMatches[matchIndex - 1];
                    DebateTeam TeamA = selectedMatch.TeamA;
                    DebateTeam TeamB = selectedMatch.TeamB;

                    Console.Clear();
                    Console.WriteLine($"🔽 Entering result for {TeamA.teamName} vs {TeamB.teamName}");

                    int[] aScores = new int[3];
                    int[] bScores = new int[3];

                    Console.WriteLine($"\nEnter scores for {TeamA.teamName}:");
                    for (int j = 0; j < 3; j++)
                    {
                        var debater = TeamA.teamMembers[j];
                        Console.Write($"  {debater.name}: ");
                        aScores[j] = int.Parse(Console.ReadLine());
                    }

                    Console.Write($"Rebuttal score: ");
                    int aRebuttal = int.Parse(Console.ReadLine());

                    Console.WriteLine($"\nEnter scores for {TeamB.teamName}:");
                    for (int j = 0; j < 3; j++)
                    {
                        var debater = TeamB.teamMembers[j];
                        Console.Write($"  {debater.name}: ");
                        bScores[j] = int.Parse(Console.ReadLine());
                    }
                    Console.Write($"Rebuttal score: ");
                    int bRebuttal = int.Parse(Console.ReadLine());

                    selectedMatch.SubmitScores(aScores, aRebuttal, bScores, bRebuttal);
                    ExcelExporter.SaveMatchupToExcel(tournament.currentMatches, tournament);

                    Console.WriteLine("\n✅ Result submitted!");
                    ExcelExporter.SaveTournamentToExcel(tournament);

                    Console.WriteLine("📁 Tournament auto-saved.");
                    Console.WriteLine("Press any key to return to match list.");
                    Console.ReadKey();
                }
                else
                {
                    Console.WriteLine("❌ Invalid choice. Press any key to try again.");
                    Console.ReadKey();
                }
            }
        }
        public static void ResetScores(List<DebateTeam> teams, Tournament tournament)
        {
            // Reset the scores of all teams and debaters
            foreach (var team in teams)
            {
                team.teamScore = 0;
                team.teamWins = 0;
                team.teamLosses = 0;
                team.teamStatus = DebateTeamStatus.NotPlayed; // Reset status to NotPlayed
                foreach (var debater in team.teamMembers)
                {
                    debater.individualScore = 0; // Assuming Debater has an individualScore property
                }
            }
            ExcelExporter.SaveTournamentToExcel(tournament);
        }        
        public static void ShowTopPerformers(Tournament tournament)
        {
            Console.Clear();
            Console.WriteLine("🎉 Top Teams:");
            // Fix the line causing the error by correctly calling the GetTopTeams method
            List<DebateTeam> topTeams = ScoreManager.GetTopTeams(tournament.teamsInTheTournament, tournament);
            foreach (var team in topTeams)
            {
                Console.WriteLine($"🏆 {team.teamName} - Wins: {team.teamWins}, Score: {team.teamScore}");
            }

            Console.WriteLine("\n🎖 Top Debaters:");
            var topDebaters = ScoreManager.GetTopDebaters(tournament.teamsInTheTournament, tournament);
            foreach (var debater in topDebaters.Take(5))
            {
                Console.WriteLine($"⭐ {debater.name} - Score: {debater.individualScore} | Dept: {debater.departmentName}");
            }

            Console.WriteLine("\nPress any key to continue...");
            Console.ReadKey();
        }
        public static TournamentStage AdvanceSegment(Tournament tournament)
        {
            if (tournament.currentSegment > TournamentStage.Preliminary2)
            {
                Console.WriteLine("Advancing to the next segment...");
                ShowTopPerformers(tournament);      // Show top teams and debaters before advancing
            }
            //If advances to Quarter, Semi, or Final, remove teams that did not qualify
            if (tournament.currentSegment == TournamentStage.Preliminary3)
            {
                tournament.teamsInTheTournament = ScoreManager.GetTopTeams(tournament.teamsInTheTournament, tournament, 16);
            }
            else if (tournament.currentSegment == TournamentStage.OctaFinal)
            {
                tournament.teamsInTheTournament = ScoreManager.GetTopTeams(tournament.teamsInTheTournament, tournament, 8);
            }
            else if (tournament.currentSegment == TournamentStage.QuarterFinal)
            {
                tournament.teamsInTheTournament = ScoreManager.GetTopTeams(tournament.teamsInTheTournament, tournament, 4);
            }
            else if (tournament.currentSegment == TournamentStage.SemiFinal)
            {
                tournament.teamsInTheTournament = ScoreManager.GetTopTeams(tournament.teamsInTheTournament, tournament, 2);
            }
            // Advance the tournament segment
            if ((int)tournament.currentSegment < (int)TournamentStage.Final)
            {
                tournament.currentSegment = (TournamentStage)((int)tournament.currentSegment + 1);
                Console.WriteLine($"Tournament advanced to: {tournament.currentSegment}");
            }
            else
            {
                Console.WriteLine("The tournament has already reached the Final segment.");
            }
            ExcelExporter.SaveTournamentToExcel(tournament);
            Console.WriteLine("Press any key to continue.");
            Console.ReadKey();
            return tournament.currentSegment;
        }
    }
}