import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'Models/NotesPage.dart';
import 'NotesPage.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _formKey = GlobalKey<FormState>();
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    notesDescriptionMaxLenth = notesDescriptionMaxLines * notesDescriptionMaxLines;
  }

  @override
  void dispose() {
    noteDescriptionController.dispose();
    noteHeadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: notesHeader(),
      ),
      body: noteHeading.isNotEmpty
          ? buildNotes()
          : const Center(child: Text("Add Notes...")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          editingIndex = null;
          noteHeadingController.clear();
          noteDescriptionController.clear();
          _settingModalBottomSheet(context);
        },
        child: const Icon(Icons.create),
      ),
    );
  }

  Widget buildNotes() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: noteHeading.length,
        itemBuilder: (context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                setState(() {
                  deletedNoteHeading = noteHeading[index];
                  deletedNoteDescription = noteDescription[index];
                  noteHeading.removeAt(index);
                  noteDescription.removeAt(index);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.purple,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Note Deleted"),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                noteHeading.add(deletedNoteHeading);
                                noteDescription.add(deletedNoteDescription);
                                deletedNoteHeading = "";
                                deletedNoteDescription = "";
                              });
                            },
                            child: const Text("Undo", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5.5),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5.5),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 10),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    editingIndex = index;
                    noteHeadingController.text = noteHeading[index];
                    noteDescriptionController.text = noteDescription[index];
                    _settingModalBottomSheet(context, editing: true);
                  });
                },
                child: noteList(index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget noteList(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.5),
      child: Container(
        decoration: BoxDecoration(
          color: noteColor[index % noteColor.length],
          borderRadius: BorderRadius.circular(5.5),
        ),
        height: 100,
        child: Row(
          children: [
            Container(
              color: noteMarginColor[index % noteMarginColor.length],
              width: 4,
              height: double.infinity,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      noteHeading[index],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AutoSizeText(
                      noteDescription[index],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _settingModalBottomSheet(BuildContext context, {bool editing = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editing ? "Edit Note" : "New Note",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            if (editing && editingIndex != null) {
                              noteHeading[editingIndex!] = noteHeadingController.text;
                              noteDescription[editingIndex!] = noteDescriptionController.text;
                            } else {
                              noteHeading.add(noteHeadingController.text);
                              noteDescription.add(noteDescriptionController.text);
                            }
                            noteHeadingController.clear();
                            noteDescriptionController.clear();
                            editingIndex = null;
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
                const Divider(thickness: 2.5, color: Colors.blueAccent),
                TextFormField(
                  maxLength: notesHeaderMaxLenth,
                  controller: noteHeadingController,
                  decoration: const InputDecoration(
                    hintText: "Note Heading",
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a note heading";
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(textSecondFocusNode);
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  focusNode: textSecondFocusNode,
                  maxLines: notesDescriptionMaxLines,
                  maxLength: notesDescriptionMaxLenth,
                  controller: noteDescriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Note Description',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter note description";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget notesHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "My Notes",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        Divider(thickness: 2.5, color: Colors.blueAccent),
      ],
    );
  }
}