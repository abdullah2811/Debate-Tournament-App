using ClosedXML.Excel;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DebateTournamentTabSystem.BLL;
public static class ExcelExporter
{
    public static readonly string TournamentRecordsFolderPath =
        @"C:\\Users\\abdul\\source\\repos\\DebateTournamentTabSystem\\Tournament Records";
    public static readonly string filePath =
        @"C:\\Users\\abdul\\source\\repos\\DebateTournamentTabSystem\\TournamentDocs";
    public static void SaveTournamentToExcel(Tournament t)
    {
        Directory.CreateDirectory(TournamentRecordsFolderPath);
        string file = Path.Combine(TournamentRecordsFolderPath,
            $"{t.tournamentName}_{t.tournamentYear}.xlsx");

        using var wb = new XLWorkbook();
        var ws = wb.Worksheets.Add("Tournament");

        // --- Metadata ---
        ws.Cell("A1").Value = "ClubName"; ws.Cell("B1").Value = t.clubName;
        ws.Cell("A2").Value = "TournamentName"; ws.Cell("B2").Value = t.tournamentName;
        ws.Cell("A3").Value = "Year"; ws.Cell("B3").Value = t.tournamentYear;
        ws.Cell("A4").Value = "CurrentSegment"; ws.Cell("B4").Value = t.currentSegment.ToString();

        // --- Header Row ---
        var headers = new[]
        {
            "TeamID","TeamName","TeamScore","TeamWins","TeamLosses","TeamStatus",
            "DebaterID","DebaterName","Department","IndividualScore"
        };
        for (int i = 0; i < headers.Length; i++)
            ws.Cell(6, i + 1).Value = headers[i];

        // --- Data Rows (4 rows per team) ---
        int r = 7;
        foreach (var team in t.teamsInTheTournament)
        {
            // Team row
            ws.Cell(r, 1).Value = team.teamID;
            ws.Cell(r, 2).Value = team.teamName;
            ws.Cell(r, 3).Value = team.teamScore;
            ws.Cell(r, 4).Value = team.teamWins;
            ws.Cell(r, 5).Value = team.teamLosses;
            ws.Cell(r, 6).Value = team.teamStatus.ToString();
            r++;

            // Three Debater rows
            foreach (var d in team.teamMembers)
            {
                ws.Cell(r, 7).Value = d.debaterID;
                ws.Cell(r, 8).Value = d.name;
                ws.Cell(r, 9).Value = d.departmentName;
                ws.Cell(r, 10).Value = d.individualScore;
                r++;
            }
        }

        wb.SaveAs(file);
    }   //Implemented
    // Save matchup to excel
    public static void SaveMatchupToExcel(List<DebateMatch> matchups, Tournament tournament)
    {
        Directory.CreateDirectory(filePath);

        var wb = new XLWorkbook();
        var ws = wb.Worksheets.Add("Matchups");

        // Header
        ws.Cell(1, 1).Value = "Tournament Name"; ws.Cell(1, 2).Value = tournament.tournamentName;
        ws.Cell(2, 1).Value = "Year"; ws.Cell(2, 2).Value = tournament.tournamentYear;
        ws.Cell(3, 1).Value = "Club"; ws.Cell(3, 2).Value = tournament.clubName;

        ws.Cell(5, 1).Value = "Team A ID";
        ws.Cell(5, 2).Value = "Team A Name";
        ws.Cell(5, 3).Value = "Team B ID";
        ws.Cell(5, 4).Value = "Team B Name";
        ws.Cell(5, 5).Value = "IsComplete";

        int row = 6;
        foreach (var match in matchups)
        {
            ws.Cell(row, 1).Value = match.TeamA.teamID;
            ws.Cell(row, 2).Value = match.TeamA.teamName;
            ws.Cell(row, 3).Value = match.TeamB.teamID;
            ws.Cell(row, 4).Value = match.TeamB.teamName;
            ws.Cell(row, 5).Value = match.IsCompleted ? "Yes" : "No";
            row++;
        }

        string path = Path.Combine(filePath,
            $"Matchups_{tournament.tournamentName}_{tournament.tournamentYear}_{tournament.currentSegment}.xlsx");
        wb.SaveAs(path);
        Console.WriteLine($"Matchup data exported to {path}");
    }    //Implemented
    // Save top debaters to excel
    public static void SaveTopDebatersToExcel(List<Debater> topDebaters, Tournament tournament)
    {
        var workbook = new XLWorkbook();
        var worksheet = workbook.Worksheets.Add("Top Debaters");
        worksheet.Cell(1, 1).Value = "Tournament Name";
        worksheet.Cell(1, 2).Value = tournament.tournamentName;
        worksheet.Cell(2, 1).Value = "Year";
        worksheet.Cell(2, 2).Value = tournament.tournamentYear;
        worksheet.Cell(3, 1).Value = "Club";
        worksheet.Cell(3, 2).Value = tournament.clubName;
        worksheet.Cell(5, 1).Value = "Debater ID";
        worksheet.Cell(5, 2).Value = "Name";
        worksheet.Cell(5, 3).Value = "Department";
        int row = 6;
        foreach (var debater in topDebaters)
        {
            worksheet.Cell(row, 1).Value = debater.debaterID;
            worksheet.Cell(row, 2).Value = debater.name;
            worksheet.Cell(row, 3).Value = debater.departmentName;
            row++;
        }
        // Save the workbook to a file
        string path = Path.Combine(filePath, $"Top_Debaters_{tournament.tournamentName}_{tournament.tournamentYear}_{tournament.currentSegment}.xlsx");
        workbook.SaveAs(path);
        Console.WriteLine($"Top debaters data exported to {path}");
    }   //Implemented
    // Save top debate teams to excel
    public static void SaveTopDebateTeamsToExcel(List<DebateTeam> topTeams, Tournament tournament)
    {
        var workbook = new XLWorkbook();
        var worksheet = workbook.Worksheets.Add("Top Teams");
        worksheet.Cell(1, 1).Value = "Tournament Name";
        worksheet.Cell(1, 2).Value = tournament.tournamentName;
        worksheet.Cell(2, 1).Value = "Year";
        worksheet.Cell(2, 2).Value = tournament.tournamentYear;
        worksheet.Cell(3, 1).Value = "Club";
        worksheet.Cell(3, 2).Value = tournament.clubName;
        worksheet.Cell(5, 1).Value = "Team ID";
        worksheet.Cell(5, 2).Value = "Team Name";
        worksheet.Cell(5, 3).Value = "Score";
        int row = 6;
        foreach (var team in topTeams)
        {
            worksheet.Cell(row, 1).Value = team.teamID;
            worksheet.Cell(row, 2).Value = team.teamName;
            worksheet.Cell(row, 3).Value = team.teamScore;
            row++;
        }
        // Save the workbook to a file
        string path = Path.Combine(filePath, $"Top_Teams_{tournament.tournamentName}_{tournament.tournamentYear}_{tournament.currentSegment}.xlsx");
        workbook.SaveAs(path);
        Console.WriteLine($"Top teams data exported to {path}");
    }   //Implemented
    public static Tournament LoadTournamentFromExcel(string filePath)
    {
        using var wb = new XLWorkbook(filePath);
        var ws = wb.Worksheet("Tournament");

        // --- Read Metadata ---
        var club = ws.Cell("B1").GetString();
        var name = ws.Cell("B2").GetString();
        var year = ws.Cell("B3").GetString();
        Enum.TryParse<TournamentStage>(ws.Cell("B4").GetString(), out var stage);

        var t = new Tournament(club, name, year)
        {
            currentSegment = stage
        };

        // --- Read Teams & Debaters ----
        int row = 7;
        while (!ws.Cell(row, 1).IsEmpty())
        {
            // Team row
            int tid = ws.Cell(row, 1).GetValue<int>();
            string tnm = ws.Cell(row, 2).GetString();
            int tscore = ws.Cell(row, 3).GetValue<int>();
            int twins = ws.Cell(row, 4).GetValue<int>();
            int tloss = ws.Cell(row, 5).GetValue<int>();
            var tstat = Enum.Parse<DebateTeamStatus>(ws.Cell(row, 6).GetString());

            var members = new List<Debater>();
            row++;

            // Next 3 rows = debaters
            for (int i = 0; i < 3; i++, row++)
            {
                int did = ws.Cell(row, 7).GetValue<int>();
                string dnm = ws.Cell(row, 8).GetString();
                string dept = ws.Cell(row, 9).GetString();
                int score = ws.Cell(row, 10).GetValue<int>();

                members.Add(new Debater(did, dnm, dept) { individualScore = score });
            }

            var team = new DebateTeam(tid, tnm, members)
            {
                teamScore = tscore,
                teamWins = twins,
                teamLosses = tloss,
                teamStatus = tstat
            };

            t.teamsInTheTournament.Add(team);
            t.currentMatches = ExcelExporter.LoadMatchupsFromExcel(t);

        }

        return t;
    }    //Implemented inside LoadTournamentFromFolder
    private static string GetCellValue(WorkbookPart workbookPart, Cell cell)
    {
        if (cell == null || cell.CellValue == null) return "";

        string value = cell.CellValue.InnerText;
        if (cell.DataType != null && cell.DataType.Value == CellValues.SharedString)
        {
            return workbookPart.SharedStringTablePart.SharedStringTable
                              .Elements<SharedStringItem>()
                              .ElementAt(int.Parse(value))
                              .InnerText;
        }
        return value;
    }   //Implemented. Unused.
    public static List<Tournament> LoadTournamentsFromFolder()
    {
        var list = new List<Tournament>();
        if (!Directory.Exists(TournamentRecordsFolderPath))
            return list;

        foreach (var f in Directory.GetFiles(TournamentRecordsFolderPath, "*.xlsx"))
        {
            try
            {
                var tour = LoadTournamentFromExcel(f);
                list.Add(tour);
            }
            catch
            {
                // skip invalid/corrupt files silently
            }
        }
        return list;
    }       //Implemented
    public static List<DebateMatch> LoadMatchupsFromExcel(Tournament tournament)
    {
        string path = Path.Combine(filePath,
            $"Matchups_{tournament.tournamentName}_{tournament.tournamentYear}_{tournament.currentSegment}.xlsx");
        if (!File.Exists(path)) return new List<DebateMatch>();

        var wb = new XLWorkbook(path);
        var ws = wb.Worksheet("Matchups");

        var matches = new List<DebateMatch>();
        int row = 6;
        while (!ws.Cell(row, 1).IsEmpty())
        {
            int aId = ws.Cell(row, 1).GetValue<int>();
            string aName = ws.Cell(row, 2).GetString();
            int bId = ws.Cell(row, 3).GetValue<int>();
            string bName = ws.Cell(row, 4).GetString();
            bool done = ws.Cell(row, 5).GetString().Equals("Yes", StringComparison.OrdinalIgnoreCase);

            var teamA = tournament.teamsInTheTournament.First(t => t.teamID == aId);
            var teamB = tournament.teamsInTheTournament.First(t => t.teamID == bId);

            var match = new DebateMatch(teamA, teamB)
            {
                IsCompleted = done
            };
            matches.Add(match);
            row++;
        }

        return matches;
    }

}