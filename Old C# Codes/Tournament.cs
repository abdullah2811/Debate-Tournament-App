namespace DebateTournamentTabSystem.BLL
{
    public class Tournament
    {
        public string clubName { get; set; }
        public string tournamentName { get; set; }
        public string tournamentYear { get; set; }
        public TournamentStage currentSegment { get; set; } = TournamentStage.Preliminary1;
        public int numberOfTeamsInTournament { get; set; } = 0;
        public List<DebateTeam> teamsInTheTournament { get; set; } = new List<DebateTeam>(); // Static list to hold all teams in the tournament
        public List<DebateMatch> currentMatches { get; set; } = new List<DebateMatch>();

        public Tournament(string clubName, string tournamentName, string tournamentYear)
        {
            teamsInTheTournament = new List<DebateTeam>();
            this.clubName = clubName;
            this.tournamentName = tournamentName;
            this.tournamentYear = tournamentYear;
        }

        public static void AddTeam(Tournament tournament)
        {
            Console.Clear();
            Console.Write("Enter team name: ");
            string teamName = Console.ReadLine();

            List<Debater> members = new List<Debater>();
            for (int i = 1; i <= 3; i++)
            {
                Console.WriteLine($"Enter details for Debater {i}:");
                Console.Write("Name: "); string name = Console.ReadLine();
                Console.Write("Department: "); string dept = Console.ReadLine();
                members.Add(new Debater(i, name, dept));
            }

            int teamID = tournament.teamsInTheTournament.Count + 1;
            DebateTeam team = new DebateTeam(teamID, teamName, members);
            tournament.teamsInTheTournament.Add(team);
            ExcelExporter.SaveTournamentToExcel(tournament);

            Console.WriteLine("Team added successfully. Press any key to continue.");
            Console.ReadKey();
        }
        public static void RemoveTeam(Tournament tournament)
        {
            Console.Clear();
            Console.Write("Enter team name to remove: ");
            string name = Console.ReadLine();
            var team = tournament.teamsInTheTournament.Find(t => t.teamName.Equals(name, StringComparison.OrdinalIgnoreCase));
            if (team != null)
            {
                tournament.teamsInTheTournament.Remove(team);
                Console.WriteLine("Team removed successfully.");
            }
            else
            {
                Console.WriteLine("Team not found.");
            }
            ExcelExporter.SaveTournamentToExcel(tournament);
            Console.WriteLine("Press any key to continue.");
            Console.ReadKey();
        }
        public static void ViewTeams(Tournament tournament)
        {
            Console.Clear();
            if (tournament.teamsInTheTournament.Count == 0)
            {
                Console.WriteLine("No teams added yet.");
            }
            else
            {
                Console.WriteLine("Teams in the tournament:");
                foreach (var team in tournament.teamsInTheTournament)
                {
                    Console.WriteLine($"{team.teamID}: {team.teamName} | Score: {team.teamScore} | Wins: {team.teamWins}");
                }
            }
            Console.WriteLine("Press any key to continue.");
            Console.ReadKey();
        }
    }
}
