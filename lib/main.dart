import 'package:flutter/material.dart';

void main() {
  runApp(CodeLearnerApp());
}

class CodeLearnerApp extends StatelessWidget {
  const CodeLearnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeLearner',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}

// Simple in-app user profile (UI-only)
class UserProfile extends ChangeNotifier {
  String firstName = '';
  String lastName = '';
  String email = '';
  void update({String? first, String? last, String? mail}) {
    if (first != null) firstName = first;
    if (last != null) lastName = last;
    if (mail != null) email = mail;
    notifyListeners();
  }
}

final userProfile = UserProfile();

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.code, size: 100, color: Colors.tealAccent),
              ),
            ),
            const SizedBox(height: 12),
            const Text('CodeLearner', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// -------------------- Authentication Screens --------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    userProfile.update(mail: email);
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => loading = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                onSaved: (v) => email = v ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => v != null && v.length >= 6 ? null : 'Password min 6 chars',
                onSaved: (v) => password = v ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : _login,
                child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SignupPage())),
                child: const Text("Don't have an account? Sign up"),
              ),
              const Divider(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminLoginPage())),
                  child: const Text('Admin Portal'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    await Future.delayed(const Duration(milliseconds: 600));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                onSaved: (v) => email = v ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6 ? null : 'Password min 6 chars',
                onSaved: (v) => password = v ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _signup, child: const Text('Create account')),
            ],
          ),
        ),
      ),
    );
  }
}
// -------------------- Main App Shell with Bottom Navigation --------------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _pages = [const SubmitCodePage(), const SettingsPage(), const TopicHelpNewPage(), const StarPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomItem(icon: _HomeLogoIcon()),
          BottomItem(icon: Icon(Icons.settings, color: Colors.black)),
          BottomItem(icon: Icon(Icons.menu_book_outlined, color: Colors.black)),
          BottomItem(icon: Icon(Icons.star, color: Colors.black)),
        ],
      ),
    );
  }
}
// -------------------- Home Page --------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CodeLearner - Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome to CodeLearner',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Quick actions', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SubmitCodePage())),
                    icon: const Icon(Icons.code),
                    label: const Text('Submit Code')),
                OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TopicHelpNewPage())),
                    icon: const Icon(Icons.school),
                    label: const Text('Topic Help')),
                OutlinedButton.icon(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const FeedbackDialog()),
                    icon: const Icon(Icons.feedback),
                    label: const Text('Feedback')),
                OutlinedButton.icon(
                    onPressed: () => showDialog(
                        context: context, builder: (_) => RatingDialog()),
                    icon: const Icon(Icons.star_rate),
                    label: const Text('Rate App')),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Recent activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: List.generate(
                    4,
                    (i) => ListTile(
                          leading: const Icon(Icons.history),
                          title: Text('Submission #${i + 1}'),
                          subtitle: const Text('Python — Fixed loop efficiency'),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ResultPage(sample: true))),
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// -------------------- Topic Help Flow --------------------

class TopicExplanationPage extends StatelessWidget {
  final String topic;
  const TopicExplanationPage({super.key, required this.topic});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$topic — Explanation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Explanation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_topicLabels[topic]?['description'] ?? 'High-level overview of $topic with key rules and pitfalls.'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TopicSnippetPage(topic: topic))), child: Text(_topicLabels[topic]?['example'] ?? 'Example Code'))),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitCodePage(initialTopic: topic))), child: Text(_topicLabels[topic]?['try'] ?? 'Try It')),
          ]),
        ]),
      ),
    );
  }
}

class TopicSnippetPage extends StatelessWidget {
  final String topic;
  const TopicSnippetPage({super.key, required this.topic});
  @override
  Widget build(BuildContext context) {
    final code = _topicLabels[topic]?['exampleCode'] ??
        '// Example code for $topic\nfor (int i = 0; i < n; i++) {\n  // ...\n}';
    return Scaffold(
      appBar: AppBar(title: Text('$topic — Example Snippet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade800)),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(code, style: const TextStyle(fontFamily: 'monospace'))),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitCodePage(initialTopic: topic))), child: const Text('Try it'))),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          ])
        ]),
      ),
    );
  }
}
// -------------------- Submit Code Page --------------------
class SubmitCodePage extends StatefulWidget {
  final String? initialTopic;
  const SubmitCodePage({super.key, this.initialTopic});
  @override
  State<SubmitCodePage> createState() => _SubmitCodePageState();
}

class _SubmitCodePageState extends State<SubmitCodePage> {
  final _codeController = TextEditingController();
  String selectedLanguage = 'Auto-detect';
  bool submitting = false;

  void _submit() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please paste your code first')));
      return;
    }
    setState(() => submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => submitting = false);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(sample: false, code: _codeController.text, language: selectedLanguage)));
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialTopic != null) {
      _codeController.text = '// Try solving a ${widget.initialTopic} problem here';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Code')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedLanguage,
                    items: ['Auto-detect', 'Python', 'Java', 'C++', 'JavaScript', 'Dart'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => selectedLanguage = v ?? 'Auto-detect'),
                    decoration: const InputDecoration(labelText: 'Language'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Auto-detect placeholder'))); }, child: const Text('Detect'))
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade700), borderRadius: BorderRadius.circular(6)),
                child: const _CodeEditor(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: submitting ? null : _submit, child: submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit'))),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => _codeController.clear(), child: const Text('Clear')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeEditor extends StatefulWidget {
  const _CodeEditor();
  @override
  State<_CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<_CodeEditor> {
  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_SubmitCodePageState>();
    return TextField(
      controller: parent!._codeController,
      expands: true,
      maxLines: null,
      minLines: null,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Paste your code here...'),
    );
  }
}
// -------------------- Result / Comparison Page --------------------
class ResultPage extends StatelessWidget {
  final bool sample;
  final String? code;
  final String? language;
  const ResultPage({super.key, this.sample = false, this.code, this.language});

  @override
  Widget build(BuildContext context) {
    final userCode = sample ? 'for i in range(n):\n  print(i)' : (code ?? '// No code submitted');
    final aiSolution = sample ? 'for i in range(n):\n  # optimized version\n  print(i)' : '// AI suggested optimized code goes here';
    final explanation = sample ? 'AI found an inefficiency in loop and suggested ...' : 'AI explanation placeholder';

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Language: ${language ?? 'Auto-detected'}'),
            const SizedBox(height: 8),
            const Text('Your submission', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade800)),
                child: SingleChildScrollView(child: Text(userCode, style: const TextStyle(fontFamily: 'monospace'))),
              ),
            ),
            const SizedBox(height: 8),
            const Text('AI suggested solution', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade800)),
              child: SingleChildScrollView(child: Text(aiSolution, style: const TextStyle(fontFamily: 'monospace'))),
            ),
            const SizedBox(height: 8),
            const Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(explanation),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: () => showDialog(context: context, builder: (_) => RatingDialog()), child: const Text('Rate this')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
// -------------------- Profile Page --------------------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 40)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Arpit Gupta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Computer Science Student')
                ]),
              ],
            ),
            const SizedBox(height: 18),
            ListTile(leading: const Icon(Icons.lock), title: const Text('Security Settings'), subtitle: const Text('Two-Factor Auth, Change password'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage()))), 
            ListTile(leading: const Icon(Icons.feedback), title: const Text('Feedback & Reports'), onTap: () => showDialog(context: context, builder: (_) => const FeedbackDialog())), 
            ListTile(leading: const Icon(Icons.delete_forever), title: const Text('Delete Account'), onTap: () => _confirmDelete(context)),
            const Spacer(),
            ElevatedButton(onPressed: () => _logout(context), child: const Text('Logout')),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Delete account?'), content: const Text('This action is irreversible.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deletion placeholder'))); }, child: const Text('Delete', style: TextStyle(color: Colors.red)))]));
  }
}
// -------------------- Dialogs --------------------
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 4.0;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate CodeLearner'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(value: rating, onChanged: (v) => setState(() => rating = v), min: 1, max: 5, divisions: 4, label: rating.toString()),
          TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Feedback (optional)')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanks — rating: $rating'))); }, child: const Text('Submit')),
      ],
    );
  }
}

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});
  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("We'd Love your Feedback!"),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: const InputDecoration(hintText: 'Please share any suggestions or issues to improve CodeLearner'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted'))); }, child: const Text('Submit')),
      ],
    );
  }
}
// -------------------- Security Settings --------------------
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});
  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool twoFA = false;
  final _pwController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SwitchListTile(
            value: twoFA,
            onChanged: (v) => setState(() => twoFA = v),
            title: const Text('Turn on 2FA'),
            subtitle: Text(twoFA ? 'Enabled' : 'Disabled'),
          ),
          const SizedBox(height: 12),
          const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _pwController, obscureText: true, decoration: const InputDecoration(labelText: 'Enter new password')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password change placeholder'))); }, child: const Text('Change Password')),
        ]),
      ),
    );
  }
}
// -------------------- Admin Portal --------------------
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;
  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => loading = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Portal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.asset(
                  'assets/images/logo_small.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.admin_panel_settings, size: 72, color: Colors.tealAccent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Admin email'), validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email', onSaved: (v) => email = v ?? ''),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (v) => v != null && v.length >= 6 ? null : 'Password min 6 chars', onSaved: (v) => password = v ?? ''),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loading ? null : _login, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login')),
          ]),
        ),
      ),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const AdminReportsView(), const AdminFeedbackView(), const AdminMetricsView()];
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Portal')),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Metrics'),
        ],
      ),
    );
  }
}

class AdminReportsView extends StatelessWidget {
  const AdminReportsView({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('• User flagged issue: snippet not compiling in Java\n• Content update requested: Arrays topic outdated\n• Abuse report #21981 handled'),
      ],
    );
  }
}

class AdminFeedbackView extends StatelessWidget {
  const AdminFeedbackView({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'author': 'Ray T',
        'time': '2 hours ago',
        'text': 'This app helped so much with my homework! The examples under Loops were super clear.'
      },
      {
        'author': 'Khang T',
        'time': '8 hours ago',
        'text': 'I improved my code style a lot. Please add more recursion challenges.'
      },
      {
        'author': 'Cian D',
        'time': '1 day ago',
        'text': 'Love the UI. Could we get more I/O parsing examples with error cases?'
      },
      {
        'author': 'Leo C',
        'time': '3 days ago',
        'text': 'Topic Help search is great. A “previous/next” in the guided flow would be sweet.'
      },
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final f = items[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.person, size: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(f['author'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(f['time'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(f['text'] as String),
                        ]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminMetricsView extends StatelessWidget {
  const AdminMetricsView({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(leading: Icon(Icons.person_outline), title: Text('Monthly Active Users'), trailing: Text('79,787')),
        ListTile(leading: Icon(Icons.code), title: Text('Submissions'), trailing: Text('4,796')),
        ListTile(leading: Icon(Icons.school), title: Text('Trending Topic'), trailing: Text('Loops')),
      ],
    );
  }
}

// -------------------- Topic Help (New UI) --------------------
// Edit these labels only to change wording per topic.
const Map<String, Map<String, String>> _topicLabels = {
  'Loops': {
    'description': 'Repeats a block while a condition holds or over a range/collection. Use for when the count is known, while for open‑ended loops, and break/continue to control flow.',
    'try': 'Print numbers 1..10 on separate lines.',
    'exampleCode': r"""#include <iostream>
using namespace std;
int main(){
  for(int i=1;i<=10;i++){
    cout << i << "\n";
  }
  return 0;
}
""",
  },
  'If-Else': {
    'description': 'Chooses a code path based on a boolean condition. Combine comparison (==, >, <, <=, >=, !=) and logical operators (&&, ||, !) to express rules clearly.',
    'try': "Read an integer and print 'even' or 'odd'.",
    'exampleCode': r"""int n = 7;
if (n % 2 == 0) {
  print('even');
} else {
  print('odd');
}
""",
  },
  'Recursion': {
    'description': 'Solves a problem by calling the function on smaller inputs. Always include a base case and move toward it each call to avoid infinite recursion.',
    'try': 'Return the nth Fibonacci number (n ≥ 0).',
    'exampleCode': r"""int fact(int n){
  if(n<=1) return 1;
  return n * fact(n-1);
}
""",
  },
  'I/O': {
    'description': 'Reads input and writes output (stdin/stdout or files). Validate and parse input; handle errors gracefully.',
    'try': 'Read N, then read N numbers and output their sum.',
    'exampleCode': r"""import 'dart:io';
void main(){
  while(true){
    stdout.write('> ');
    final line = stdin.readLineSync();
    if(line == null || line.toLowerCase() == 'quit') break;
    print(line);
  }
}
""",
  },
};

class TopicHelpNewPage extends StatefulWidget {
  const TopicHelpNewPage({super.key});
  @override
  State<TopicHelpNewPage> createState() => _TopicHelpNewPageState();
}

class _TopicHelpNewPageState extends State<TopicHelpNewPage> {
  final TextEditingController _search = TextEditingController();
  final List<String> _allTopics = const ['Loops', 'If-Else', 'Recursion', 'I/O'];

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final items = q.isEmpty ? _allTopics : _allTopics.where((t) => t.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Topic Help')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search for any topic'),
          ),
          const SizedBox(height: 16),
          const Text('Common Topics:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final t = items[i];
                final lbl = _topicLabels[t] ?? const {'description': 'Description', 'example': 'Example Code', 'try': 'Try It'};
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(children: [
                    OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TopicExplanationPage(topic: t))), child: const Text('Explanation')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TopicSnippetPage(topic: t))), child: const Text('Example Code')),
                    const Spacer(),
                    OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitCodePage(initialTopic: t))), child: const Text('Try It')),
                  ])
                ]);
              },
            ),
          )
        ]),
      ),
    );
  }
}

// -------------------- Settings Page (combined with Profile) --------------------
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _edit(String title, String current, ValueChanged<String> onSave,
      {TextInputType? type}) async {
    final c = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(controller: c, keyboardType: type, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { onSave(c.text.trim()); Navigator.pop(context); setState(() {}); }, child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header banner with avatar and Edit link
          Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.teal.shade400, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(radius: 28, child: Icon(Icons.person, size: 30)),
                  SizedBox(height: 4),
                  Text('Edit', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _EditableRow(
            label: 'First',
            value: userProfile.firstName.isEmpty ? '—' : userProfile.firstName,
            onEdit: () => _edit('First Name', userProfile.firstName, (v) => userProfile.update(first: v)),
          ),
          _EditableRow(
            label: 'Last',
            value: userProfile.lastName.isEmpty ? '—' : userProfile.lastName,
            onEdit: () => _edit('Last Name', userProfile.lastName, (v) => userProfile.update(last: v)),
          ),
          _EditableRow(
            label: 'Email',
            value: userProfile.email.isEmpty ? '—' : userProfile.email,
            onEdit: () => _edit('Email', userProfile.email, (v) => userProfile.update(mail: v), type: TextInputType.emailAddress),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage())),
              child: const Text('Security'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;
  const _EditableRow({required this.label, required this.value, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 12),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70))),
          const SizedBox(width: 8),
          TextButton(onPressed: onEdit, child: const Text('Edit')),
        ],
      ),
    );
  }
}

// -------------------- Custom Bottom Bar and Helpers --------------------
class _HomeLogoIcon extends StatelessWidget {
  const _HomeLogoIcon();
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo_small.png', width: 24, height: 24,
        errorBuilder: (_, __, ___) => const Icon(Icons.home));
  }
}

class BottomItem {
  final Widget icon;
  const BottomItem({required this.icon});
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomItem> items;
  const CustomBottomBar({super.key, required this.currentIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE62121);
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        color: red,
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(opacity: currentIndex == i ? 1 : 0.7, child: items[i].icon),
                    ],
                  ),
                ),
              ),
              if (i != items.length - 1)
                Container(width: 1, height: double.infinity, color: Colors.black),
            ]
          ],
        ),
      ),
    );
  }
}

class StarPage extends StatelessWidget {
  const StarPage({super.key});
  @override
  Widget build(BuildContext context) => const _StarPageBody();
}

class _StarPageBody extends StatefulWidget {
  const _StarPageBody();
  @override
  State<_StarPageBody> createState() => _StarPageBodyState();
}

class _StarPageBodyState extends State<_StarPageBody> {
  int rating = 4;
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                iconSize: 36,
                onPressed: () => setState(() => rating = i + 1),
                icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber),
              )),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Any additional feedback?'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanks — rating: $rating')));
                },
                child: const Text('Submit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
