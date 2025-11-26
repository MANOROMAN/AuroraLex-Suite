import 'package:flutter/material.dart';

import '../../../widgets/glass_card.dart';

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = _docs;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1300
            ? 3
            : constraints.maxWidth > 800
            ? 2
            : 1;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Aurora Vault',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, color: Colors.white70),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: documents.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: doc.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              doc.category,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          doc.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doc.updatedAt,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Onizle'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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

const _docs = [
  _DocumentCard(
    title: 'HMK 281 Itiraz Taslag',
    category: 'Durusma',
    updatedAt: '12 dk once',
    color: Color(0xFF59FFD5),
  ),
  _DocumentCard(
    title: 'Risk Pulse Raporu',
    category: 'Analiz',
    updatedAt: 'Dun',
    color: Color(0xFFFF8FB7),
  ),
  _DocumentCard(
    title: 'KVKK Veri Aks',
    category: 'Uygunluk',
    updatedAt: '2 gun once',
    color: Color(0xFF7B6BFF),
  ),
  _DocumentCard(
    title: 'Sozlesme Ekleri',
    category: 'Belgeler',
    updatedAt: '1 saat once',
    color: Color(0xFFFFB347),
  ),
];
