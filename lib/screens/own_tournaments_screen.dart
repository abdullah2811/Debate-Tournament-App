import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debate_tournament_app/models/tournament.dart';
import 'package:debate_tournament_app/models/user.dart';
import 'package:debate_tournament_app/screens/add_teams_screen.dart';
import 'package:debate_tournament_app/screens/next_round_details.dart';
import 'package:debate_tournament_app/screens/tournament_details_screen.dart';
import 'package:flutter/material.dart';

class OwnTournamentsScreen extends StatefulWidget {
  final User currentUser;

  const OwnTournamentsScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<OwnTournamentsScreen> createState() => _OwnTournamentsScreenState();
}

class _OwnTournamentsScreenState extends State<OwnTournamentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Tournament> _allTournaments = [];
  List<Tournament> _filteredTournaments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final results = _filteredTournaments.where((t) {
      if (query.isEmpty) return true;
      final segment = t.currentSegment.toString().toLowerCase();
      return t.tournamentName.toLowerCase().contains(query) ||
          t.tournamentClubName.toLowerCase().contains(query) ||
          segment.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Tournaments'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search my tournaments...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? const Center(
                        child: Text(
                          'No tournaments found.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final tournament = results[index];
                          return _buildTournamentCard(tournament);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTournaments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tournaments')
          .where('createdByUserID', isEqualTo: widget.currentUser.userID)
          // Avoid composite index requirement by ordering client-side.
          .get();

      final tournaments =
          snapshot.docs.map((doc) => Tournament.fromJson(doc.data())).toList()
            ..sort((a, b) {
              final aDate = a.createdAt ?? a.tournamentStartingDate;
              final bDate = b.createdAt ?? b.tournamentStartingDate;
              return bDate.compareTo(aDate); // newest first
            });

      setState(() {
        _allTournaments = tournaments;
        _filteredTournaments = tournaments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tournaments: $e')),
        );
      }
    }
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final now = DateTime.now();
    final isUpcoming = now.isBefore(tournament.tournamentStartingDate);
    final isCompleted = now.isAfter(tournament.tournamentEndingDate);
    final isActive = !isUpcoming && !isCompleted;

    String status;
    if (isUpcoming) {
      status = 'Upcoming';
    } else if (isCompleted) {
      status = 'Completed';
    } else {
      status = 'Active';
    }

    final segmentName = tournament.currentSegment;

    final matchesCount = tournament.currentMatches?.length ?? 0;
    final additionClosed = tournament.teamAdditionClosed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to tournament details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            color: isActive
                                ? Colors.green.shade900
                                : Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tournament.tournamentStartingDate.year}',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tournament.tournamentName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tournament.tournamentClubName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.timeline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    segmentName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.groups,
                    label: '${tournament.numberOfTeamsInTournament} Teams',
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    icon: Icons.sports,
                    label: '$matchesCount Matches',
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => additionClosed
                              ? const NextRoundDetailsScreen()
                              : AddTeamsScreen(currentTournament: tournament),
                        ),
                      );
                      // Refresh tournaments list if changes were made
                      if (result == true) {
                        _loadTournaments();
                      }
                    },
                    icon: Icon(
                      additionClosed ? Icons.settings : Icons.build,
                      size: 18,
                    ),
                    label: Text(additionClosed ? 'Manage' : 'Add Teams'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TournamentDetailsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
