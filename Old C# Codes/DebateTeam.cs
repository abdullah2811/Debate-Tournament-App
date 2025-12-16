using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DebateTournamentTabSystem.BLL
{
    public enum DebateTeamStatus
    {
        NotPlayed,
        Win,
        Lose
    }
    public class DebateTeam
    {
        public string teamName { get; set; }
        public int teamID { get; set; }
        public List<Debater> teamMembers { get; private set; }
        public int teamWins { get; internal set; } = 0;
        public int teamLosses { get; internal set; } = 0;
        public double teamScore { get; internal set; } = 0;
        public DebateTeamStatus teamStatus { get; set; } = DebateTeamStatus.NotPlayed; // Default status is NotPlayed
        public DebateTeam(int id, string name, List<Debater> members, int score=0)  // Constructor with default score value as 0
        {
            if (members == null || members.Count != 3)
                throw new ArgumentException("A debate team must have exactly 3 debaters.");
            this.teamID = id;
            this.teamName = name;
            this.teamMembers = members;
            this.teamScore = score;
        }
        public void increaseTeamScore(int score)
        {
            teamScore += score;
        }
        public void teamWinsADebate()
        {
            this.teamStatus = DebateTeamStatus.Win; // Update status to Win
            teamWins++;
        }
        public void teamLosesADebate()
        {
            this.teamStatus = DebateTeamStatus.Lose; // Update status to Lose
            teamLosses++;
        }
    }
}
