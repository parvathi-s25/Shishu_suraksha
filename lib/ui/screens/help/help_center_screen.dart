import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> emergencyGuides = const [
    {
      "title": "CPR (Cardiopulmonary Resuscitation)",
      "steps": "1. Check responsiveness.\n2. Call for help.\n3. Open airway.\n4. Check breathing.\n5. 30 chest compressions.\n6. 2 rescue breaths.",
      "icon": "heart_broken" 
    },
    {
      "title": "High Fever Management",
      "steps": "1. Check temperature.\n2. Give Paracetamol (if prescribed).\n3. Keep child hydrated.\n4. Use tepid sponge bath.\n5. Seek medical help if > 102°F.",
      "icon": "thermostat"
    },
    {
      "title": "Severe Dehydration (ORS)",
      "steps": "1. Mix 1L clean water with 1 packet ORS.\n2. Give small sips frequently.\n3. Watch for sunken eyes/dry mouth.\n4. Rush to hospital if vomiting persists.",
      "icon": "water_drop"
    },
    {
      "title": "Choking First Aid",
      "steps": "1. Give 5 back blows.\n2. Give 5 abdominal thrusts.\n3. Repeat until object is cleared.\n4. Call emergency if unconscious.",
      "icon": "medical_services"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Quick Guide", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: emergencyGuides.length,
        itemBuilder: (context, index) {
          final guide = emergencyGuides[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(Icons.medical_information, color: Colors.blue),
              title: Text(guide['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(guide['steps']!, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
