import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debate_tournament_app/models/tournament.dart';
import 'package:debate_tournament_app/models/debate_team.dart';
import 'package:debate_tournament_app/models/debater.dart';
import 'package:debate_tournament_app/models/debate_match.dart';
import 'package:debate_tournament_app/models/user.dart';
import 'dash_screen.dart';
import 'debater_details_screen.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final Tournament currentTournament;
  final bool isGuest;

  const TournamentDetailsScreen(
      {required this.currentTournament, this.isGuest = false, Key? key})
      : super(key: key);

  @override
  State<TournamentDetailsScreen> createState() =>
      _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSegmentIndex = 0;
  bool _showTeamsLeaderboard = true; // true = teams, false = debaters

  Tournament get tournament => widget.currentTournament;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Set selected segment to current segment if available
    if (tournament.currentSegmentIndex >= 0) {
      _selectedSegmentIndex = tournament.currentSegmentIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTournamentStatus() {
    final now = DateTime.now();
    if (tournament.isClosed) return 'Completed';
    if (now.isBefore(tournament.tournamentStartingDate)) return 'Upcoming';
    if (now.isAfter(tournament.tournamentEndingDate)) return 'Completed';
    return 'Active';
  }

  Color _getStatusColor() {
    final status = _getTournamentStatus();
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Upcoming':
        return Colors.orange;
      case 'Completed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateRange() {
    final start = tournament.tournamentStartingDate;
    final end = tournament.tournamentEndingDate;
    return '${_formatDate(start)} to ${_formatDate(end)}';
  }

  String _getFormatName() {
    switch (tournament.tournamentFormat) {
      case TournamentFormat.asianParliamentary:
        return 'Asian Parliamentary';
      case TournamentFormat.britishParliamentary:
        return 'British Parliamentary';
      case TournamentFormat.lincolnDouglas:
        return 'Lincoln-Douglas';
      case TournamentFormat.policyDebate:
        return 'Policy Debate';
      case TournamentFormat.publicForum:
        return 'Public Forum';
      case TournamentFormat.studentCongress:
        return 'Student Congress';
    }
  }

  int _getTotalMatchesCount() {
    int count = 0;
    if (tournament.tournamentSegments != null) {
      for (var segment in tournament.tournamentSegments!) {
        count += segment.matchesInThisSegment?.length ?? 0;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tournament Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share tournament
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit tournament
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tournament Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament.tournamentName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getTournamentStatus(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tournament
                                            .tournamentSegments?[
                                                tournament.currentSegmentIndex]
                                            .segmentName ??
                                        'Registration',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (tournament.tournamentLocation != null &&
                      tournament.tournamentLocation!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tournament.tournamentLocation!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateRange(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.white.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tournament.tournamentClubName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Statistics Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.groups,
                    value: '${tournament.numberOfTeamsInTournament}',
                    label: 'Teams',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.sports,
                    value: '${_getTotalMatchesCount()}',
                    label: 'Matches',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.person,
                    value: '${tournament.debatersInTheTournament?.length ?? 0}',
                    label: 'Debaters',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Teams'),
                Tab(text: 'Matches'),
                Tab(text: 'Leaderboard'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTeamsTab(),
                _buildMatchesTab(),
                _buildLeaderboardTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => DashScreen(
                  isRegistered: !widget.isGuest,
                ),
              ),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dashboard),
              SizedBox(width: 8),
              Text(
                'Go to Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tournament Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (tournament.tournamentDescription != null &&
              tournament.tournamentDescription!.isNotEmpty)
            _buildInfoCard(
              icon: Icons.info,
              title: 'Description',
              value: tournament.tournamentDescription!,
              color: Colors.blue,
            ),
          if (tournament.tournamentDescription != null &&
              tournament.tournamentDescription!.isNotEmpty)
            const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.language,
            title: 'Format',
            value: _getFormatName(),
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.schedule,
            title: 'Current Stage',
            value: (tournament.tournamentSegments != null &&
                    tournament.currentSegmentIndex >= 0 &&
                    tournament.currentSegmentIndex <
                        tournament.tournamentSegments!.length)
                ? tournament.tournamentSegments![tournament.currentSegmentIndex]
                    .segmentName
                : 'Registration',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          if (tournament.prizePool != null)
            _buildInfoCard(
              icon: Icons.attach_money,
              title: 'Prize Pool',
              value: '\$${tournament.prizePool!.toStringAsFixed(0)}',
              color: Colors.orange,
            ),
          if (tournament.prizePool != null) const SizedBox(height: 12),
          if (tournament.maxTeams != null)
            _buildInfoCard(
              icon: Icons.groups,
              title: 'Maximum Teams',
              value: '${tournament.maxTeams}',
              color: Colors.teal,
            ),
          if (tournament.maxTeams != null) const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.flag,
            title: 'Status',
            value: _getTournamentStatus(),
            color: _getStatusColor(),
          ),
          const SizedBox(height: 12),
          _buildTournamentManagersCard(),
          const SizedBox(height: 24),
          const Text(
            'Tournament Segments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (tournament.tournamentSegments == null ||
              tournament.tournamentSegments!.isEmpty)
            const Center(
              child: Text(
                'No segments configured yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...tournament.tournamentSegments!.asMap().entries.map((entry) {
              final index = entry.key;
              final segment = entry.value;
              final isCurrent = index == tournament.currentSegmentIndex;
              final isCompleted = index < tournament.currentSegmentIndex;
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isCurrent
                      ? const BorderSide(color: Colors.green, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? Colors.blue
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : isCurrent
                              ? Icons.play_arrow
                              : Icons.circle_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    segment.segmentName,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${segment.numberOfTeamsInSegment} teams | ${segment.matchesInThisSegment?.length ?? 0} matches',
                  ),
                  trailing: isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    final teams = tournament.teamsInTheTournament ?? [];

    if (teams.isEmpty) {
      return const Center(
        child: Text(
          'No teams registered yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Sort teams by wins first, then by score
    final sortedTeams = List<DebateTeam>.from(teams)
      ..sort((a, b) {
        if (b.teamWins != a.teamWins) {
          return b.teamWins.compareTo(a.teamWins);
        }
        return b.teamScore.compareTo(a.teamScore);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedTeams.length,
      itemBuilder: (context, index) {
        final team = sortedTeams[index];
        final memberNames = team.teamMembers
            .map((m) => m is Debater ? m.name : 'Unknown')
            .join(', ');

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: index < 3
                    ? (index == 0
                        ? Colors.amber.withOpacity(0.2)
                        : index == 1
                            ? Colors.grey.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2))
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: index < 3
                        ? (index == 0
                            ? Colors.amber.shade700
                            : index == 1
                                ? Colors.grey.shade700
                                : Colors.orange.shade700)
                        : Colors.blue,
                  ),
                ),
              ),
            ),
            title: Text(
              team.teamName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        memberNames,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildBadge('Wins: ${team.teamWins}', Colors.green),
                    _buildBadge('Losses: ${team.teamLosses}', Colors.red),
                    _buildBadge('Score: ${team.teamScore.toStringAsFixed(0)}',
                        Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchesTab() {
    final segments = tournament.tournamentSegments ?? [];

    if (segments.isEmpty) {
      return const Center(
        child: Text(
          'No segments configured yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final selectedSegment = _selectedSegmentIndex < segments.length
        ? segments[_selectedSegmentIndex]
        : segments.first;
    final matches = selectedSegment.matchesInThisSegment ?? [];

    return Column(
      children: [
        // Segment selector buttons
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: segments.asMap().entries.map((entry) {
                final index = entry.key;
                final segment = entry.value;
                final isSelected = index == _selectedSegmentIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSegmentIndex = index;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.grey.shade200,
                      foregroundColor:
                          isSelected ? Colors.white : Colors.grey.shade700,
                      elevation: isSelected ? 2 : 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      segment.segmentName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1),
        // Matches list
        Expanded(
          child: matches.isEmpty
              ? const Center(
                  child: Text(
                    'No matches in this segment.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return _buildMatchCard(match, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(DebateMatch match, int index) {
    final isCompleted = match.isCompleted;
    final teamATotal = isCompleted
        ? match.teamAScores.reduce((a, b) => a + b) + match.teamARebuttal
        : 0;
    final teamBTotal = isCompleted
        ? match.teamBScores.reduce((a, b) => a + b) + match.teamBRebuttal
        : 0;
    final teamAWon = teamATotal > teamBTotal;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Match ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (match.venue != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Venue ${match.venue}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Government',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.teamA.teamName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isCompleted && teamAWon
                              ? Colors.green.shade700
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isCompleted) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$teamATotal',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: teamAWon
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                            if (teamAWon)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Opposition',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.teamB.teamName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isCompleted && !teamAWon
                              ? Colors.green.shade700
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isCompleted) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!teamAWon)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            Text(
                              '$teamBTotal',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: !teamAWon
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Individual: ${match.teamAScores.join(' + ')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Rebuttal: ${match.teamARebuttal}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Individual: ${match.teamBScores.join(' + ')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Rebuttal: ${match.teamBRebuttal}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Column(
      children: [
        // Toggle buttons for Teams vs Debaters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showTeamsLeaderboard = true;
                    });
                  },
                  icon: const Icon(Icons.groups, size: 20),
                  label: const Text('Top Teams'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showTeamsLeaderboard
                        ? Colors.purple
                        : Colors.grey.shade200,
                    foregroundColor: _showTeamsLeaderboard
                        ? Colors.white
                        : Colors.grey.shade700,
                    elevation: _showTeamsLeaderboard ? 2 : 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showTeamsLeaderboard = false;
                    });
                  },
                  icon: const Icon(Icons.person, size: 20),
                  label: const Text('Top Debaters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_showTeamsLeaderboard
                        ? Colors.teal
                        : Colors.grey.shade200,
                    foregroundColor: !_showTeamsLeaderboard
                        ? Colors.white
                        : Colors.grey.shade700,
                    elevation: !_showTeamsLeaderboard ? 2 : 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Leaderboard content
        Expanded(
          child: _showTeamsLeaderboard
              ? _buildTeamsLeaderboard()
              : _buildDebatersLeaderboard(),
        ),
      ],
    );
  }

  Widget _buildTeamsLeaderboard() {
    final teams = tournament.teamsInTheTournament ?? [];

    if (teams.isEmpty) {
      return const Center(
        child: Text(
          'No teams registered yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final sortedTeams = List<DebateTeam>.from(teams)
      ..sort((a, b) {
        if (b.teamWins != a.teamWins) {
          return b.teamWins.compareTo(a.teamWins);
        }
        return b.teamScore.compareTo(a.teamScore);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTeams.length,
      itemBuilder: (context, index) {
        final team = sortedTeams[index];
        final isTopThree = index < 3;

        return Card(
          elevation: isTopThree ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isTopThree
              ? (index == 0
                  ? Colors.amber.shade50
                  : index == 1
                      ? Colors.grey.shade100
                      : Colors.orange.shade50)
              : Colors.white,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: index == 0
                    ? Colors.amber
                    : index == 1
                        ? Colors.grey[400]
                        : index == 2
                            ? Colors.brown[300]
                            : Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: index < 3
                    ? const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
              ),
            ),
            title: Text(
              team.teamName,
              style: TextStyle(
                fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
                fontSize: isTopThree ? 16 : 14,
              ),
            ),
            subtitle: Row(
              children: [
                _buildBadge('W: ${team.teamWins}', Colors.green),
                const SizedBox(width: 6),
                _buildBadge('L: ${team.teamLosses}', Colors.red),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${team.teamScore.toStringAsFixed(0)} pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                  fontSize: isTopThree ? 14 : 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebatersLeaderboard() {
    final debaters = tournament.debatersInTheTournament ?? [];

    if (debaters.isEmpty) {
      return const Center(
        child: Text(
          'No debaters registered yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final sortedDebaters = List<Debater>.from(debaters)
      ..sort((a, b) => b.individualScore.compareTo(a.individualScore));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDebaters.length,
      itemBuilder: (context, index) {
        final debater = sortedDebaters[index];
        final isTopThree = index < 3;

        return Card(
          elevation: isTopThree ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isTopThree
              ? (index == 0
                  ? Colors.amber.shade50
                  : index == 1
                      ? Colors.grey.shade100
                      : Colors.orange.shade50)
              : Colors.white,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: index == 0
                    ? Colors.amber
                    : index == 1
                        ? Colors.grey[400]
                        : index == 2
                            ? Colors.brown[300]
                            : Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: index < 3
                    ? const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
              ),
            ),
            title: Text(
              debater.name,
              style: TextStyle(
                fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
                fontSize: isTopThree ? 16 : 14,
              ),
            ),
            subtitle: Text(
              debater.teamName.isEmpty ? 'No Team' : debater.teamName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${debater.individualScore.toStringAsFixed(0)} pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                  fontSize: isTopThree ? 14 : 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentManagersCard() {
    final managers = tournament.usersRunningTheTournament;
    final creatorId = tournament.createdByUserID;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tournament Managers',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (managers.isEmpty && creatorId == null)
              const Text(
                'No managers assigned',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Show creator if available
                  if (creatorId != null && creatorId.isNotEmpty)
                    _buildManagerChip(
                      userId: creatorId,
                      user: managers
                          .where((u) => u.userID == creatorId)
                          .firstOrNull,
                      isCreator: true,
                    ),
                  // Show other managers (excluding creator to avoid duplicates)
                  ...managers
                      .where((u) => u.userID != creatorId)
                      .map((user) => _buildManagerChip(
                            userId: user.userID,
                            user: user,
                            isCreator: false,
                          )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerChip({
    required String userId,
    User? user,
    required bool isCreator,
  }) {
    return InkWell(
      onTap: () async {
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DebaterDetailsScreen(user: user, isGuest: widget.isGuest),
            ),
          );
        } else {
          // If we only have the userID, we need to fetch the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loading user $userId...'),
              duration: const Duration(seconds: 1),
            ),
          );
          try {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
            if (doc.exists && mounted) {
              final fetchedUser = User(
                userID: doc.data()!['userID'] ?? userId,
                name: doc.data()!['name'] ?? 'Unknown',
                email: doc.data()!['email'] ?? '',
                clubName: doc.data()!['clubName'],
                phoneNumber: doc.data()!['phoneNumber'],
                address: doc.data()!['address'],
                memberSince: doc.data()!['memberSince'] != null
                    ? (doc.data()!['memberSince'] as Timestamp).toDate()
                    : null,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DebaterDetailsScreen(
                      user: fetchedUser, isGuest: widget.isGuest),
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not found')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading user: $e')),
              );
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCreator
              ? Colors.indigo.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCreator
                ? Colors.indigo.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCreator ? Icons.star : Icons.person,
              size: 16,
              color: isCreator ? Colors.indigo : Colors.blue,
            ),
            const SizedBox(width: 6),
            Text(
              userId,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCreator ? Colors.indigo : Colors.blue,
              ),
            ),
            if (isCreator) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Creator',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: isCreator ? Colors.indigo : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
