using DebateTournamentTabSystem.BLL;
using DocumentFormat.OpenXml.Math;
using System;
using System.Collections.Generic;
using System.Security.Cryptography;

namespace DebateTournamentTabSystem
{
    internal class Program
    {
        static List<Tournament> allTournaments = ExcelExporter.LoadTournamentsFromFolder();

        static void Main(string[] args)
        {
            while (true)
            {
                Console.Clear();
                Console.WriteLine("Welcome to the Debate Tournament Tab System!");
                Console.WriteLine("Pick one of the following options:");
                Console.WriteLine("1. Create a tournament");
                Console.WriteLine("2. Run a tournament");
                Console.WriteLine("3. View previous tournament data");
                Console.WriteLine("4. Exit this application");

                Console.Write("Enter your choice: ");
                string choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        allTournaments.Add(Dash.CreateTournament());
                        break;
                    case "2":
                        RunTournament();
                        break;
                    case "3":
                        ViewTournaments();
                        break;
                    case "4":
                        if (Dash.ConfirmExit()) return;
                        break;
                    default:
                        Console.WriteLine("Invalid choice. Press any key to try again.");
                        Console.ReadKey();
                        break;
                }
            }
        }

        public static void RunTournament()
        {
            if (allTournaments.Count == 0)
            {
                Console.WriteLine("No tournaments available. Press any key to return.");
                Console.ReadKey();
                return;
            }

            Console.Clear();
            Console.WriteLine("Choose a tournament to run:");
            for (int i = 0; i < allTournaments.Count; i++)
            {
                var t = allTournaments[i];
                Console.WriteLine($"{i + 1}. {t.tournamentName} ({t.tournamentYear}) - {t.clubName} | Current Segment: {t.currentSegment}");
            }

            Console.Write("Enter choice: ");
            if (int.TryParse(Console.ReadLine(), out int choice) && choice > 0 && choice <= allTournaments.Count)
            {
                Dash.RunTournamentMenu(allTournaments[choice - 1]);
            }
            else
            {
                Console.WriteLine("Invalid choice. Press any key to return.");
                Console.ReadKey();
            }
        }
        public static void ViewTournaments()
        {
            Console.Clear();
            if (allTournaments.Count == 0)
            {
                Console.WriteLine("No tournaments created yet.");
            }
            else
            {
                Console.WriteLine("Existing Tournaments:");
                foreach (var t in allTournaments)
                {
                    Console.WriteLine($"{t.tournamentName} ({t.tournamentYear}) - {t.clubName} | Current Segment: {t.currentSegment}");
                }
            }
            Console.WriteLine("Press any key to continue.");
            Console.ReadKey();
        }
    }
}
