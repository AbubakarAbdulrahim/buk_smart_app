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

  static const Map<String, Map<String, List<String>>> academicStructure = {
    'Faculty of Basic Medical Sciences': {
      'Department of Anatomy': ['B.Sc. Anatomy'],
      'Department of Biochemistry': [
        'B.Sc. Biochemistry',
        'B.Sc. Nutrition and Dietetics',
      ],
      'Department of Human Physiology': ['B.Sc. Human Physiology'],
    },
    'Faculty of Allied Health Sciences': {
      'Department of Physiotherapy': ['Bachelor of Physiotherapy (BPT)'],
      'Department of Medical Laboratory Science': [
        'Bachelor of Medical Laboratory Science (BMLS)',
      ],
      'Department of Nursing Sciences': ['Bachelor of Nursing Science (BNSc)'],
      'Department of Medical Radiography': ['Bachelor of Radiography'],
      'Department of Optometry': ['Doctor of Optometry (OD)'],
      'Department of Environmental Health Sciences': [
        'B.Sc. Environmental Health Science',
      ],
    },
    'Faculty of Clinical Sciences': {
      'Department of Clinical Sciences': [
        'Bachelor of Medicine, Bachelor of Surgery (MBBS)',
      ],
    },
    'Faculty of Dentistry': {
      'Department of Dentistry': ['Bachelor of Dental Surgery (BDS)'],
    },
    'Faculty of Pharmaceutical Sciences': {
      'Department of Pharmaceutical Sciences': ['Doctor of Pharmacy (PharmD)'],
    },
    'Faculty of Life Sciences': {
      'Department of Biological Sciences': [
        'B.Sc. Applied Biology',
        'B.Sc. Biology',
        'B.Sc. Botany',
        'B.Sc. Zoology',
      ],
      'Department of Microbiology': ['B.Sc. Microbiology'],
    },
    'Faculty of Physical Sciences': {
      'Department of Mathematical Sciences': [
        'B.Sc. Mathematics',
        'B.Sc. Statistics',
      ],
      'Department of Physics': [
        'B.Sc. Physics',
        'B.Sc. Physics with Electronics',
        'B.Sc. Electronics with Physics',
      ],
      'Department of Pure and Industrial Chemistry': [
        'B.Sc. Chemistry',
        'B.Sc. Industrial Chemistry',
        'B.Sc. Forensic Science',
      ],
    },
    'Faculty of Agriculture': {
      'Department of Agricultural Economics & Extension': [
        'B.Agriculture (Agricultural Economics & Extension)',
        'B.Sc. Agricultural Extension (SAFE)',
      ],
      'Department of Agronomy': ['B.Agriculture (Agronomy / Soil Science)'],
      'Department of Animal Science': ['B.Agriculture (Animal Science)'],
      'Department of Crop Protection': ['B.Agriculture (Crop Protection)'],
      'Department of Soil Science': ['B.Agriculture (Soil Science)'],
      'Department of Fisheries and Aquaculture': [
        'Bachelor of Fisheries & Aquaculture',
      ],
      'Department of Food Science & Technology': [
        'Bachelor of Food Science & Technology',
      ],
      'Department of Forestry & Wildlife Management': [
        'Bachelor of Forestry & Wildlife Management',
      ],
    },
    'Faculty of Arts and Islamic Studies': {
      'Department of Arabic': ['B.A. Arabic'],
      'Department of English & Literary Studies': ['B.A. English'],
      'Department of History': ['B.A. History'],
      "Department of Islamic Studies and Shari'ah": [
        'B.A. Islamic Studies',
        'B.A. Sharia',
      ],
      'Department of Linguistics and Foreign Languages': [
        'B.A. Linguistics',
        'B.A. French',
      ],
      'Department of Nigerian Languages': ['B.A. Hausa'],
      'FAIS Combined Board': ['B.A. Arts Combined'],
    },
    'Faculty of Computing': {
      'Department of Computer Science': [
        'B.Sc. Computer Science',
        'B.Sc. Computer Science/Economics',
      ],
      'Department of Information Technology': [
        'B.Sc. Information Technology',
        'B.Sc. Cyber Security',
      ],
      'Department of Software Engineering': ['B.Sc. Software Engineering'],
    },
    'Faculty of Earth and Environmental Sciences': {
      'Department of Architecture': ['B.Sc. Architecture'],
      'Department of Environmental Management': [
        'B.Sc. Environmental Management',
      ],
      'Department of Estate Management': ['B.Sc. Estate Management'],
      'Department of Geography': [
        'B.Sc. Geography',
        'B.Sc. Geography (Science Option)',
        'B.Sc. Meteorology',
      ],
      'Department of Geology': ['B.Sc. Geology'],
      'Department of Quantity Surveying': ['B.Sc. Quantity Surveying'],
      'Department of Urban and Regional Planning': [
        'Bachelor of Urban & Regional Planning',
      ],
    },
    'Faculty of Education': {
      'Department of Adult Education & Community Services': [
        'B.Ed. Adult Education and Community Development',
        'B.A. (Ed) Adult Education',
        'B.Sc. (Ed) Adult Education',
      ],
      'Department of Education': [
        'B.A. (Ed) Education',
        'B.A. (Ed) Primary Education',
        'B.A. (Ed) Early Childhood Education',
      ],
      'Department of Library & Information Science': [
        'B.A./B.Sc. Library and Information Science',
      ],
      'Department of Physical & Health Education': [
        'B.Sc. (Ed) Physical Education',
        'B.Sc. (Ed) Health Education',
      ],
      'Department of Science & Technical Education': [
        'B.Sc. (Ed) Science Education',
        'Bachelor of Technology Education',
        'B.Sc. (Ed) Geography',
      ],
      'Department of Special Education': [
        'B.A. (Ed) Special Education',
        'B.Sc. (Ed) Special Education',
      ],
    },
    'Faculty of Engineering': {
      'Department of Agricultural & Biosystems Engineering': [
        'B.Eng. Agricultural and Environmental Engineering',
        'B.Eng. Irrigation Engineering',
      ],
      'Department of Chemical & Petroleum Engineering': [
        'B.Eng. Chemical Engineering',
        'B.Eng. Petroleum Engineering',
      ],
      'Department of Civil Engineering': ['B.Eng. Civil Engineering'],
      'Department of Electrical Engineering': ['B.Eng. Electrical Engineering'],
      'Department of Computer Engineering': ['B.Eng. Computer Engineering'],
      'Department of Telecommunications Engineering': [
        'B.Eng. Telecommunication Engineering',
      ],
      'Department of Mechanical Engineering': [
        'B.Eng. Mechanical Engineering',
        'B.Eng. Automotive Engineering',
      ],
      'Department of Mechatronics Engineering': [
        'B.Eng. Mechatronics Engineering',
      ],
    },
    'Faculty of Law': {
      'Department of Law': ['LL.B (Common and Islamic Law)'],
    },
    'Faculty of Communication and Media Studies': {
      'Department of Broadcasting and Journalism': [
        'B.Sc. Mass Communication (Broadcasting/Journalism)',
      ],
      'Department of Public Relations and Advertising': [
        'B.Sc. Mass Communication (Public Relations & Advertising)',
      ],
      'Department of Development & Strategic Communication': [
        'B.Sc. Mass Communication (Development Communication)',
      ],
      'Department of Information, Media Studies, and Film & Multimedia': [
        'B.Sc. Information and Media Studies',
      ],
      'Department of Theatre & Performing Arts': [
        'B.A. Theatre and Performing Arts',
      ],
    },
    'Faculty of Management Sciences': {
      'Department of Accounting': ['B.Sc. Accounting', 'B.Sc. Taxation'],
      'Department of Business Administration & Entrepreneurship': [
        'B.Sc. Business Administration',
        'B.Sc. Entrepreneurship',
      ],
      'Department of Finance': [
        'B.Sc. Finance',
        'B.Sc. Banking and Finance',
      ],
      'Department of Public Administration': ['B.Sc. Public Administration'],
    },
    'Faculty of Social Sciences': {
      'Department of Economics': ['B.Sc. Economics'],
      'Department of Political Science': [
        'B.Sc. Political Science',
        'B.Sc. International Relations',
      ],
      'Department of Sociology': ['B.Sc. Sociology', 'B.Sc. Criminology'],
    },
    'Faculty of Veterinary Medicine': {
      'Department of Veterinary Medicine': [
        'Doctor of Veterinary Medicine (DVM)',
      ],
    },
  };

  static List<String> get faculties => academicStructure.keys.toList();

  static List<String> departmentsFor(String? faculty) {
    if (faculty == null) return const [];
    return academicStructure[faculty]?.keys.toList() ?? const [];
  }

  static List<String> programsFor(String? faculty, String? department) {
    if (faculty == null || department == null) return const [];
    return academicStructure[faculty]?[department] ?? const [];
  }
}
