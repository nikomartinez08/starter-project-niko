import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/article_input.dart';
import '../bloc/upload_article_bloc.dart';
import '../bloc/upload_article_event.dart';
import '../bloc/upload_article_state.dart';

class UploadArticlePage extends StatefulWidget {
  const UploadArticlePage({super.key});

  @override
  State<UploadArticlePage> createState() => _UploadArticlePageState();
}

class _UploadArticlePageState extends State<UploadArticlePage> {
  final _authorController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _submit(BuildContext context) {
    if (_authorController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    final articleInput = ArticleInput(
      author: _authorController.text,
      title: _titleController.text,
      description: _descriptionController.text,
      content: _contentController.text,
      imagePath: _imagePath,
    );

    context.read<UploadArticleBloc>().add(UploadArticleRequested(articleInput));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UploadArticleBloc>(
      create: (context) => sl<UploadArticleBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Article'),
        ),
        body: BlocConsumer<UploadArticleBloc, UploadArticleState>(
          listener: (context, state) {
            if (state is UploadArticleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article uploaded successfully!')),
              );
              Navigator.pop(context);
            } else if (state is UploadArticleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            }
          },
          builder: (context, state) {
            if (state is UploadArticleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imagePath == null
                          ? const Center(
                              child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Author'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Publish Article'),
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
