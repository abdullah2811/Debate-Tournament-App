import 'package:debate_tournament_app/models/debate_match.dart';
import 'package:debate_tournament_app/models/tournament.dart';
import 'package:debate_tournament_app/screens/own_tournaments_screen.dart';
import 'package:debate_tournament_app/services/sort_generate_matchups.dart';
import 'package:flutter/material.dart';

class MatchupScreen extends StatefulWidget {
  final Tournament currentTournament;

  const MatchupScreen({Key? key, required this.currentTournament})
      : super(key: key);

  @override
  State<MatchupScreen> createState() => _MatchupScreenState();
}

class _MatchupScreenState extends State<MatchupScreen> {
  late List<DebateMatch> matches;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateMatches();
  }

  void _generateMatches() {
    try {
      // Get current segment and teams
      final segment = widget.currentTournament.currentSegment;
      final teams = widget.currentTournament.teamsInTheTournament ?? [];

      if (segment == null || teams.isEmpty) {
        setState(() {
          isLoading = false;
          matches = [];
        });
        return;
      }

      // Generate matchups using the sorting algorithm
      matches = generateMatchups(widget.currentTournament, segment, teams).$1;

      // Show a snackbar if matchups are not generated
      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matchups could be generated.')),
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating matchups: $e')),
        );
      }
    }
  }

  bool get _allMatchesCompleted =>
      matches.isNotEmpty && matches.every((m) => m.isCompleted);

  bool get _isFinalSegment {
    final segments = widget.currentTournament.tournamentSegments;
    final currentSegment = widget.currentTournament.currentSegment;
    if (segments == null || currentSegment == null) return false;
    return segments.last.segmentID == currentSegment.segmentID;
  }

  Future<void> _proceedToNextRound() async {
    try {
      // Find the next segment
      final segments = widget.currentTournament.tournamentSegments;
      if (segments == null) return;

      final currentIndex = segments.indexWhere(
        (s) =>
            s.segmentID == widget.currentTournament.currentSegment?.segmentID,
      );

      if (currentIndex >= 0 && currentIndex < segments.length - 1) {
        // Update to next segment
        widget.currentTournament.currentSegment = segments[currentIndex + 1];
        widget.currentTournament.currentMatches = [];

        // Save to Firestore
        await widget.currentTournament.updateTournament();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proceeding to next round...')),
          );
          Navigator.pop(context, true); // Return to own_tournaments_screen
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error proceeding to next round: $e')),
        );
      }
    }
  }

  Future<void> _closeTournament() async {
    // Capture the parent context so we can pop the screen (not just the dialog)
    final parentContext = context;

    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close Tournament'),
        content: const Text(
          'Are you sure you want to close this tournament? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close the dialog first
              try {
                widget.currentTournament.isClosed = true;
                await widget.currentTournament.updateTournament();

                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Tournament closed.')),
                  );
                  // Return to own_tournaments_screen and trigger refresh
                  Navigator.pop(parentContext, true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Error closing tournament: $e')),
                  );
                }
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
              'Matchups - ${widget.currentTournament.currentSegment?.segmentName ?? 'Round'}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.leaderboard),
              tooltip: 'Show Best Debaters',
              onPressed: _showBestDebaters,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : matches.isEmpty
                ? const Center(
                    child: Text(
                      'No matchups generated.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final match = matches[index];
                            return _buildMatchCard(match, index);
                          },
                        ),
                      ),
                      if (_allMatchesCompleted)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton.icon(
                            onPressed: _isFinalSegment
                                ? _closeTournament
                                : _proceedToNextRound,
                            icon: Icon(
                              _isFinalSegment
                                  ? Icons.close
                                  : Icons.arrow_forward,
                            ),
                            label: Text(
                              _isFinalSegment
                                  ? 'Close Tournament'
                                  : 'Proceed to Next Round',
                              style: const TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFinalSegment ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMatchCard(DebateMatch match, int index) {
    final venueText = match.venue != null ? 'Venue: ${match.venue}' : 'Venue: TBD';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Match ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            venueText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${match.teamA.teamName} vs ${match.teamB.teamName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    match.teamA.teamName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    match.teamB.teamName,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: match.isCompleted
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        match.isCompleted ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: match.isCompleted
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (match.isCompleted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'A: ${match.teamAScores.join(', ')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'B: ${match.teamBScores.join(', ')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      match.isCompleted ? null : () => _showScoresDialog(match),
                  icon: const Icon(Icons.score, size: 18),
                  label: const Text('Submit Scores'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        match.isCompleted ? Colors.grey : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScoresDialog(DebateMatch match) {
    final govDeb1 = TextEditingController();
    final govDeb2 = TextEditingController();
    final govDeb3 = TextEditingController();
    final govRebuttal = TextEditingController();

    final oppDeb1 = TextEditingController();
    final oppDeb2 = TextEditingController();
    final oppDeb3 = TextEditingController();
    final oppRebuttal = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Scores'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Government Team Scores
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Government (${match.teamA.teamName})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              _buildScoreField(govDeb1, 'Prime Minister'),
              const SizedBox(height: 8),
              _buildScoreField(govDeb2, 'Deputy Prime Minister'),
              const SizedBox(height: 8),
              _buildScoreField(govDeb3, 'Member of Government'),
              const SizedBox(height: 8),
              _buildScoreField(govRebuttal, 'Rebuttal'),
              const SizedBox(height: 20),

              // Opposition Team Scores
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Opposition (${match.teamB.teamName})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              _buildScoreField(oppDeb1, 'Leader of the Opposition'),
              const SizedBox(height: 8),
              _buildScoreField(oppDeb2, 'Deputy Leader of the Opposition'),
              const SizedBox(height: 8),
              _buildScoreField(oppDeb3, 'Member of Opposition'),
              const SizedBox(height: 8),
              _buildScoreField(oppRebuttal, 'Rebuttal'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate all fields are filled
              final govScores = [
                govDeb1.text.trim(),
                govDeb2.text.trim(),
                govDeb3.text.trim(),
                govRebuttal.text.trim(),
              ];
              final oppScores = [
                oppDeb1.text.trim(),
                oppDeb2.text.trim(),
                oppDeb3.text.trim(),
                oppRebuttal.text.trim(),
              ];

              if (govScores.any((s) => s.isEmpty) ||
                  oppScores.any((s) => s.isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all score fields.')),
                );
                return;
              }

              try {
                match.submitScores(
                  govScores.map(int.parse).toList().sublist(0, 3),
                  oppScores.map(int.parse).toList().sublist(0, 3),
                  int.parse(govScores[3]),
                  int.parse(oppScores[3]),
                  widget.currentTournament,
                );
                //Update firestore
                widget.currentTournament.updateTournament();
                // Update widget state
                setState(() {});

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Scores submitted successfully.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showBestDebaters() {
    final debaters = widget.currentTournament.debatersInTheTournament ?? [];
    
    if (debaters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No debaters found in this tournament.')),
      );
      return;
    }

    // Sort debaters by individual score in descending order
    final sortedDebaters = List.from(debaters)
      ..sort((a, b) => b.individualScore.compareTo(a.individualScore));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Best Debaters'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sortedDebaters.length,
            itemBuilder: (context, index) {
              final debater = sortedDebaters[index];
              final isTopThree = index < 3;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: isTopThree ? 3 : 1,
                color: isTopThree 
                    ? (index == 0 
                        ? Colors.amber.shade50 
                        : index == 1 
                            ? Colors.grey.shade100 
                            : Colors.orange.shade50)
                    : Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTopThree
                        ? (index == 0
                            ? Colors.amber
                            : index == 1
                                ? Colors.grey
                                : Colors.orange)
                        : Colors.blue,
                    foregroundColor: Colors.white,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    debater.name,
                    style: TextStyle(
                      fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    debater.teamName.isEmpty ? 'No Team' : debater.teamName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${debater.individualScore.toStringAsFixed(1)} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
