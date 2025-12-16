using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace DebateTournamentTabSystem.BLL
{
    public class Debater
    {
        public int debaterID { get; set; }
        public string name { get; set; }
        public string departmentName { get; set; }
        public double individualScore { get; internal set; } = 0;

        public Debater(int id, string name, string departmentName)
        {
            this.debaterID = id;
            this.name = name;
            this.departmentName = departmentName;
        }

        public void increaseIndividualScore(int score)
        {
            this.individualScore += score;
        }
        public void UpdateName(string newName) => name = newName;
        public void UpdateDepartment(string newDept) => departmentName = newDept;
    }
}
