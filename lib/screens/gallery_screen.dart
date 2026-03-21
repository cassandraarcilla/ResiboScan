import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../src/html_stub.dart'
    if (dart.library.html) 'dart:html' as html;

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
const _cerulean    = Color(0xFF2D728F);
const _cyan        = Color(0xFF3B8EA5);
const _sandy       = Color(0xFFF49E4C);
const _cream       = Color(0xFFFDF8EC);
const _white       = Color(0xFFFFFFFF);
const _ink         = Color(0xFF0F2027);
const _inkMid      = Color(0xFF2C4A55);
const _inkLight    = Color(0xFF7A9BAA);

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selectedTab = 0; // 0 = Recent, 1 = Albums
  int? _selectedIndex;
  
  List<Uint8List> _pickedBytes = [];
  List<AssetEntity> _assets = [];
  List<AssetPathEntity> _albums = [];
  
  bool _loading = true;
  bool _permissionDenied = false;

  bool get _isDesktop => 
      !kIsWeb && 
      (defaultTargetPlatform == TargetPlatform.windows || 
       defaultTargetPlatform == TargetPlatform.macOS || 
       defaultTargetPlatform == TargetPlatform.linux);

  bool get _useCustomPicker => kIsWeb || _isDesktop;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = true;
      input.click();
      
      try {
        await input.onChange.first;
      } catch (_) {}
      
      if (input.files == null || input.files!.isEmpty) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      final List<Uint8List> loaded = [];
      for (final file in input.files!) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoad.first;
        final dataUrl = reader.result as String;
        final base64String = dataUrl.split(',').last;
        loaded.add(base64Decode(base64String));
      }

      if (mounted) {
        setState(() {
          _pickedBytes = loaded;
          _loading = false;
        });
      }
    } else if (_isDesktop) {
      try {
        final picker = ImagePicker();
        final pickedFiles = await picker.pickMultiImage();
        
        if (pickedFiles.isEmpty) {
          if (mounted) Navigator.pop(context, null);
          return;
        }

        final List<Uint8List> loaded = [];
        for (final file in pickedFiles) {
          loaded.add(await file.readAsBytes());
        }

        if (mounted) {
          setState(() {
            _pickedBytes = loaded;
            _loading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } else {
      final result = await PhotoManager.requestPermissionExtend();
      if (!mounted) return;

      if (!result.isAuth) {
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
        return;
      }

      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
          orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
        ),
      );

      if (paths.isNotEmpty) {
        final recent = paths.first;
        final count = await recent.assetCountAsync;
        _assets = await recent.getAssetListRange(start: 0, end: count > 300 ? 300 : count);
        
        // Also load all albums for the albums tab
        _albums = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          hasAll: true,
        );
      }

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedIndex == null) return;
    
    if (_useCustomPicker) {
      Navigator.pop(context, _pickedBytes[_selectedIndex!]);
    } else {
      setState(() => _loading = true);
      try {
        final bytes = await _assets[_selectedIndex!].originBytes;
        if (mounted) {
          Navigator.pop(context, bytes);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink.withOpacity(0.4), // The area above the card
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Extra spacing at top to push bottom sheet down slightly
            const SizedBox(height: 20),
            
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // ── Card Top Header ──
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Cerulean square icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _cerulean,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.photo, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              
                              // Tabs
                              _tab('Recent', 0),
                              const SizedBox(width: 12),
                              _tab('Albums', 1),
                            ],
                          ),
                        ),
                        
                        // Close button top-right
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 18, color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // ── Content ──
                    Expanded(
                      child: _permissionDenied
                          ? _buildPermissionDenied()
                          : _loading
                              ? const Center(child: CircularProgressIndicator(color: _cerulean))
                              : _selectedTab == 0
                                  ? _buildGrid()
                                  : _buildAlbums(),
                    ),
                  ],
                ),
              ),
            ),
            
            // ── Bottom Confirm Bar ──
            if (_selectedIndex != null && !_loading)
              Container(
                color: _cream,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cerulean,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Use Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedTab = index;
        _selectedIndex = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _cerulean : _cream,
          borderRadius: BorderRadius.circular(24),
          border: selected ? null : Border.all(color: _cerulean, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _white : _cerulean,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final count = _useCustomPicker ? _pickedBytes.length : _assets.length;
    
    if (count == 0) {
      return Center(
        child: Text('No photos found',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        // MUST BE EXACTLY ZERO SPACING PURSUANT TO MOCKUP
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        final isSelected = _selectedIndex == i;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = isSelected ? null : i;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              if (_useCustomPicker)
                Image.memory(
                  _pickedBytes[i],
                  fit: BoxFit.cover,
                )
              else
                AssetEntityImage(
                  _assets[i],
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(300),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                
              // Overlay
              if (isSelected)
                Container(
                  color: _cerulean.withOpacity(0.4),
                ),
              if (isSelected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle, color: _sandy, size: 28),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlbums() {
    if (_useCustomPicker) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Showing uploaded photos',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(child: _buildGrid()),
        ],
      );
    }
    
    if (_albums.isEmpty) {
      return Center(
        child: Text('No albums found',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _albums.length,
      itemBuilder: (context, i) {
        final album = _albums[i];
        
        return FutureBuilder<List<AssetEntity>>(
          future: album.getAssetListRange(start: 0, end: 1),
          builder: (context, snapshot) {
            final asset = snapshot.data?.firstOrNull;
            
            return GestureDetector(
              onTap: () async {
                setState(() => _loading = true);
                final count = await album.assetCountAsync;
                final assets = await album.getAssetListRange(start: 0, end: count > 300 ? 300 : count);
                if (mounted) {
                  setState(() {
                    _assets = assets;
                    _selectedTab = 0;
                    _selectedIndex = null;
                    _loading = false;
                  });
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: double.infinity,
                      child: asset == null 
                          ? const Center(child: Icon(Icons.photo_album, color: Colors.grey))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AssetEntityImage(
                                asset,
                                isOriginal: false,
                                thumbnailSize: const ThumbnailSize.square(300),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    album.name.isEmpty ? 'Untitled' : album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  FutureBuilder<int>(
                    future: album.assetCountAsync,
                    builder: (context, countSnap) {
                      return Text(
                        '${countSnap.data ?? 0}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 18),
          const Text('Photo access denied',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: PhotoManager.openSetting,
            style: ElevatedButton.styleFrom(backgroundColor: _cerulean),
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
