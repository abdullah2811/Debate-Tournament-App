import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debate_tournament_app/models/tournament.dart';
import 'package:debate_tournament_app/models/user.dart';
import 'package:debate_tournament_app/screens/add_teams_screen.dart';
import 'package:debate_tournament_app/screens/matchup_screen.dart';
import 'package:debate_tournament_app/screens/tournament_details_screen.dart';
import 'package:debate_tournament_app/screens/tournament_roadmap_screen.dart';
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
  List<Tournament> _allTournaments =
      []; // It will be used when sorting or filtering implementations are added
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
      final segment = t.tournamentSegments?[t.currentSegmentIndex]
              .toString()
              .toLowerCase() ??
          '';
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
    } else if (isCompleted || tournament.isClosed) {
      status = 'Completed';
    } else {
      status = 'Active';
    }

    final matchesCount = tournament
            .tournamentSegments?[tournament.currentSegmentIndex]
            .matchesInThisSegment
            ?.length ??
        0;
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
                  if (tournament.isClosed == false)
                    TextButton.icon(
                      onPressed: () => _editTournament(tournament),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  const SizedBox(width: 4),
                  if (tournament.isClosed == false)
                    TextButton.icon(
                      onPressed: () => _confirmDeleteTournament(tournament),
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  const SizedBox(width: 4),
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
                    'Segment: ${tournament.tournamentSegments?[tournament.currentSegmentIndex].segmentName ?? 'Registration'}',
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
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (tournament.isClosed == false)
                    TextButton.icon(
                      onPressed: () async {
                        // Refresh tournament before navigation to get latest segments and currentSegment
                        if (additionClosed) {
                          final refreshed = await Tournament.getTournament(
                              tournament.tournamentID);
                          if (refreshed != null && mounted) {
                            tournament = refreshed;
                          }
                          if (tournament.currentSegmentIndex == -1) {
                            tournament.proceedToNextSegment();
                          }
                        }

                        if (!mounted) return;

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => additionClosed
                                ? MatchupScreen(currentTournament: tournament)
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
                      label: Text(
                          additionClosed ? 'Generate Matchups' : 'Add Teams'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  if (tournament.isClosed == false)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentRoadmapScreen(
                                currentTournament: tournament),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Configure Rounds'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TournamentDetailsScreen(
                                currentTournament: tournament)),
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

  Future<void> _editTournament(Tournament tournament) async {
    final nameCtrl = TextEditingController(text: tournament.tournamentName);
    final clubCtrl = TextEditingController(text: tournament.tournamentClubName);
    final locationCtrl =
        TextEditingController(text: tournament.tournamentLocation ?? '');
    final descriptionCtrl =
        TextEditingController(text: tournament.tournamentDescription ?? '');
    final maxTeamsCtrl =
        TextEditingController(text: tournament.maxTeams?.toString() ?? '');
    final prizePoolCtrl =
        TextEditingController(text: tournament.prizePool?.toString() ?? '');

    DateTime startDate = tournament.tournamentStartingDate;
    DateTime endDate = tournament.tournamentEndingDate;

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (statefulContext, setLocalState) {
          Future<void> pickStart() async {
            final picked = await showDatePicker(
              context: dialogContext,
              initialDate: startDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setLocalState(() => startDate = picked);
            }
          }

          Future<void> pickEnd() async {
            final picked = await showDatePicker(
              context: dialogContext,
              initialDate: endDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setLocalState(() => endDate = picked);
            }
          }

          return AlertDialog(
            title: const Text('Edit Tournament'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextFieldCtrl(nameCtrl, 'Tournament Name', Icons.title),
                  const SizedBox(height: 10),
                  _buildTextFieldCtrl(clubCtrl, 'Club/Organizer', Icons.school),
                  const SizedBox(height: 10),
                  _buildTextFieldCtrl(
                      locationCtrl, 'Location', Icons.location_on),
                  const SizedBox(height: 10),
                  _buildTextFieldCtrl(
                      descriptionCtrl, 'Description', Icons.description,
                      maxLines: 3),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickStart,
                          icon: const Icon(Icons.date_range),
                          label: Text(
                              'Start: ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickEnd,
                          icon: const Icon(Icons.event),
                          label: Text(
                              'End: ${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextFieldCtrl(
                    maxTeamsCtrl,
                    'Max Teams (optional)',
                    Icons.groups,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _buildTextFieldCtrl(
                    prizePoolCtrl,
                    'Prize Pool (optional)',
                    Icons.attach_money,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Basic validation
                  if (nameCtrl.text.trim().isEmpty ||
                      clubCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content: Text('Name and Club are required.')),
                    );
                    return;
                  }

                  // Apply edits to model
                  tournament.tournamentName = nameCtrl.text.trim();
                  tournament.tournamentClubName = clubCtrl.text.trim();
                  tournament.tournamentLocation =
                      locationCtrl.text.trim().isEmpty
                          ? null
                          : locationCtrl.text.trim();
                  tournament.tournamentDescription =
                      descriptionCtrl.text.trim().isEmpty
                          ? null
                          : descriptionCtrl.text.trim();
                  tournament.tournamentStartingDate = startDate;
                  tournament.tournamentEndingDate = endDate;

                  final maxTeamsVal = int.tryParse(maxTeamsCtrl.text.trim());
                  final prizePoolVal =
                      double.tryParse(prizePoolCtrl.text.trim());

                  tournament.maxTeams = maxTeamsVal;
                  tournament.prizePool = prizePoolVal;

                  try {
                    await tournament.updateTournament();
                    if (mounted) {
                      Navigator.pop(dialogContext);
                      _loadTournaments();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tournament updated.')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _confirmDeleteTournament(Tournament tournament) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Text(
            'Are you sure you want to delete "${tournament.tournamentName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                // deleteTournament() is async void; call and then reload
                tournament.deleteTournament();
                await Future.delayed(const Duration(milliseconds: 300));
                _loadTournaments();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tournament deleted.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete tournament: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldCtrl(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
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
