import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Advertising package types
enum AdPackageType {
  banner,
  featured,
  push,
  premium,
}

/// Advertising target audience
enum AdTargetAudience {
  all,
  subscribers,
  nonSubscribers,
  ageGroup,
  region,
}

/// Advertising package model
class AdPackage {
  final String id;
  final String name;
  final String description;
  final AdPackageType type;
  final int price;
  final int durationDays;
  final int impressions;
  final double clickRate;
  final List<String> features;
  final bool isPopular;
  final bool isBestValue;

  const AdPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.impressions,
    required this.clickRate,
    required this.features,
    this.isPopular = false,
    this.isBestValue = false,
  });
}

/// Mock advertising packages
final List<AdPackage> adPackages = [
  AdPackage(
    id: 'banner_basic',
    name: 'Basic Banner',
    description: 'Entry-level banner advertising',
    type: AdPackageType.banner,
    price: 50000,
    durationDays: 7,
    impressions: 10000,
    clickRate: 2.5,
    features: [
      'Home feed banner',
      'Basic targeting',
      'Performance report',
    ],
  ),
  AdPackage(
    id: 'banner_pro',
    name: 'Pro Banner',
    description: 'Enhanced banner with better placement',
    type: AdPackageType.banner,
    price: 150000,
    durationDays: 14,
    impressions: 50000,
    clickRate: 3.5,
    features: [
      'Prime placement',
      'Advanced targeting',
      'Real-time analytics',
      'A/B testing',
    ],
    isPopular: true,
  ),
  AdPackage(
    id: 'featured_idol',
    name: 'Featured Idol',
    description: 'Get featured on the discover page',
    type: AdPackageType.featured,
    price: 300000,
    durationDays: 7,
    impressions: 100000,
    clickRate: 5.0,
    features: [
      'Discover page feature',
      'Trending section',
      'Push notification',
      'Social sharing boost',
    ],
  ),
  AdPackage(
    id: 'push_campaign',
    name: 'Push Campaign',
    description: 'Direct push notifications to fans',
    type: AdPackageType.push,
    price: 200000,
    durationDays: 3,
    impressions: 30000,
    clickRate: 8.0,
    features: [
      'Direct push notification',
      'Custom message',
      'Target timing',
      'Click tracking',
    ],
  ),
  AdPackage(
    id: 'premium_spotlight',
    name: 'Premium Spotlight',
    description: 'Maximum exposure package',
    type: AdPackageType.premium,
    price: 500000,
    durationDays: 30,
    impressions: 500000,
    clickRate: 4.5,
    features: [
      'All ad placements',
      'Priority support',
      'Custom creatives',
      'Dedicated manager',
      'Monthly report',
      'ROI guarantee',
    ],
    isBestValue: true,
  ),
];

class AdvertisingPurchaseScreen extends ConsumerStatefulWidget {
  const AdvertisingPurchaseScreen({super.key});

  @override
  ConsumerState<AdvertisingPurchaseScreen> createState() =>
      _AdvertisingPurchaseScreenState();
}

class _AdvertisingPurchaseScreenState
    extends ConsumerState<AdvertisingPurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AdPackage? _selectedPackage;
  AdTargetAudience _targetAudience = AdTargetAudience.all;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Advertising'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Packages', icon: Icon(Icons.local_offer)),
            Tab(text: 'Create Ad', icon: Icon(Icons.add_circle)),
            Tab(text: 'My Ads', icon: Icon(Icons.campaign)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPackagesTab(),
          _buildCreateAdTab(),
          _buildMyAdsTab(),
        ],
      ),
    );
  }

  Widget _buildPackagesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header stats
        _buildStatsHeader(),
        const SizedBox(height: 20),

        // Package categories
        const Text(
          'Advertising Packages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Package cards
        ...adPackages.map((package) => _buildPackageCard(package)),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Advertising Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Total Spent', '\$1,250', Icons.payments),
              _buildStatItem('Impressions', '125K', Icons.visibility),
              _buildStatItem('Clicks', '4.2K', Icons.touch_app),
              _buildStatItem('CTR', '3.4%', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(AdPackage package) {
    final isSelected = _selectedPackage?.id == package.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.deepPurple : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedPackage = package),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPackageIcon(package.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              package.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(package.price / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            '${package.durationDays} days',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricChip(
                        Icons.visibility,
                        '${(package.impressions / 1000).toStringAsFixed(0)}K impressions',
                      ),
                      const SizedBox(width: 8),
                      _buildMetricChip(
                        Icons.touch_app,
                        '${package.clickRate}% CTR',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: package.features
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showPurchaseDialog(package),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Purchase This Package'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (package.isPopular)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (package.isBestValue)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageIcon(AdPackageType type) {
    IconData icon;
    Color color;

    switch (type) {
      case AdPackageType.banner:
        icon = Icons.view_carousel;
        color = Colors.blue;
        break;
      case AdPackageType.featured:
        icon = Icons.star;
        color = Colors.amber;
        break;
      case AdPackageType.push:
        icon = Icons.notifications_active;
        color = Colors.red;
        break;
      case AdPackageType.premium:
        icon = Icons.diamond;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildMetricChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAdTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Campaign details
        _buildSectionCard(
          'Campaign Details',
          Icons.campaign,
          Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Campaign Name',
                  hintText: 'e.g., Summer Concert Promotion',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Campaign Description',
                  hintText: 'Describe your campaign goals...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Target audience
        _buildSectionCard(
          'Target Audience',
          Icons.people,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AdTargetAudience.values.map((audience) {
                  final isSelected = _targetAudience == audience;
                  return ChoiceChip(
                    label: Text(_getAudienceLabel(audience)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _targetAudience = audience);
                      }
                    },
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                _getAudienceDescription(_targetAudience),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Schedule
        _buildSectionCard(
          'Schedule',
          Icons.calendar_today,
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_arrow, color: Colors.green),
                title: const Text('Start Date'),
                subtitle: Text(
                  '${_startDate.year}/${_startDate.month}/${_startDate.day}',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                  child: const Text('Change'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Budget
        _buildSectionCard(
          'Budget',
          Icons.attach_money,
          Column(
            children: [
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Daily Budget',
                  hintText: 'Enter amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.payments),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recommended: \$50-100/day for optimal reach',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Creative upload
        _buildSectionCard(
          'Creative Assets',
          Icons.image,
          Column(
            children: [
              InkWell(
                onTap: () {
                  // TODO: Implement image picker
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click to upload banner image',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Recommended: 1200x628px',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit button
        ElevatedButton(
          onPressed: () => _showCreateConfirmation(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Create Campaign',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildMyAdsTab() {
    final mockCampaigns = [
      {
        'name': 'Summer Live Concert',
        'status': 'active',
        'budget': 150000,
        'spent': 45000,
        'impressions': 32500,
        'clicks': 1250,
        'startDate': '2024/01/15',
        'endDate': '2024/01/22',
      },
      {
        'name': 'New Album Release',
        'status': 'completed',
        'budget': 300000,
        'spent': 300000,
        'impressions': 125000,
        'clicks': 4200,
        'startDate': '2024/01/01',
        'endDate': '2024/01/14',
      },
      {
        'name': 'Fan Meeting Promo',
        'status': 'scheduled',
        'budget': 200000,
        'spent': 0,
        'impressions': 0,
        'clicks': 0,
        'startDate': '2024/02/01',
        'endDate': '2024/02/07',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Campaign Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryItem('Active', '1', Colors.green),
                  _buildSummaryItem('Scheduled', '1', Colors.blue),
                  _buildSummaryItem('Completed', '1', Colors.grey),
                  _buildSummaryItem('Total', '3', Colors.deepPurple),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'My Campaigns',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Campaign list
        ...mockCampaigns.map((campaign) => _buildCampaignCard(campaign)),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    Color statusColor;
    IconData statusIcon;

    switch (campaign['status']) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.play_circle;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    final budget = campaign['budget'] as int;
    final spent = campaign['spent'] as int;
    final progress = budget > 0 ? spent / budget : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      (campaign['status'] as String).toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${(budget / 1000).toStringAsFixed(0)}K',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impressions',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${((campaign['impressions'] as int) / 1000).toStringAsFixed(1)}K',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clicks',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${((campaign['clicks'] as int) / 1000).toStringAsFixed(1)}K',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CTR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      campaign['impressions'] as int > 0
                          ? '${((campaign['clicks'] as int) / (campaign['impressions'] as int) * 100).toStringAsFixed(1)}%'
                          : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget spent: \$${(spent / 1000).toStringAsFixed(1)}K',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.date_range, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${campaign['startDate']} - ${campaign['endDate']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAudienceLabel(AdTargetAudience audience) {
    switch (audience) {
      case AdTargetAudience.all:
        return 'All Users';
      case AdTargetAudience.subscribers:
        return 'Subscribers';
      case AdTargetAudience.nonSubscribers:
        return 'Non-Subscribers';
      case AdTargetAudience.ageGroup:
        return 'Age Group';
      case AdTargetAudience.region:
        return 'By Region';
    }
  }

  String _getAudienceDescription(AdTargetAudience audience) {
    switch (audience) {
      case AdTargetAudience.all:
        return 'Your ad will be shown to all users on the platform.';
      case AdTargetAudience.subscribers:
        return 'Target only users who are already subscribed to you.';
      case AdTargetAudience.nonSubscribers:
        return 'Target users who haven\'t subscribed yet - great for growth.';
      case AdTargetAudience.ageGroup:
        return 'Target specific age demographics (18-24, 25-34, etc.)';
      case AdTargetAudience.region:
        return 'Target users from specific countries or regions.';
    }
  }

  void _showPurchaseDialog(AdPackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            _buildPackageIcon(package.type),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                package.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(package.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDialogRow('Duration', '${package.durationDays} days'),
                  _buildDialogRow(
                      'Est. Impressions', '${package.impressions / 1000}K'),
                  _buildDialogRow('Est. CTR', '${package.clickRate}%'),
                  const Divider(),
                  _buildDialogRow(
                    'Total Price',
                    '\$${(package.price / 1000).toStringAsFixed(0)}K',
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentSuccess(package);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.deepPurple : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccess(AdPackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Purchase Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${package.name} campaign will start shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _tabController.animateTo(2); // Go to My Ads tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View My Campaigns'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Create Campaign?'),
        content: const Text(
          'Your campaign will be reviewed and activated within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Campaign submitted for review!'),
                  backgroundColor: Colors.green,
                ),
              );
              _tabController.animateTo(2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
