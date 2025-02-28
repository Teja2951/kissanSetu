import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GovernmentSchemes extends StatefulWidget {
  const GovernmentSchemes({super.key});

  @override
  State<GovernmentSchemes> createState() => _GovernmentSchemesState();
}

class _GovernmentSchemesState extends State<GovernmentSchemes> {
  final SupabaseClient supabase = Supabase.instance.client;


  final Stream<List<Map<String, dynamic>>> _stream = Supabase.instance.client
      .from('blogs')
      .stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Government Schemes")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          final List<Map<String, dynamic>> data = List.from(snapshot.data!);

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _buildCards(item);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildCards(Map<String,dynamic> item) {
    return Card(
      child: ListTile(
        title: Text(item['title']),
        subtitle: Text(item['content']),
      ),
    );
  }

}
