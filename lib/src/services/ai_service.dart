import 'dart:convert';
import 'package:http/http.dart' as http;

/// Hukuk odaklı AI Servisi - Google Gemini API
/// Ücretsiz: 15 istek/dakika, 1,500 istek/gün
class GeminiLegalService {
  final String apiKey;

  GeminiLegalService({required this.apiKey});

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // Türk Hukuku odaklı sistem promptu - ÇOK DETAYLI VERSİYON
  static const String _legalSystemPrompt = '''
Sen AuroraLex AI, Türkiye Cumhuriyeti Hukuk Sistemi konusunda uzmanlaşmış yapay zeka asistanısın. Görevin kullanıcılara son derece detaylı, akademik düzeyde, kanun maddelerine dayalı hukuki bilgi ve yorumlar sunmaktır.

🎯 GÖREV VE SORUMLULUKLAR:

Sen bir hukuk profesörü gibi davran. Her soruya kapsamlı, derinlemesine, akademik bir analiz sun. Kullanıcının hukuki durumunu tüm boyutlarıyla ele al, olası senaryoları değerlendir, emsal kararları referans göster ve hukuki yorumlar yap.

📚 KAYNAK KULLANIMI - MUTLAKA ŞUNLARI REFERANS VER:

1. ANAYASA (1982 T.C. Anayasası)
   - İlgili temel hak ve özgürlükleri belirt (örn: Madde 17-Yaşam Hakkı, Madde 19-Kişi Hürriyeti)
   - Anayasal güvenceleri açıkla
   - Anayasa Mahkemesi kararlarına atıfta bulun

2. TÜRK CEZA KANUNU (TCK - 5237 Sayılı)
   - İlgili suçun tanımını tam metin olarak ver
   - Ceza miktarlarını alt ve üst sınırlarıyla belirt
   - Temel ceza + artırım/indirim sebeplerini detaylandır

3. CEZA MUHAKEMESI KANUNU (CMK - 5271 Sayılı)
   - Kovuşturma prosedürünü açıkla
   - Tutuklama/adli kontrol şartlarını belirt
   - Delil toplama sürecini özetle

4. TÜRK MEDENI KANUNU (TMK - 4721 Sayılı)
   - Medeni hukuk yönlerini ele al
   - Aile hukuku, miras hukuku maddelerini belirt

5. TÜRK BORÇLAR KANUNU (TBK - 6098 Sayılı)
   - Sözleşme hukuku maddelerini referans ver
   - Tazminat hesaplamalarını açıkla

6. İŞ KANUNU (4857 Sayılı)
   - İşçi-işveren ilişkilerini değerlendir
   - Kıdem-ihbar tazminatı hesapla

🎓 CEVAP YAPISI - HER CEVAP MUTLAKA ŞUNLARI İÇERSİN:

1. DURUM ANALİZİ VE HUKUKİ NİTELENDİRME
- Kullanıcının durumunu hukuki açıdan sınıflandır
- Hangi hukuk dalına girdiğini belirt
- Birden fazla suç/ihlal varsa hepsini say

2. ANAYASAL BOYUT
- İlgili Anayasa maddelerini belirt
- Temel hak ve özgürlüklere etkisini açıkla

3. KANUN MADDELERİ (TAM METİN ALINTI)
- Madde numarasını yaz
- Madde metnini tırnak içinde TAM OLARAK ver
- Maddenin fıkra ve bentlerini ayrı ayrı açıkla

4. HUKUKİ ANALİZ VE YORUM
- Kanun maddesinin nasıl yorumlandığını açıkla
- Yargıtay kararlarına atıfta bulun
- Doktrindeki görüşleri özetle

5. OLASI SENARYOLAR VE TAHMİNLER
- En iyi senaryo
- Orta senaryo
- En kötü senaryo
- Her senaryonun olasılığını yüzde olarak tahmin et

6. CEZA/TAZMİNAT HESAPLAMALARI
- Temel ceza/tazminat miktarını belirt
- Artırım sebeplerini say
- İndirim sebeplerini say
- Tahmini nihai miktar aralığını hesapla

7. SÜREÇ HAKKINDA BİLGİLENDİRME
- Hangi mahkemeye başvurulacak
- Dava süreci nasıl işleyecek
- Zamanaşımı süreleri
- Uzlaşma imkanı

8. PRATIK ÖNERİLER
- Hemen yapılması gerekenler
- Sakınılması gereken hatalar
- Delil toplama önerileri

9. YASAL UYARI (MUTLAKA)
- Bu bilgilerin genel nitelikte olduğunu vurgula
- Kesin olmadığını belirt
- Avukat tutulmasını öner

📊 DETAYLANDIRMA:

- Minimum 800 kelime yanıt ver
- En az 5 kanun maddesi referans ver
- Her maddeden sonra açıklama yap
- Somut örnekler ver
- Matematiksel hesaplamalar yap

💬 ÜSLUP VE FORMAT:

- Akademik ama anlaşılır dil kullan
- Hukuki terimleri açıkla
- Emoji ile konuları ayır (🎯 📚 ⚖️ 💡 ⚠️ gibi)
- ASLA markdown formatı kullanma (**, *, #, vb.)
- Başlıklar için sadece BÜYÜK HARF ve emoji kullan
- Maddeler için tire (-) veya numara (1., 2.) kullan
- Kalın yazı formatı YASAK

ÖNEMLİ FORMAT KURALLARI:
❌ KULLANMA: **kalın yazı**, *italic*, ***bold italic***
❌ KULLANMA: # Başlık, ## Alt Başlık
✅ KULLAN: BÜYÜK HARF BAŞLIKLAR
✅ KULLAN: Emoji + Başlık (🎯 GÖREV VE SORUMLULUKLAR)
✅ KULLAN: Tire veya numara ile liste

⚠️ ÖNEMLİ: HER CEVABINSONUNDA MUTLAKA ŞU UYARIYI EKLE:

"⚠️ ÖNEMLİ YASAL UYARI

Bu bilgiler Türk Hukuku'nun genel prensiplerine dayanmakta olup, sizin somut durumunuz için kesin bir hüküm niteliği taşımaz. Verilen ceza tahminleri ve yorumlar, genel uygulamalara göre yapılan değerlendirmelerdir.

Her dava kendine özgüdür ve mahkeme takdir yetkisini kullanır. Mutlaka bir avukata danışın. Avukat, dosyanıza özel strateji geliştirecek ve haklarınızı savunacaktır.

Unutmayın: Bu platform hukuki danışmanlık hizmeti vermez, sadece genel bilgilendirme amaçlıdır."
''';

  /// Hukuki soru sor (konuşma geçmişi ile)
  Future<String> askLegalQuestion(String question, {List<Map<String, String>>? chatHistory}) async {
    if (question.trim().isEmpty) {
      return 'Lütfen bir soru sorunuz.';
    }

    if (question.length > 2000) {
      return 'Mesajınız çok uzun. Lütfen sorunuzu daha kısa bir şekilde ifade edin.';
    }

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        List<Map<String, dynamic>> contents = [];
        
        contents.add({
          'role': 'user',
          'parts': [{'text': _legalSystemPrompt}],
        });
        
        contents.add({
          'role': 'model',
          'parts': [{'text': 'Anladım. Türk Hukuku uzmanı olarak son derece detaylı, kanun maddelerine dayalı, akademik düzeyde cevaplar vereceğim. Her cevabımda Anayasa, TCK, CMK, TMK gibi kanunlardan alıntılar yapacak, olasılık tahminleri sunacak ve sonunda yasal uyarı ekleyeceğim.'}],
        });
        
        if (chatHistory != null && chatHistory.isNotEmpty) {
          for (var message in chatHistory) {
            contents.add({
              'role': message['role'] ?? 'user',
              'parts': [{'text': message['text'] ?? ''}],
            });
          }
        }
        
        contents.add({
          'role': 'user',
          'parts': [{'text': question}],
        });

        final response = await http
            .post(
              Uri.parse('$_baseUrl?key=$apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': contents,
                'generationConfig': {
                  'temperature': 0.8,
                  'maxOutputTokens': 4096, // Daha uzun cevaplar için
                  'topP': 0.95,
                  'topK': 40,
                },
                'safetySettings': [
                  {
                    'category': 'HARM_CATEGORY_HARASSMENT',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
                  },
                  {
                    'category': 'HARM_CATEGORY_HATE_SPEECH',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
                  },
                  {
                    'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
                  },
                  {
                    'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
                  },
                ],
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            String answer = data['candidates'][0]['content']['parts'][0]['text'];
            
            // Markdown formatını temizle
            answer = _cleanMarkdown(answer);
            
            // Yasal uyarı kontrolü - yoksa ekle
            if (!answer.contains('YASAL UYARI') && !answer.contains('avukata danışın')) {
              answer += '\n\n⚠️ ÖNEMLİ YASAL UYARI\n\nBu bilgiler genel niteliktedir ve kesin hüküm değildir. Her dava kendine özgüdür. Mutlaka bir avukata danışın. Bu platform hukuki danışmanlık hizmeti vermez.';
            }
            
            return answer;
          } else {
            return 'Üzgünüm, şu anda yanıt üretemiyorum. Lütfen sorunuzu farklı şekilde ifade edin.';
          }
        } else if (response.statusCode == 429) {
          return '⏱️ Rate limit aşıldı!\n\nGoogle Gemini ücretsiz kullanımda sıkı limitler var.\n\n🔸 5 dakika bekleyin\n🔸 Ardından tekrar sorun\n\nYa da farklı bir API key kullanın.';
        } else if (response.statusCode == 503) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: 2 * retryCount));
            continue;
          }
          return 'Sistem şu anda çok yoğun. Lütfen birkaç dakika sonra tekrar deneyin.';
        } else if (response.statusCode == 400) {
          return '❌ Geçersiz istek. Lütfen sorunuzu farklı şekilde ifade edin.';
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          return '🔑 API anahtarınız geçersiz. Lütfen ayarlardan kontrol edin.';
        } else {
          return 'API Hatası: ${response.statusCode}\nLütfen daha sonra tekrar deneyin.';
        }
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * retryCount));
          continue;
        }
        return 'Bağlantı sorunu.\n\nİnternet bağlantınızı kontrol edin.\nHata: ${e.toString()}';
      }
    }

    return 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  }

  /// Markdown formatını temizle (**, *, #, vb.)
  String _cleanMarkdown(String text) {
    String cleaned = text;
    
    // *** bold italic ***
    cleaned = cleaned.replaceAll(RegExp(r'\*\*\*([^\*]+)\*\*\*'), r'\1');
    
    // ** bold **
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'\1');
    
    // * italic *
    cleaned = cleaned.replaceAll(RegExp(r'\*([^\*\n]+)\*'), r'\1');
    
    // # Başlık formatları
    cleaned = cleaned.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    
    // __ alt çizgi bold __
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'\1');
    
    // _ alt çizgi italic _
    cleaned = cleaned.replaceAll(RegExp(r'_([^_\n]+)_'), r'\1');
    
    return cleaned;
  }

  Future<bool> testApiKey() async {
    try {
      final testQuestion = 'Merhaba';
      final response = await askLegalQuestion(testQuestion);
      
      if (response.contains('API anahtarınız') || 
          response.contains('geçersiz') ||
          response.contains('Bağlantı sorunu')) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
