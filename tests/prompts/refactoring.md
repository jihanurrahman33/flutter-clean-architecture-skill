# Test Scenario: Refactoring Legacy Monolithic Code

## Input Task Prompt
```text
Refactor this legacy monolithic StatefulWidget into Clean Architecture:

class LegacyProfileScreen extends StatefulWidget {
  @override
  _LegacyProfileScreenState createState() => _LegacyProfileScreenState();
}

class _LegacyProfileScreenState extends State<LegacyProfileScreen> {
  Map<String, dynamic>? userJson;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);
    final response = await http.get(Uri.parse('https://api.example.com/user'));
    setState(() {
      userJson = jsonDecode(response.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return CircularProgressIndicator();
    return Text(userJson?['name'] ?? '');
  }
}
```
