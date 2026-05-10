import 'package:flutter/material.dart';

class QuickActionItem {
  const QuickActionItem(this.title, this.icon, this.bgColor, this.iconColor);

  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
}

class ResourceItem {
  const ResourceItem(this.title, this.subtitle, this.icon, this.bgColor);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
}

class AppData {
  static const incidentTypes = [
    'Insecurity',
    'Theft',
    'Emergency',
    'Power Outage',
    'Water Outage',
  ];

  static const chatbotActions = [
    'Report an Incident',
    'Find Past Questions',
    'University Rules',
    'Scholarships',
    'Other Help',
  ];
}
