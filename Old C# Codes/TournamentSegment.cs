using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DebateTournamentTabSystem.BLL
{
    // Enum for tournament stages with explicit values
    public enum TournamentStage
    {
        Preliminary1 = 1,
        Preliminary2 = 2,
        Preliminary3 = 3,
        OctaFinal = 4,
        QuarterFinal = 5,
        SemiFinal = 6,
        Final = 7
    }

    // Represents a segment (stage) of the tournament  
    public class TournamentSegment
    {
        public string segmentName { get; set; } // Name of the segment  
        public int segmentID { get; set; } // Segment identifier  
        public List<DebateTeam> teamsInThisSegment { get; set; } = new List<DebateTeam>(); // Teams in this segment  
        public int numberOfTeamsInSegment { get; set; } // Number of teams                
    }
}
