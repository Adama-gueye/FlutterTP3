import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Note {
  final int id;
  String subject;
  final String contenu;

  Note({
    required this.id,
    required this.subject,
    required this.contenu,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      subject: json['subject'],
      contenu: json['contenu'],
    );
  }
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      home: NotesForm(),
    );
  }
}

class NotesForm extends StatefulWidget {
  @override
  _NotesFormState createState() => _NotesFormState();
}

class _NotesFormState extends State<NotesForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  String? _selectedSubject;
  List<Note> notes = [];

  Future<void> saveNote() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/notes/save');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subject': _selectedSubject,
        'contenu': _contentController.text,
      }),
    );

    if (response.statusCode == 200) {
      // La note a été enregistrée avec succès, on redirige l'utilisateur vers la liste des notes
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NoteList(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add note')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AJout d\'un Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                items: [
                  DropdownMenuItem(child: Text('Java'), value: 'Java'),
                  DropdownMenuItem(child: Text('PHP'), value: 'PHP'),
                  DropdownMenuItem(child: Text('Algo'), value: 'Algo'),
                ],
                hint: Text('Selectionner un sujet'),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'SVP Veuillez selectionner un sujet';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Entrer une note (comprise entre 0 et 20)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'SVP Veuillez entre une note';
                  }
                  final note = int.tryParse(value);
                  if (note == null || note < 0 || note > 20) {
                    return 'SVP entrez une note comprise entre 0 et 20';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await saveNote();
                  }
                },
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  List<Note> _notes = [];

  Future<void> _fetchNotes() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/api/notes/liste'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        List<Note> notes = [];
        jsonList.forEach((jsonNote) {
          Note note = Note.fromJson(jsonNote);
          notes.add(note);
        });
        setState(() {
          _notes = notes;
        });
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des notes'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return Container(
      margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.subject),
              const SizedBox(height: 10.0),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.contenu),
              const SizedBox(height: 10.0),

            ],
          ),
       
 
        ],
      ),
    );
          },
        ),
      ),
    );
  }
}








void main() {
  runApp(NotesApp());
}
