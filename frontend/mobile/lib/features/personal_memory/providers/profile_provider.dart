import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  return [
    {"field": "മുഴുവൻ പേര് (Full Name)", "value": "മാധവൻ നായർ (Madhavan Nair)"},
    {"field": "ജനനതീയതി (Date of Birth)", "value": "12-04-1952"},
    {"field": "രക്തഗ്രൂപ്പ് (Blood Group)", "value": "O+ve"},
    {
      "field": "മേൽവിലാസം (Address)",
      "value": "ശാന്തിനിലയം, കോട്ടയം, കേരളം 686001"
    },
  ];
});
