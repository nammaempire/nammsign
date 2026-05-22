import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signage_app/core/constants/app_colors.dart';
import 'package:signage_app/models/ad_slot_model.dart';
import 'package:video_player/video_player.dart';

class SignagePreviewWidget extends StatefulWidget {
  final File? mediaFile;
  final String mediaType; // 'image' | 'video'
  final AdSlot slot;

  const SignagePreviewWidget({
    super.key,
    required this.mediaFile,
    required this.mediaType,
    required this.slot,
  });

  @override
  State<SignagePreviewWidget> createState() => _SignagePreviewWidgetState();
}

class _SignagePreviewWidgetState extends State<SignagePreviewWidget> {
  VideoPlayerController? _videoCtrl;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video' && widget.mediaFile != null) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.file(widget.mediaFile!);
    await _videoCtrl!.initialize();
    await _videoCtrl!.setLooping(true);
    await _videoCtrl!.play();
    if (mounted) setState(() => _videoInitialized = true);
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Preview on Signage Board',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),
          ),

          // ── Signage Board Mockup ───────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.signageBoardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.signageBoardBezel,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top bar – control strip
                Container(
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.signageBoardBezel,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      // Live LED
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.signageBoardLed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE PREVIEW',
                        style: TextStyle(
                          color: AppColors.signageBoardLed,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.slot.name,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),

                // ── Screen Area ────────────────────────────────────────
                AspectRatio(
                  aspectRatio: _getAspectRatio(),
                  child: ClipRRect(
                    child: _buildMediaContent(),
                  ),
                ),

                // Bottom info strip
                Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.signageBoardBezel,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.slot.location} · ${widget.slot.city}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.people_rounded,
                        size: 12,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.slot.footTrafficLabel,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Video Controls ─────────────────────────────────────────────
          if (widget.mediaType == 'video' && _videoInitialized)
            _VideoControls(controller: _videoCtrl!),
        ],
      );

  double _getAspectRatio() {
    final w = widget.slot.screenWidth.toDouble();
    final h = widget.slot.screenHeight.toDouble();
    return (w / h).clamp(0.5, 2.5);
  }

  Widget _buildMediaContent() {
    if (widget.mediaFile == null) {
      return _EmptyPreview();
    }
    if (widget.mediaType == 'image') {
      return Image.file(
        widget.mediaFile!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    if (widget.mediaType == 'video' &&
        _videoInitialized &&
        _videoCtrl != null) {
      return VideoPlayer(_videoCtrl!);
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryPurple),
    );
  }
}

// ── Empty Preview Placeholder ─────────────────────────────────────────────────
class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF0A0515),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'Your ad will appear here',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
}

// ── Video Controls ────────────────────────────────────────────────────────────
class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoControls({required this.controller});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            // Play/Pause
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                  _isPlaying
                      ? widget.controller.play()
                      : widget.controller.pause();
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Progress
            Expanded(
              child: VideoProgressIndicator(
                widget.controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primaryPurple,
                  bufferedColor: AppColors.darkDivider,
                  backgroundColor: AppColors.darkCard,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Duration
            ValueListenableBuilder(
              valueListenable: widget.controller,
              builder: (_, VideoPlayerValue value, __) {
                final position = value.position;
                final duration = value.duration;
                return Text(
                  '${_fmt(position)} / ${_fmt(duration)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkTextSecondary,
                  ),
                );
              },
            ),
          ],
        ),
      );

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
