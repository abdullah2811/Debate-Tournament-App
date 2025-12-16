using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DebateTournamentTabSystem.BLL
{
    public class DebateMatch
    {
        public DebateTeam TeamA { get; set; }
        public DebateTeam TeamB { get; set; }
        public int[] TeamAScores { get; set; } = new int[3];
        public int[] TeamBScores { get; set; } = new int[3];
        public bool IsCompleted { get; set; } = false;

        public DebateMatch(DebateTeam a, DebateTeam b)
        {
            TeamA = a;
            TeamB = b;
        }

        public void SubmitScores(int[] aScores, int aRebuttal, int[] bScores, int bRebuttal)
        {
            if (aScores.Length != 3 || bScores.Length != 3)
                throw new ArgumentException("Each team must have exactly 3 debater scores.");

            TeamAScores = aScores;
            TeamBScores = bScores;

            int teamATotal = aScores.Sum() + aRebuttal;
            int teamBTotal = bScores.Sum() + bRebuttal;

            for (int i = 0; i < 3; i++)
            {
                TeamA.teamMembers[i].increaseIndividualScore(aScores[i]);
                TeamB.teamMembers[i].increaseIndividualScore(bScores[i]);
            }

            TeamA.increaseTeamScore(teamATotal);
            TeamB.increaseTeamScore(teamBTotal);

            if (teamATotal > teamBTotal)
            {
                TeamA.teamWinsADebate();
                TeamB.teamLosesADebate();
            }
            else if (teamBTotal > teamATotal)
            {
                TeamB.teamWinsADebate();
                TeamA.teamLosesADebate();
            }
            else
            {
                Console.WriteLine("The scores are tied.");
                Console.WriteLine($"Team A: {TeamA.teamName}");
                Console.WriteLine($"Team B: {TeamB.teamName}");
                Console.WriteLine("Enter the number of the team that wins (1 for Team A, 2 for Team B):");

                while (true)
                {
                    string? input = Console.ReadLine();
                    if (input == "1")
                    {
                        TeamA.teamWinsADebate();
                        TeamB.teamLosesADebate();
                        break;
                    }
                    else if (input == "2")
                    {
                        TeamB.teamWinsADebate();
                        TeamA.teamLosesADebate();
                        break;
                    }
                    else
                    {
                        Console.WriteLine("Invalid input. Please enter 1 or 2:");
                    }
                }
            }

            IsCompleted = true;
        }
    }
}
