import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';

import '../data/cases_service.dart';
import '../data/documents_service.dart';
import '../../../core/i18n/app_localizations.dart';

class CaseTrackerTab extends HookConsumerWidget {
  const CaseTrackerTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedTab = useState(0);
    final casesAsync = ref.watch(userCasesProvider);
    final documentsAsync = ref.watch(userDocumentsProvider);
    
    return Column(
      children: [
        // Header with tabs
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.caseTrackerTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => selectedTab.value == 0
                        ? _showAddCaseDialog(context, ref)
                        : _showAddDocumentDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(selectedTab.value == 0 ? l10n.addCase : l10n.addDocument),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173d4),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tab selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1a2633),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: l10n.cases,
                        isSelected: selectedTab.value == 0,
                        onTap: () => selectedTab.value = 0,
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: l10n.documents,
                        isSelected: selectedTab.value == 1,
                        onTap: () => selectedTab.value = 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: selectedTab.value == 0
              ? casesAsync.when(
                  data: (cases) => _buildCasesTab(context, cases),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Hata: $err', style: const TextStyle(color: Colors.white)),
                  ),
                )
              : documentsAsync.when(
                  data: (documents) => _buildDocumentsTab(context, documents),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Hata: $err', style: const TextStyle(color: Colors.white)),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCasesTab(BuildContext context, List<CaseModel> cases) {
    if (cases.isEmpty) {
      return const Center(
        child: Text(
          'Henüz dava eklenmemiş',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(),
          const SizedBox(height: 18),
          _buildActiveCases(context),
          const SizedBox(height: 18),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context, List<DocumentModel> documents) {
    if (documents.isEmpty) {
      return const Center(
        child: Text(
          'Henüz belge eklenmemiş',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1300
            ? 3
            : constraints.maxWidth > 800
            ? 2
            : 1;
        return Consumer(
          builder: (context, ref, child) {
            return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: documents.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) {
            final doc = documents[index];
            return Card(
              color: const Color(0xFF1a2633),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(doc.category),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doc.category,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                          color: const Color(0xFF101922),
                          onSelected: (value) async {
                            if (value == 'preview') {
                              // Dosya önizleme
                              if (doc.fileUrl != null && doc.fileUrl!.isNotEmpty) {
                                // Dosya uzantısını kontrol et
                                final fileUrl = doc.fileUrl!.toLowerCase();
                                
                                if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
                                  // Firebase Storage URL veya web linki - tarayıcıda aç
                                  final uri = Uri.parse(doc.fileUrl!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Dosya açılamadı'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else if (fileUrl.endsWith('.pdf') || 
                                           fileUrl.endsWith('.doc') || 
                                           fileUrl.endsWith('.docx')) {
                                  // Lokal dosya - open_file paketi ile aç
                                  final file = File(doc.fileUrl!);
                                  if (await file.exists()) {
                                    final result = await OpenFile.open(doc.fileUrl!);
                                    if (result.type != ResultType.done) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result.message),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Dosya bulunamadı'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else if (fileUrl.endsWith('.jpg') || 
                                           fileUrl.endsWith('.jpeg') || 
                                           fileUrl.endsWith('.png')) {
                                  // Resim dosyası - dialog içinde göster
                                  final file = File(doc.fileUrl!);
                                  if (await file.exists()) {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                          backgroundColor: Colors.black,
                                          child: Stack(
                                            children: [
                                              InteractiveViewer(
                                                child: Image.file(file),
                                              ),
                                              Positioned(
                                                top: 16,
                                                right: 16,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close, color: Colors.white),
                                                  onPressed: () => Navigator.pop(ctx),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Resim dosyası bulunamadı'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Bilinmeyen format - open_file ile aç
                                  final file = File(doc.fileUrl!);
                                  if (await file.exists()) {
                                    await OpenFile.open(doc.fileUrl!);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Dosya bulunamadı'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bu belgeye ait dosya bulunamadı'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            } else if (value == 'edit') {
                              // Düzenleme dialogu
                              _showEditDocumentDialog(context, ref, doc);
                            } else if (value == 'share') {
                              // Paylaşma
                              if (doc.fileUrl != null && doc.fileUrl!.isNotEmpty) {
                                // Dosya yolunu kontrol et
                                final fileUrl = doc.fileUrl!;
                                
                                if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
                                  // Web URL - sadece link paylaş
                                  await Share.share(
                                    'Belge: ${doc.title}\nKategori: ${doc.category}\n\nDosya: $fileUrl',
                                    subject: doc.title,
                                  );
                                } else {
                                  // Lokal dosya - dosyayı paylaş
                                  final file = File(fileUrl);
                                  if (await file.exists()) {
                                    await Share.shareXFiles(
                                      [XFile(fileUrl)],
                                      text: 'Belge: ${doc.title}\nKategori: ${doc.category}',
                                      subject: doc.title,
                                    );
                                  } else {
                                    // Dosya bulunamadı - sadece bilgileri paylaş
                                    await Share.share(
                                      'Belge: ${doc.title}\nKategori: ${doc.category}',
                                      subject: doc.title,
                                    );
                                  }
                                }
                              } else {
                                // Dosya yok - sadece bilgileri paylaş
                                await Share.share(
                                  'Belge: ${doc.title}\nKategori: ${doc.category}',
                                  subject: doc.title,
                                );
                              }
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1a2633),
                                  title: const Text(
                                    'Belgeyi Sil',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Bu belgeyi silmek istediğinize emin misiniz?',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('İptal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirm == true) {
                                await ref.read(documentsServiceProvider).deleteDocument(doc.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Belge silindi'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'preview',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18, color: Colors.white70),
                                  SizedBox(width: 12),
                                  Text('Önizle', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18, color: Colors.white70),
                                  SizedBox(width: 12),
                                  Text('Düzenle', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share, size: 18, color: Colors.white70),
                                  SizedBox(width: 12),
                                  Text('Paylaş', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Sil', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doc.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(doc.updatedAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
          },
        );
      },
    );
  }

  Widget _buildStats() {
    final stats = [
      _StatCard('Aktif Dosya', '32', Icons.layers, const Color(0xFF1173d4)),
      _StatCard(
        'Bugün',
        '5 görev',
        Icons.calendar_today,
        const Color(0xFF59FFD5),
      ),
      _StatCard(
        'Tamamlanma',
        '%78',
        Icons.trending_up,
        const Color(0xFF4CAF50),
      ),
    ];

    return Card(
      color: const Color(0xFF1a2633),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: Row(
          children: stats
              .map(
                (stat) => Expanded(
                  child: Column(
                    children: [
                      Icon(stat.icon, color: stat.color, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        stat.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stat.label,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActiveCases(BuildContext context) {
    final cases = [
      _CaseCard(
        title: 'ABC Holding vs. Vergi Dairesi',
        court: 'İstanbul 6. Vergi Mah.',
        status: 'Duruşma yarın',
        progress: 0.72,
        color: const Color(0xFF1173d4),
      ),
      _CaseCard(
        title: 'Beta Yazılım / İşçilik',
        court: 'Bakırköy 14. İş Mah.',
        status: 'Delil listesi bekliyor',
        progress: 0.38,
        color: const Color(0xFF59FFD5),
      ),
      _CaseCard(
        title: 'Gamma A.Ş. Tazminat',
        court: 'Kadıköy 2. Asliye Tic.',
        status: 'İnceleme aşamasında',
        progress: 0.55,
        color: const Color(0xFF4CAF50),
      ),
    ];

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cases.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = cases[index];
          return SizedBox(
            width: 300,
            child: Card(
              color: const Color(0xFF1a2633),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.court,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(color: item.color, fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(item.progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        color: item.color,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline() {
    final events = [
      _TimelineEvent(
        time: '09:30',
        title: 'Duruşma',
        detail: 'Şişli 2.Asliye - HMK 281 sözlü anlatım',
        tag: 'Mahkeme',
        color: const Color(0xFF1173d4),
      ),
      _TimelineEvent(
        time: '13:45',
        title: 'Müvekkil görüşmesi',
        detail: 'Risk analizi çıktılarını CFO ile paylaş',
        tag: 'Toplantı',
        color: const Color(0xFF59FFD5),
      ),
      _TimelineEvent(
        time: '17:15',
        title: 'Delil yükleme',
        detail: 'E-devlet entegrasyonundan belgeleri doğrula',
        tag: 'Görev',
        color: const Color(0xFF4CAF50),
      ),
    ];

    return Card(
      color: const Color(0xFF1a2633),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bugünkü Timeline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...events.map((event) => _TimelineTile(event: event)),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1173d4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade400,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _StatCard {
  const _StatCard(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _CaseCard {
  const _CaseCard({
    required this.title,
    required this.court,
    required this.status,
    required this.progress,
    required this.color,
  });

  final String title;
  final String court;
  final String status;
  final double progress;
  final Color color;
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.time,
    required this.title,
    required this.detail,
    required this.tag,
    required this.color,
  });

  final String time;
  final String title;
  final String detail;
  final String tag;
  final Color color;
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event});

  final _TimelineEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: event.color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 46,
                color: Colors.white.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.time,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  event.detail,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.chevron_right,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard {
  const _DocumentCard({
    required this.title,
    required this.category,
    required this.updatedAt,
    required this.color,
  });

  final String title;
  final String category;
  final String updatedAt;
  final Color color;
}

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'duruşma':
    case 'durusma':
      return const Color(0xFF1173d4);
    case 'analiz':
      return const Color(0xFF59FFD5);
    case 'uygunluk':
      return const Color(0xFF4CAF50);
    case 'belgeler':
      return const Color(0xFFFFB347);
    case 'delil':
      return const Color(0xFFE91E63);
    case 'delil listesi':
      return const Color(0xFF9C27B0);
    default:
      return const Color(0xFF1173d4);
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Bilinmiyor';
  
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inMinutes < 1) {
    return 'Şimdi';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} dk önce';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} saat önce';
  } else if (difference.inDays == 1) {
    return 'Dün';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} gün önce';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

const _docs = [
  _DocumentCard(
    title: 'HMK 281 İtiraz Taslağı',
    category: 'Duruşma',
    updatedAt: '12 dk önce',
    color: Color(0xFF1173d4),
  ),
  _DocumentCard(
    title: 'Risk Analiz Raporu',
    category: 'Analiz',
    updatedAt: 'Dün',
    color: Color(0xFF59FFD5),
  ),
  _DocumentCard(
    title: 'KVKK Veri Akış Şeması',
    category: 'Uygunluk',
    updatedAt: '2 gün önce',
    color: Color(0xFF4CAF50),
  ),
  _DocumentCard(
    title: 'Sözleşme Ekleri',
    category: 'Belgeler',
    updatedAt: '1 saat önce',
    color: Color(0xFFFFB347),
  ),
  _DocumentCard(
    title: 'Bilirkişi Raporu v2',
    category: 'Delil',
    updatedAt: '3 gün önce',
    color: Color(0xFFE91E63),
  ),
  _DocumentCard(
    title: 'E-posta Trafiği Özet',
    category: 'Delil Listesi',
    updatedAt: 'Bugün',
    color: Color(0xFF9C27B0),
  ),
];

void _showAddCaseDialog(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final titleController = TextEditingController();
  final caseNumberController = TextEditingController();
  final courtController = TextEditingController();
  String selectedStatus = l10n.statusOngoing;
  DateTime? selectedDate;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1a2633),
        title: Text(
          l10n.addNewCase,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.caseTitle,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF101922),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: caseNumberController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.caseNumber,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF101922),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: courtController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.court,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF101922),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                dropdownColor: const Color(0xFF101922),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.status,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF101922),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [l10n.statusOngoing, l10n.statusWon, l10n.statusLost, l10n.statusPending]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF1173d4),
                            surface: Color(0xFF1a2633),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101922),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate == null
                            ? l10n.selectDate
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  caseNumberController.text.isEmpty ||
                  courtController.text.isEmpty ||
                  selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.allCategories), // "Lütfen tüm alanları doldurun" çevirisi eklenecek
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await ref.read(casesServiceProvider).addCase(
                    title: titleController.text,
                    caseNumber: caseNumberController.text,
                    court: courtController.text,
                    status: selectedStatus,
                    nextHearing: selectedDate!,
                  );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.caseAdded),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1173d4),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
  );
}

void _showAddDocumentDialog(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final titleController = TextEditingController();
  
  // Kategori map'i - key: database değeri, value: görünen metin
  final categories = {
    'Duruşma': l10n.docCategoryHearing,
    'Analiz': l10n.docCategoryAnalysis,
    'Uygunluk': l10n.docCategoryCompliance,
    'Belgeler': l10n.docCategoryDocuments,
    'Delil': l10n.docCategoryEvidence,
    'Delil Listesi': l10n.docCategoryEvidenceList,
  };
  
  String selectedCategory = 'Duruşma';
  String? selectedFileName;
  String? selectedFilePath; // Dosya yolunu saklamak için

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1a2633),
        title: Text(
          l10n.addNewDocument,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.documentTitle,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF101922),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: const Color(0xFF101922),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.category,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF101922),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categories.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
                  );
                  
                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      selectedFileName = result.files.first.name;
                      selectedFilePath = result.files.first.path; // Dosya yolunu kaydet
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.selectFile}: ${result.files.first.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: Icon(
                  selectedFileName != null ? Icons.check_circle : Icons.attach_file,
                  color: selectedFileName != null ? Colors.green : Colors.white70,
                ),
                label: Text(
                  selectedFileName ?? l10n.selectFile,
                  style: TextStyle(
                    color: selectedFileName != null ? Colors.green : Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: selectedFileName != null ? Colors.green : Colors.white30,
                  ),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.documentTitle),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await ref.read(documentsServiceProvider).addDocument(
                    title: titleController.text,
                    category: selectedCategory,
                    fileUrl: selectedFilePath, // Dosya yolunu kaydet
                  );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.documentAdded),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1173d4),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
  );
}

void _showEditDocumentDialog(BuildContext context, WidgetRef ref, DocumentModel doc) {
  final titleController = TextEditingController(text: doc.title);
  
  // Dropdown için tüm kategorileri tanımla (mutable list)
  final availableCategories = <String>[
    'Sözleşmeler',
    'Dilekçeler',
    'Kararlar',
    'İlamlar',
    'Diğer',
  ];
  
  // Eğer mevcut kategori listede yoksa, listeye ekle
  String selectedCategory = doc.category;
  if (!availableCategories.contains(selectedCategory)) {
    availableCategories.add(selectedCategory);
  }

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1a2633),
      title: const Text(
        'Belgeyi Düzenle',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Belge Adı',
                labelStyle: TextStyle(color: Color(0xFF59FFD5)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1173d4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF59FFD5)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: const Color(0xFF1a2633),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: TextStyle(color: Color(0xFF59FFD5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1173d4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF59FFD5)),
                  ),
                ),
                items: availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(
            'İptal',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (titleController.text.isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text('Lütfen belge adını girin'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Dialogu kapat
            Navigator.pop(dialogContext);

            // updateDocument metodunu kullan
            await ref.read(documentsServiceProvider).updateDocument(
              documentId: doc.id,
              title: titleController.text,
              category: selectedCategory,
            );

            // Ana context'i kontrol et
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Belge başarıyla güncellendi'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1173d4),
          ),
          child: const Text('Güncelle'),
        ),
      ],
    ),
  );
}




