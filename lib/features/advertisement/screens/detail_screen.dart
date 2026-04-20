import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/ad_slot_model.dart';
import '../../../providers/advertisement_provider.dart';
import '../widgets/signage_preview.dart';
import 'payment_screen.dart';

class DetailScreen extends StatefulWidget {
  final AdSlot slot;
  const DetailScreen({super.key, required this.slot});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final ImagePicker   _picker = ImagePicker();

  File?   _mediaFile;
  String  _mediaType   = 'image'; // 'image' | 'video'
  int     _durationDays = 7;
  bool    _showPreview  = false;

  final List<int> _durationOptions = [1, 3, 7, 14, 30];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  double get _totalPrice => widget.slot.pricePerDay * _durationDays;

  // ── Media Picker ──────────────────────────────────────────────────────────
  Future<void> _pickMedia(String type) async {
    try {
      XFile? file;
      if (type == 'image') {
        file = await _picker.pickImage(
          source:     ImageSource.gallery,
          imageQuality: 85,
        );
      } else {
        file = await _picker.pickVideo(source: ImageSource.gallery);
      }
      if (file != null) {
        setState(() {
          _mediaFile  = File(file!.path);
          _mediaType  = type;
          _showPreview = false; // reset preview
        });
      }
    } catch (e) {
      _showSnack('Failed to pick media. Check permissions.');
    }
  }

  void _togglePreview() {
    if (_mediaFile == null) {
      _showSnack('Please upload an image or video first');
      return;
    }
    setState(() => _showPreview = !_showPreview);
  }

  // ── Proceed to Payment ────────────────────────────────────────────────────
  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mediaFile == null) {
      _showSnack('Please upload your advertisement media');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          slot:         widget.slot,
          title:        _titleCtrl.text.trim(),
          description:  _descCtrl.text.trim(),
          mediaFile:    _mediaFile!,
          mediaType:    _mediaType,
          durationDays: _durationDays,
          totalAmount:  _totalPrice,
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:   const Text(AppStrings.createAd),
        leading: IconButton(
          icon:     const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Slot Info Card ────────────────────────────────
                    _SlotInfoCard(slot: widget.slot, isDark: isDark),
                    const SizedBox(height: 24),

                    // ── Ad Title ──────────────────────────────────────
                    const _SectionLabel(label: 'Ad Details'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText:  AppStrings.adTitle,
                        hintText:   'e.g. Summer Sale – 50% Off',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Ad title is required'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines:   3,
                      decoration: const InputDecoration(
                        labelText: AppStrings.adDescription,
                        hintText:  'Short description of your advertisement...',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Description is required'
                              : null,
                    ),
                    const SizedBox(height: 24),

                    // ── Duration Selector ─────────────────────────────
                    const _SectionLabel(label: AppStrings.adDuration),
                    const SizedBox(height: 12),
                    _DurationSelector(
                      selected:  _durationDays,
                      options:   _durationOptions,
                      onSelect:  (d) => setState(() => _durationDays = d),
                      isDark:    isDark,
                    ),
                    const SizedBox(height: 8),
                    _PriceSummary(
                      days:   _durationDays,
                      price:  widget.slot.pricePerDay,
                      total:  _totalPrice,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    // ── Media Upload ──────────────────────────────────
                    const _SectionLabel(label: AppStrings.uploadMedia),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MediaPickerButton(
                            icon:      Icons.image_rounded,
                            label:     AppStrings.uploadImage,
                            selected:  _mediaFile != null && _mediaType == 'image',
                            onTap:     () => _pickMedia('image'),
                            isDark:    isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MediaPickerButton(
                            icon:    Icons.videocam_rounded,
                            label:   AppStrings.uploadVideo,
                            selected: _mediaFile != null && _mediaType == 'video',
                            onTap:   () => _pickMedia('video'),
                            isDark:  isDark,
                          ),
                        ),
                      ],
                    ),

                    // ── Media Thumbnail Preview ────────────────────────
                    if (_mediaFile != null) ...[
                      const SizedBox(height: 16),
                      _MediaThumbnail(
                        file:      _mediaFile!,
                        mediaType: _mediaType,
                        isDark:    isDark,
                        onRemove:  () => setState(() {
                          _mediaFile   = null;
                          _showPreview = false;
                        }),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // ── Signage Preview Toggle ─────────────────────────
                    OutlinedButton.icon(
                      onPressed: _togglePreview,
                      icon:  Icon(
                        _showPreview ? Icons.visibility_off : Icons.visibility,
                      ),
                      label: Text(
                        _showPreview
                            ? 'Hide Preview'
                            : AppStrings.previewSignage,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    // ── Signage Preview Widget ─────────────────────────
                    if (_showPreview) ...[
                      const SizedBox(height: 20),
                      SignagePreviewWidget(
                        mediaFile: _mediaFile,
                        mediaType: _mediaType,
                        slot:      widget.slot,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Proceed CTA ───────────────────────────────────
                    Consumer<AdvertisementProvider>(
                      builder: (_, provider, __) => ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : _proceedToPayment,
                        style:     ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                        icon:      const SizedBox.shrink(),
                        label: Ink(
                          decoration: BoxDecoration(
                            gradient:     AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            height:    54,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.payment_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${AppStrings.proceedPayment} · ₹${_totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color:      Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize:   15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryPurple,
          ),
    );
  }
}

class _SlotInfoCard extends StatelessWidget {
  final AdSlot slot;
  final bool   isDark;
  const _SlotInfoCard({required this.slot, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:     const EdgeInsets.all(16),
      decoration:  BoxDecoration(
        gradient:     const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width:  52,
            height: 52,
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tv_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.name,
                  style: const TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize:   16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot.location} · ${slot.city}',
                  style: const TextStyle(
                    color:    Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  slot.priceLabel,
                  style: const TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize:   14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int          selected;
  final List<int>    options;
  final Function(int) onSelect;
  final bool         isDark;

  const _DurationSelector({
    required this.selected,
    required this.options,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((d) {
        final isSelected = d == selected;
        return GestureDetector(
          onTap: () => onSelect(d),
          child: AnimatedContainer(
            duration:    const Duration(milliseconds: 200),
            padding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration:  BoxDecoration(
              color:        isSelected
                  ? AppColors.primaryPurple
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(10),
              border:       Border.all(
                color: isSelected
                    ? AppColors.primaryPurple
                    : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),
            ),
            child: Text(
              '$d ${d == 1 ? 'Day' : 'Days'}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize:   13,
                color:      isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final int    days;
  final double price;
  final double total;
  final bool   isDark;

  const _PriceSummary({
    required this.days,
    required this.price,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:     const EdgeInsets.only(top: 12),
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        isDark
            ? AppColors.primaryPurple.withOpacity(0.1)
            : AppColors.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate_outlined, color: AppColors.primaryPurple, size: 18),
          const SizedBox(width: 8),
          Text(
            '₹${price.toStringAsFixed(0)} × $days days',
            style: const TextStyle(color: AppColors.primaryPurple, fontSize: 13),
          ),
          const Spacer(),
          Text(
            'Total: ₹${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color:      AppColors.primaryPurple,
              fontWeight: FontWeight.w800,
              fontSize:   15,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPickerButton extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final bool       selected;
  final VoidCallback onTap;
  final bool       isDark;

  const _MediaPickerButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height:   100,
        decoration: BoxDecoration(
          color:        selected
              ? AppColors.primaryPurple.withOpacity(0.12)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(
            color: selected
                ? AppColors.primaryPurple
                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size:  28,
              color: selected
                  ? AppColors.primaryPurple
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      selected
                    ? AppColors.primaryPurple
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final File         file;
  final String       mediaType;
  final bool         isDark;
  final VoidCallback onRemove;

  const _MediaThumbnail({
    required this.file,
    required this.mediaType,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: mediaType == 'image'
              ? Image.file(
                  file,
                  height:  160,
                  width:   double.infinity,
                  fit:     BoxFit.cover,
                )
              : Container(
                  height:  160,
                  width:   double.infinity,
                  color:   isDark ? AppColors.darkCard : AppColors.lightCard,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        size:  48,
                        color: AppColors.primaryPurple,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Video uploaded',
                        style: TextStyle(color: AppColors.primaryPurple),
                      ),
                    ],
                  ),
                ),
        ),
        Positioned(
          top:   8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding:    const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
