import 'dart:typed_data';
import 'package:flutter/material.dart';

// ── App palette ──────────────────────────────────────────────────────────────
const _cerulean  = Color(0xFF2D728F);
const _cream     = Color(0xFFFDF8EC);
const _ink       = Color(0xFF0F2027);
const _inkMid    = Color(0xFF2C4A55);
const _inkLight  = Color(0xFF7A9BAA);

const _green     = Color(0xFF4CAF50);

class WebImageFile {
  final String name;
  final Uint8List bytes;
  WebImageFile({required this.name, required this.bytes});
}

class WebGalleryScreen extends StatefulWidget {
  final List<WebImageFile> files;
  const WebGalleryScreen({super.key, required this.files});

  @override
  State<WebGalleryScreen> createState() => _WebGalleryScreenState();
}

class _WebGalleryScreenState extends State<WebGalleryScreen> {
  int _tabIndex = 0; // 0 = Recent, 1 = Albums
  WebImageFile? _selected;

  void _confirmSelection() {
    if (_selected != null) {
      Navigator.pop(context, _selected!.bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar matching the mockup ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  // Back button (modeled after the green photo icon in mockup)
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Let users cancel
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Tabs
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(child: _buildTab('Recent', 0)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildTab('Albums', 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Grid Content ────────────────────────────────────
            Expanded(
              child: widget.files.isEmpty
                  ? _buildEmptyState()
                  : _tabIndex == 0
                      ? _buildGrid()
                      : _buildAlbumsMock(),
            ),

            // ── Bottom confirm bar (appears when selected) ──────
            if (_selected != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10, offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selected!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _confirmSelection,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text('Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _green : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? null : Border.all(color: _green, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : _green,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No photos selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _inkMid,
            ),
          ),
          const SizedBox(height: 8),
          Text('Go back and select photos from your PC',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsMock() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('Showing selected photos',
            style: TextStyle(color: _inkLight, fontSize: 13),
          ),
        ),
        Expanded(child: _buildGrid()),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.files.length,
      itemBuilder: (context, index) {
        final file = widget.files[index];
        final isSelected = _selected == file;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selected = isSelected ? null : file;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    file.bytes,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _green, width: 3),
                  ),
                ),
              if (isSelected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle, color: Colors.white, size: 24),
                ),
            ],
          ),
        );
      },
    );
  }
}
