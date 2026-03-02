import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class UploadArticlePage extends StatefulWidget {
  const UploadArticlePage({Key? key}) : super(key: key);

  @override
  State<UploadArticlePage> createState() => _UploadArticlePageState();
}

class _UploadArticlePageState extends State<UploadArticlePage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UploadArticleCubit>(
      create: (context) => sl<UploadArticleCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Create Article',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: BlocConsumer<UploadArticleCubit, UploadArticleState>(
          listener: (context, state) {
            if (state is UploadArticleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article created successfully!')),
              );
              Navigator.of(context).pop();
            } else if (state is UploadArticleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error ?? 'Unknown error')),
              );
            }
          },
          builder: (context, state) {
            if (state is UploadArticleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildForm(context);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Author Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: _selectedImagePath != null
                  ? Image.file(File(_selectedImagePath!), fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                        Text('Tap to select image'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty && 
                  _contentController.text.isNotEmpty && 
                  _selectedImagePath != null) {
                 context.read<UploadArticleCubit>().uploadArticle(
                  author: _authorController.text,
                  title: _titleController.text,
                  content: _contentController.text,
                  urlToImage: _selectedImagePath!,
                );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields including image')),
                );
              }
            },
            child: const Text('Publish Article'),
          ),
        ],
      ),
    );
  }
}
