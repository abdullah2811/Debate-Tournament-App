using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DebateTournamentTabSystem.BLL
{
    public class Dash
    {
        public static Tournament CreateTournament()
        {
            Console.Clear();
            Console.Write("Enter tournament name: ");
            string name = Console.ReadLine();

            Console.Write("Enter tournament year: ");
            string year = Console.ReadLine();

            Console.Write("Enter club name: ");
            string club = Console.ReadLine();

            // Simplify the 'new' expression in the CreateTournament method
            Tournament newTournament = new Tournament(club, name, year);
            ExcelExporter.SaveTournamentToExcel(newTournament);
            return newTournament;

            Console.WriteLine("Tournament created successfully. Press any key to return to the main menu!");
            Console.ReadKey();
        }
        public static void RunTournamentMenu(Tournament tournament)
        {
            while (true)
            {
                Console.Clear();
                Console.WriteLine($"Running Tournament: {tournament.tournamentName} ({tournament.tournamentYear})");
                Console.WriteLine($"Current Segment: {tournament.currentSegment}\n");

                Console.WriteLine("1. Add a team");
                Console.WriteLine("2. Remove a team");
                Console.WriteLine("3. View all teams");
                Console.WriteLine("4. Show Matchups for Current Segment");
                Console.WriteLine("5. Enter Match Results");
                Console.WriteLine("6. Export to Excel");
                Console.WriteLine("7. Advance Segment");
                Console.WriteLine("8. Back to main menu");
                Console.WriteLine("9. Get Tops");


                Console.Write("Enter your choice: ");
                string choice = Console.ReadLine();
                switch (choice)
                {
                    case "1":
                        Tournament.AddTeam(tournament);
                        break;
                    case "2":
                        Tournament.RemoveTeam(tournament);
                        break;
                    case "3":
                        Tournament.ViewTeams(tournament);
                        break;
                    case "4":
                        MatchMashup.ShowMatchups(tournament);
                        break;
                    case "5":
                        ScoreManager.EnterMatchResults(tournament);
                        break;
                    case "6":
                        ExcelExporter.SaveTournamentToExcel(tournament);
                        Console.WriteLine("Press any key to continue...");
                        Console.ReadKey();
                        return;
                    case "7":
                        ScoreManager.AdvanceSegment(tournament);
                        break;
                    case "8":
                        return;
                    case "9":
                        ScoreManager.ShowTopPerformers(tournament);
                        break;

                    default:
                        Console.WriteLine("Invalid choice. Press any key to try again.");
                        Console.ReadKey();
                        break;
                }
            }
        }
        public static bool ConfirmExit()
        {
            Console.Write("Are you sure you want to exit? (y/n): ");
            string input = Console.ReadLine().ToLower();
            return input == "y" || input == "yes";
        }
    }
}
