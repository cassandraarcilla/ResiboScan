import 'dart:typed_data';
import 'package:flutter/material.dart';

// ── App palette ──────────────────────────────────────────────────────────────
// Eto yung mga kulay na gagamitin natin para magmukhang vintage at malinis yung gallery.
const _cerulean  = Color(0xFF2D728F);
const _cream     = Color(0xFFFDF8EC);
const _ink       = Color(0xFF0F2027);
const _inkMid    = Color(0xFF2C4A55);
const _inkLight  = Color(0xFF7A9BAA);

const _green     = Color(0xFF4CAF50); // Primary accent color para sa gallery actions.

// Model class para sa mga images na galing sa web/PC.
// Kasi sa web, bytes (Uint8List) ang gamit natin imbes na file paths.
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
  int _tabIndex = 0; // 0 = Recent, 1 = Albums (Navigation state natin 'to).
  WebImageFile? _selected; // Dito natin ise-save kung anong image ang pinindot ni user.

  // Kapag pinindot yung 'Done', ibabalik natin yung bytes ng napiling picture sa previous screen.
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
            // Header part na may back button at tab switcher.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  // Back button (Yung green circle icon na nasa design mockup).
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Para makabalik kung ayaw na mag-select.
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
                  
                  // Tabs para sa 'Recent' at 'Albums'.
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
            // Dito lalabas yung mga pictures. Kung wala pang laman, pakita muna yung empty state.
            Expanded(
              child: widget.files.isEmpty
                  ? _buildEmptyState()
                  : _tabIndex == 0
                      ? _buildGrid()
                      : _buildAlbumsMock(),
            ),

            // ── Bottom confirm bar (appears when selected) ──────
            // Lalabas lang 'tong 'Done' button kapag may na-select nang picture.
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
                    // Display ng file name ng napiling picture.
                    Expanded(
                      child: Text(
                        _selected!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Done Button para i-finalize yung selection.
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

  // Helper widget para sa pag-switch ng tabs.
  Widget _buildTab(String label, int index) {
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer( // Nilagyan natin ng konting transition para smooth yung selection.
        duration: const Duration(milliseconds: 200),
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

  // Eto yung screen na makikita pag walang files na na-upload si user.
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

  // Mock layout lang muna para sa Albums tab, same grid pa rin ang gamit.
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

  // Main grid builder para sa mga images.
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
              // Toggle logic: Pag kinlik ulit yung selected, made-deselect siya.
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
              // Checkmark icon para clear na selected yung picture.
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
