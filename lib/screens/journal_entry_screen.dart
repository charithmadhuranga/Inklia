import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../config/templates.dart';
import '../theme/app_theme.dart';

class JournalEntryScreen extends StatefulWidget {
  final DateTime selectedDate;
  final JournalEntry? existingEntry;

  const JournalEntryScreen({
    super.key,
    required this.selectedDate,
    this.existingEntry,
  });

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _tagController = TextEditingController();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _imagePaths = [];
  List<String> _voiceMemoPaths = [];
  Mood? _selectedMood;
  List<String> _tags = [];
  bool _isFavorite = false;
  String? _selectedTemplate;
  bool _isRecording = false;
  String? _playingVoiceMemo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingEntry?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingEntry?.content ?? '',
    );
    _imagePaths = List.from(widget.existingEntry?.imagePaths ?? []);
    _voiceMemoPaths = List.from(widget.existingEntry?.voiceMemoPaths ?? []);
    _selectedMood = widget.existingEntry?.mood;
    _tags = List.from(widget.existingEntry?.tags ?? []);
    _isFavorite = widget.existingEntry?.isFavorite ?? false;
    _selectedTemplate = widget.existingEntry?.templateType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      final savedPath = await _saveFile(image.path);
      setState(() {
        _imagePaths.add(savedPath);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (photo != null) {
      final savedPath = await _saveFile(photo.path);
      setState(() {
        _imagePaths.add(savedPath);
      });
    }
  }

  Future<String> _saveFile(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}${path.extension(filePath)}';
    final savedPath = path.join(appDir.path, fileName);
    await File(filePath).copy(savedPath);
    return savedPath;
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.m4a';
      final voicePath = path.join(appDir.path, fileName);

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: voicePath,
      );

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final voicePath = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });

    if (voicePath != null) {
      setState(() {
        _voiceMemoPaths.add(voicePath);
      });
    }
  }

  Future<void> _playVoiceMemo(String voicePath) async {
    if (_playingVoiceMemo == voicePath) {
      await _audioPlayer.stop();
      setState(() {
        _playingVoiceMemo = null;
      });
    } else {
      await _audioPlayer.play(DeviceFileSource(voicePath));
      setState(() {
        _playingVoiceMemo = voicePath;
      });
    }
  }

  void _removeVoiceMemo(int index) {
    setState(() {
      _voiceMemoPaths.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _selectTemplate(JournalTemplate template) {
    setState(() {
      _selectedTemplate = template.id;
      if (_titleController.text.isEmpty) {
        _titleController.text = template.defaultTitle;
      }
      if (_contentController.text.isEmpty) {
        _contentController.text = template.defaultContent;
      }
    });
  }

  Future<void> _saveEntry() async {
    final entry = JournalEntry(
      id: widget.existingEntry?.id ?? const Uuid().v4(),
      date: widget.selectedDate,
      title: _titleController.text,
      content: _contentController.text,
      imagePaths: _imagePaths,
      voiceMemoPaths: _voiceMemoPaths,
      mood: _selectedMood,
      tags: _tags,
      isFavorite: _isFavorite,
      templateType: _selectedTemplate,
      createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
    );

    if (widget.existingEntry != null) {
      await _databaseService.updateEntry(entry);
    } else {
      await _databaseService.insertEntry(entry);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showTemplatesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            'Choose a Template',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: JournalTemplate.templates.length,
                        itemBuilder: (context, index) {
                          final template = JournalTemplate.templates[index];
                          final isSelected = _selectedTemplate == template.id;
                          return ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor.withOpacity(0.2)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  template.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            title: Text(
                              template.name,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(template.description),
                            trailing:
                                isSelected
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryColor,
                                    )
                                    : null,
                            onTap: () {
                              _selectTemplate(template);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(dateFormat.format(widget.selectedDate)),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? Colors.amber : null,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              IconButton(icon: const Icon(Icons.save), onPressed: _saveEntry),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMoodSelector(),
                  const SizedBox(height: 16),
                  _buildTemplateSelector(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 24),
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildMediaSection(),
                  if (_imagePaths.isNotEmpty) _buildImageGallery(),
                  if (_voiceMemoPaths.isNotEmpty) _buildVoiceMemos(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    Mood.values.map((mood) {
                      final isSelected = _selectedMood == mood;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = isSelected ? null : mood;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                isSelected
                                    ? Border.all(
                                      color: AppTheme.primaryColor,
                                      width: 2,
                                    )
                                    : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.textSecondary,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Template',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                if (_selectedTemplate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTemplate = null;
                        _titleController.clear();
                        _contentController.clear();
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showTemplatesSheet,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedTemplate != null
                          ? JournalTemplate.getById(_selectedTemplate!)?.icon ??
                              '📝'
                          : '📝',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedTemplate != null
                            ? JournalTemplate.getById(
                                  _selectedTemplate!,
                                )?.name ??
                                'Select Template'
                            : 'Tap to choose a template',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              _selectedTemplate != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag...',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add_circle),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _tags.map((tag) {
                      return Chip(
                        label: Text(
                          '#$tag',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppTheme.textPrimary,
                        ),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: AppTheme.accentColor.withOpacity(0.3),
                        side: BorderSide(
                          color: AppTheme.accentColor.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.attachment,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Media & Attachments',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MediaButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: _pickImage,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MediaButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: _takePhoto,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MediaButton(
                    icon: _isRecording ? Icons.stop : Icons.mic,
                    label: _isRecording ? 'Stop' : 'Record',
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    color: _isRecording ? Colors.red : Colors.orange,
                    isRecording: _isRecording,
                  ),
                ),
              ],
            ),
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text('Recording...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_imagePaths.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Photos (${_imagePaths.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imagePaths[index]),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
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

  Widget _buildVoiceMemos() {
    if (_voiceMemoPaths.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mic, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Voice Memos (${_voiceMemoPaths.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _voiceMemoPaths.length,
            itemBuilder: (context, index) {
              final isPlaying = _playingVoiceMemo == _voiceMemoPaths[index];
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isPlaying
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.stop : Icons.play_arrow,
                      color: isPlaying ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                  title: Text('Voice Memo ${index + 1}'),
                  subtitle: Text(
                    isPlaying ? 'Playing...' : 'Tap to play',
                    style: TextStyle(
                      color:
                          isPlaying
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeVoiceMemo(index),
                  ),
                  onTap: () => _playVoiceMemo(_voiceMemoPaths[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isRecording;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isRecording ? color.withOpacity(0.2) : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
