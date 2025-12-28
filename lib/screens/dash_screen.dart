import 'package:debate_tournament_app/screens/adjudicator_screen.dart';
import 'package:debate_tournament_app/screens/create_a_tournament_screen.dart';
import 'package:debate_tournament_app/screens/own_tournaments_screen.dart';
import 'package:debate_tournament_app/screens/search_debaters_screen.dart';
import 'package:debate_tournament_app/screens/search_tournaments_screen.dart';
import 'package:flutter/material.dart';

import '../models/user.dart' as app_user;
import 'profile_screen.dart';

class DashScreen extends StatelessWidget {
  final app_user.User? currentUser;
  final bool isRegistered;

  const DashScreen({
    Key? key,
    this.currentUser,
    this.isRegistered = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isRegistered)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
          if (isRegistered)
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                if (currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(currentUser: currentUser!),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Section
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
                    Text(
                      isRegistered ? 'Welcome Back!' : 'Welcome!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRegistered
                          ? 'Manage your debate tournaments'
                          : 'Browse tournaments and debaters',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats Section (Only for registered users)
            if (isRegistered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.sports,
                        title: 'Active',
                        value: '12',
                        subtitle: 'Tournaments',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.groups,
                        title: 'Total',
                        value: '48',
                        subtitle: 'Teams',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.person,
                        title: 'Total',
                        value: '144',
                        subtitle: 'Debaters',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Main Options Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRegistered ? 'Quick Actions' : 'Browse',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Create Tournament Card (Only for registered users)
                  if (isRegistered)
                    _buildActionCard(
                      context: context,
                      icon: Icons.add_circle,
                      title: 'Create a Tournament',
                      subtitle: 'Start a new debate tournament',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateATournamentScreen(),
                          ),
                        );
                      },
                    ),

                  if (isRegistered) const SizedBox(height: 12),

                  // Adjudicator Area Card (Only for registered users)
                  if (isRegistered)
                    _buildActionCard(
                      context: context,
                      icon: Icons.gavel,
                      title: 'Adjudicator Area',
                      subtitle: 'Manage adjudicators and assignments',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdjudicatorScreen(),
                          ),
                        );
                      },
                    ),

                  if (isRegistered) const SizedBox(height: 12),

                  // Manage Tournaments Card (Only for registered users)
                  if (isRegistered)
                    _buildActionCard(
                      context: context,
                      icon: Icons.edit,
                      title: 'Manage Your Tournaments',
                      subtitle: 'View and edit your tournaments',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OwnTournamentsScreen(currentUser: currentUser!),
                          ),
                        );
                      },
                    ),

                  if (isRegistered) const SizedBox(height: 12),

                  // Search Tournaments Card
                  _buildActionCard(
                    context: context,
                    icon: Icons.search,
                    title: 'Search Tournaments',
                    subtitle: 'Browse all available tournaments',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchTournamentsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Search Debaters Card
                  _buildActionCard(
                    context: context,
                    icon: Icons.person_search,
                    title: 'Search Debaters',
                    subtitle: 'Find debaters and their statistics',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchDebatersScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity Section (Only for registered users)
                  if (isRegistered)
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                  if (isRegistered) const SizedBox(height: 16),

                  if (isRegistered)
                    _buildActivityCard(
                      icon: Icons.sports,
                      title: 'Inter-University Debate 2025',
                      subtitle: 'Preliminary Round 2 in progress',
                      time: '2 hours ago',
                      color: Colors.blue,
                    ),

                  if (isRegistered) const SizedBox(height: 12),

                  if (isRegistered)
                    _buildActivityCard(
                      icon: Icons.groups,
                      title: 'New team registered',
                      subtitle: 'Phoenix Debaters joined tournament',
                      time: '5 hours ago',
                      color: Colors.green,
                    ),

                  if (isRegistered) const SizedBox(height: 12),

                  if (isRegistered)
                    _buildActivityCard(
                      icon: Icons.emoji_events,
                      title: 'Tournament completed',
                      subtitle: 'National Debate Championship 2025',
                      time: '1 day ago',
                      color: Colors.orange,
                    ),

                  if (isRegistered) const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
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
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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
}
