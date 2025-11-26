import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/i18n/app_localizations.dart';

class LegalDictionaryTab extends HookWidget {
  const LegalDictionaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searchQuery = useState<String>('');
    final selectedCategory = useState<String?>('Tümü');
    
    // Dil kontrolü
    final isEnglish = l10n.localeName == 'en';
    
    // Dile göre terimleri al
    final terms = isEnglish ? _getLegalTermsEn() : _getLegalTermsTr();
    
    // Filtrelenmiş terimler
    final filteredTerms = terms.where((term) {
      // Kategori filtresi
      final categoryMatch = selectedCategory.value == 'Tümü' || 
                           term.category == selectedCategory.value;
      
      // Arama filtresi
      final searchMatch = searchQuery.value.isEmpty ||
                         term.title.toLowerCase().contains(searchQuery.value) ||
                         term.definition.toLowerCase().contains(searchQuery.value);
      
      return categoryMatch && searchMatch;
    }).toList();
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                onChanged: (value) {
                  searchQuery.value = value.toLowerCase();
                },
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: l10n.searchTerm,
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: const Color(0xFF1a2633),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryData(l10n.allCategories, 'Tümü'),
                    _CategoryData(l10n.criminalLawCategory, isEnglish ? 'Criminal Law' : 'Ceza Hukuku'),
                    _CategoryData(l10n.civilLawCategory, isEnglish ? 'Civil Law' : 'Medeni Hukuk'),
                    _CategoryData(l10n.commercialLawCategory, isEnglish ? 'Commercial Law' : 'Ticaret Hukuku'),
                    _CategoryData(l10n.laborLawCategory, isEnglish ? 'Labor Law' : 'İş Hukuku'),
                    _CategoryData(l10n.administrativeLawCategory, isEnglish ? 'Administrative Law' : 'İdare Hukuku'),
                    _CategoryData('Enforcement Law', isEnglish ? 'Enforcement Law' : 'İcra İflas Hukuku'),
                  ].map((categoryData) {
                    final isSelected = selectedCategory.value == categoryData.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(categoryData.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          selectedCategory.value = categoryData.key;
                        },
                        backgroundColor: const Color(0xFF1a2633),
                        selectedColor: const Color(0xFF1173d4),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade400,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Terms List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: filteredTerms.map((term) {
                  return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF1a2633),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            title: Text(
              term.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                term.category,
                style: TextStyle(
                  color: _getCategoryColor(term.category),
                  fontSize: 13,
                ),
              ),
            ),
            iconColor: const Color(0xFF1173d4),
            collapsedIconColor: Colors.grey.shade600,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  term.definition,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              if (term.example != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101922),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnglish ? 'Example:' : 'Örnek:',
                        style: const TextStyle(
                          color: Color(0xFF1173d4),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        term.example!,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (term.relatedTerms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: term.relatedTerms.map((related) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101922),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF1173d4).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        related,
                        style: const TextStyle(
                          color: Color(0xFF1173d4),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      }).toList(),
              ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ceza Hukuku':
      case 'Criminal Law':
        return const Color(0xFFFF6B6B);
      case 'Medeni Hukuk':
      case 'Civil Law':
        return const Color(0xFF4ECDC4);
      case 'Ticaret Hukuku':
      case 'Commercial Law':
        return const Color(0xFFFFE66D);
      case 'İş Hukuku':
      case 'Labor Law':
        return const Color(0xFF95E1D3);
      case 'İdare Hukuku':
      case 'Administrative Law':
        return const Color(0xFFA8DADC);
      case 'İcra İflas Hukuku':
      case 'Enforcement Law':
        return const Color(0xFFB8A7D9);
      default:
        return const Color(0xFF1173d4);
    }
  }
}

class _LegalTerm {
  final String title;
  final String category;
  final String definition;
  final String? example;
  final List<String> relatedTerms;

  const _LegalTerm({
    required this.title,
    required this.category,
    required this.definition,
    this.example,
    this.relatedTerms = const [],
  });
}

// Turkish Terms
List<_LegalTerm> _getLegalTermsTr() => const [
  _LegalTerm(
    title: 'İhbar Tazminatı',
    category: 'İş Hukuku',
    definition: 'İş sözleşmesinin feshedilmesi durumunda işverenin işçiye ödemesi gereken tazminattır. İhbar süresine uymadan iş sözleşmesini fesheden taraf, diğer tarafa ihbar süresi kadar ücret tutarında tazminat ödemekle yükümlüdür.',
    example: 'Bir işçi 5 yıldır çalıştığı şirketten haklı sebep olmaksızın işten çıkarılırsa, 8 haftalık ihbar tazminatı alma hakkına sahiptir.',
    relatedTerms: ['Kıdem Tazminatı', 'İş Sözleşmesi', 'Fesih'],
  ),
  _LegalTerm(
    title: 'Kıdem Tazminatı',
    category: 'İş Hukuku',
    definition: 'En az bir yıl çalışmış işçinin, iş sözleşmesinin belirli koşullarda sona ermesi halinde işverenden talep edebileceği tazminattır. Her geçen tam yıl için 30 günlük brüt ücret tutarında ödenir.',
    example: 'Emekliye ayrılan bir işçi, 15 yıllık çalışma süresi için kıdem tazminatı talep edebilir.',
    relatedTerms: ['İhbar Tazminatı', 'Emeklilik', 'İş Akdi'],
  ),
  _LegalTerm(
    title: 'Hapis Cezası',
    category: 'Ceza Hukuku',
    definition: 'Suç işleyen kişinin özgürlüğünden yoksun bırakılmasını içeren ceza türüdür. TCK\'ya göre ağırlaştırılmış müebbet hapis, müebbet hapis ve süreli hapis cezası olmak üzere üç türü vardır.',
    example: 'Kasten yaralama suçu için Türk Ceza Kanunu\'nda 1 yıldan 3 yıla kadar hapis cezası öngörülmüştür.',
    relatedTerms: ['Adli Para Cezası', 'Güvenlik Tedbiri', 'TCK'],
  ),
  _LegalTerm(
    title: 'Nafaka',
    category: 'Medeni Hukuk',
    definition: 'Boşanma veya ayrılık durumunda, ekonomik durumu daha zayıf olan eşe veya çocuklara, diğer eş tarafından ödenmesi gereken parasal yardımdır. İştirak nafakası, yoksulluk nafakası ve tedbir nafakası olmak üzere türleri vardır.',
    example: 'Boşanan bir kadın, eğer evlilik birliğinin devamı süresince ev hanımı olarak çalışmış ve geliri yoksa, eski eşinden yoksulluk nafakası talep edebilir.',
    relatedTerms: ['Boşanma', 'Velayet', 'Mal Rejimi'],
  ),
  _LegalTerm(
    title: 'Limited Şirket',
    category: 'Ticaret Hukuku',
    definition: 'Ticaret Kanunu\'na göre kurulan, esas sermayesi belirli ve paylara bölünmüş olan, ortakların sorumluluğunun koydukları sermaye ile sınırlı olduğu sermaye şirketidir. En az bir ortak ile kurulabilir.',
    example: 'Küçük ve orta ölçekli işletmeler genellikle limited şirket şeklinde kurulur çünkü ortakların kişisel mal varlıkları korunur.',
    relatedTerms: ['Anonim Şirket', 'Kollektif Şirket', 'TTK'],
  ),
  _LegalTerm(
    title: 'Anonim Şirket',
    category: 'Ticaret Hukuku',
    definition: 'Esas sermayesi belirli ve paylara bölünmüş, borçlarından dolayı yalnızca mal varlığıyla sorumlu olan sermaye şirketidir. Hisse senetleri çıkarabilir ve halka açılabilir.',
    example: 'Büyük şirketler genellikle anonim şirket şeklinde kurulur ve hisse senetleri borsada işlem görebilir.',
    relatedTerms: ['Limited Şirket', 'Hisse Senedi', 'Genel Kurul'],
  ),
  _LegalTerm(
    title: 'İpotekli Borç',
    category: 'Medeni Hukuk',
    definition: 'Bir taşınmaz veya tapu kütüğüne kayıtlı olan diğer bir ayni hak üzerinde, belirli bir alacağı güvence altına almak amacıyla kurulan ayni bir haktır.',
    example: 'Ev kredisi çeken kişi, satın aldığı evi bankaya ipotek olarak verir.',
    relatedTerms: ['Rehin', 'Taşınmaz', 'Ayni Hak'],
  ),
  _LegalTerm(
    title: 'İdari Yargı',
    category: 'İdare Hukuku',
    definition: 'İdari işlem ve eylemlerden kaynaklanan uyuşmazlıkların çözüldüğü yargı koludur. İdare mahkemeleri, bölge idare mahkemeleri ve Danıştay\'dan oluşur.',
    example: 'Bir kamu görevlisinin maaş kesme cezasına karşı açtığı dava idari yargıda görülür.',
    relatedTerms: ['Danıştay', 'İdari İşlem', 'İptal Davası'],
  ),
  _LegalTerm(
    title: 'Velayet',
    category: 'Medeni Hukuk',
    definition: 'Ergin olmayan çocukların şahıslarını ve mallarını korumak, gözetmek ve temsil etmek hak ve yetkisinin bütünüdür. Velayetin kullanılmasında ana ve baba eşit hak ve yükümlülüklere sahiptir.',
    example: 'Boşanan ebeveynlerden birine velayet verilebilir veya ortak velayet kararı alınabilir.',
    relatedTerms: ['Nafaka', 'Boşanma', 'Vesayet'],
  ),
  _LegalTerm(
    title: 'Kasten Yaralama',
    category: 'Ceza Hukuku',
    definition: 'Bir başkasının vücuduna acı veren veya sağlığının ya da algılama yeteneğinin bozulmasına neden olan fiil olarak tanımlanır. Basit tıbbi müdahale ile giderilebiliyorsa basit, aksi halde ağır yaralama suçu oluşur.',
    example: 'Kavga sırasında bir kişinin burnunu kırması kasten yaralama suçunu oluşturur.',
    relatedTerms: ['Hapis Cezası', 'TCK', 'Müdafi'],
  ),
  _LegalTerm(
    title: 'Sözleşme',
    category: 'Medeni Hukuk',
    definition: 'İki veya daha fazla tarafın karşılıklı ve birbirine uygun irade beyanları ile kurulan hukuki işlemdir. Yazılı veya sözlü olabilir.',
    example: 'Kira sözleşmesi, alım satım sözleşmesi, iş sözleşmesi gibi çeşitli türleri vardır.',
    relatedTerms: ['İrade Beyanı', 'Borç', 'Edim'],
  ),
  _LegalTerm(
    title: 'Zamanaşımı',
    category: 'Medeni Hukuk',
    definition: 'Belirli bir sürenin geçmesi nedeniyle bir hakkın kullanılamaması veya borcun düşmesi halidir. Her türlü alacak için farklı zamanaşımı süreleri bulunur.',
    example: '10 yıllık zamanaşımı süresinde tahsil edilmeyen kira alacağı düşer.',
    relatedTerms: ['Hak Düşümü', 'Alacak', 'Dava Açma'],
  ),
  _LegalTerm(
    title: 'İş Kazası',
    category: 'İş Hukuku',
    definition: 'İşyerinde veya işin yürütümü nedeniyle meydana gelen, ölüme veya bedensel ya da ruhsal bir zarara yol açan olaydır. Meslek hastalığından farklıdır.',
    example: 'İnşaat işçisinin iskeleden düşerek yaralanması iş kazasıdır.',
    relatedTerms: ['Meslek Hastalığı', 'Sosyal Güvenlik', 'İşveren Sorumluluğu'],
  ),
  _LegalTerm(
    title: 'Ceza Ehliyeti',
    category: 'Ceza Hukuku',
    definition: 'Bir kişinin işlediği fiilden dolayı cezalandırılabilmesi için gerekli olan ayırt etme ve davranışlarını yönlendirebilme yeteneğidir. 12 yaşından küçük çocuklar ceza ehliyetine sahip değildir.',
    example: '10 yaşındaki bir çocuk suç işlese bile cezai sorumluluğu olmaz.',
    relatedTerms: ['TCK', 'Kusur', 'Kast'],
  ),
  _LegalTerm(
    title: 'Haczedilmezlik',
    category: 'İcra İflas Hukuku',
    definition: 'Bazı mal ve hakların borçlunun geçimi için gerekli olması sebebiyle haczi mümkün olmayan malların tümüdür. Asgari ücret, emekli maaşının bir kısmı, zorunlu ev eşyaları haczedilemez.',
    example: 'Borçlunun geçimi için gerekli olan yatak, masa, sandalye gibi eşyalar haczedilemez.',
    relatedTerms: ['Haciz', 'İcra Takibi', 'Borçlu'],
  ),
  _LegalTerm(
    title: 'Dolandırıcılık',
    category: 'Ceza Hukuku',
    definition: 'Hileli davranışlarla bir kimseyi aldatıp, onun veya başkasının zararına olarak, kendisine veya başkasına bir yarar sağlamak suçudur. TCK 157. maddede düzenlenmiştir.',
    example: 'Sahte belge düzenleyerek banka kredisi çekmek dolandırıcılık suçunu oluşturur.',
    relatedTerms: ['Hile', 'Güveni Kötüye Kullanma', 'Sahtecilik'],
  ),
  _LegalTerm(
    title: 'Tehdit',
    category: 'Ceza Hukuku',
    definition: 'Bir kimseye bir kötülük ihsas veya isnat edilmesi suretiyle gerçekleşen suçtur. Kişinin huzur ve sükununu bozmaya yöneliktir.',
    example: 'Birinin ailesine zarar vereceğini söylemek tehdit suçunu oluşturur.',
    relatedTerms: ['Hakaret', 'Şantaj', 'Korkutma'],
  ),
  _LegalTerm(
    title: 'Zimmet',
    category: 'Ceza Hukuku',
    definition: 'Kamu görevlisinin görevinin sağladığı kolaylıkla kendisinin veya başkasının zilyetliğinde bulunan para veya malları kendine veya başkasına mal etmesidir.',
    example: 'Belediye veznedarının kasadaki parayı kişisel kullanımına alması zimmet suçudur.',
    relatedTerms: ['Görevi Kötüye Kullanma', 'İrtikap', 'Rüşvet'],
  ),
  _LegalTerm(
    title: 'Hakaret',
    category: 'Ceza Hukuku',
    definition: 'Bir kimseye onur, şeref ve saygınlığını rencide edebilecek somut bir fiil veya olgu isnat etmek ya da sövmek suretiyle işlenir.',
    example: 'Sosyal medyada birine ağır küfürler etmek hakaret suçunu oluşturabilir.',
    relatedTerms: ['Tehdit', 'İftira', 'Kişilik Hakları'],
  ),
  _LegalTerm(
    title: 'Hırsızlık',
    category: 'Ceza Hukuku',
    definition: 'Zilyedinin rızası olmaksızın bir malın bulunduğu yerden alınmasıdır. Gece vakti, kilitli yer gibi nitelikli hallerde ceza artar.',
    example: 'Marketten cebe mal indirmek hırsızlık suçunu oluşturur.',
    relatedTerms: ['Yağma', 'Mala Zarar Verme', 'Zilyetlik'],
  ),
  _LegalTerm(
    title: 'Taksirle Ölüme Sebebiyet',
    category: 'Ceza Hukuku',
    definition: 'Dikkat ve özen yükümlülüğüne aykırılık nedeniyle bir kişinin ölümüne neden olunmasıdır. Trafik kazaları en yaygın örneklerdendir.',
    example: 'Alkollü araç kullanırken kaza yapıp birinin ölümüne sebep olmak bu suçu oluşturur.',
    relatedTerms: ['Taksir', 'Kasten Öldürme', 'Trafik Suçları'],
  ),
  _LegalTerm(
    title: 'Evlenme Şartları',
    category: 'Medeni Hukuk',
    definition: 'Evliliğin geçerli olabilmesi için gerekli koşullardır. 17 yaş, evlenme ehliyeti, evlenme yasağı bulunmaması gibi şartlar aranır.',
    example: 'Hakim onayı ile 16 yaşını doldurmuş bir kişi evlenebilir.',
    relatedTerms: ['Nişanlanma', 'Evliliğin Butlanı', 'Medeni Hal'],
  ),
  _LegalTerm(
    title: 'Mal Rejimi',
    category: 'Medeni Hukuk',
    definition: 'Eşlerin evlilik birliği içinde malvarlıkları arasındaki ilişkiyi düzenleyen hukuki statüdür. Edinilmiş mallara katılma rejimi yasal mal rejimidir.',
    example: 'Boşanmada edinilmiş mallar eşler arasında eşit paylaşılır.',
    relatedTerms: ['Boşanma', 'Mal Paylaşımı', 'Kişisel Mal'],
  ),
  _LegalTerm(
    title: 'Vesayet',
    category: 'Medeni Hukuk',
    definition: 'Anne ve babası olmayan veya velayetten yoksun kalan küçüklerin ve kısıtlıların kişilik ve mal haklarını korumak için kurulan bir müessesedir.',
    example: 'Ebeveynleri vefat eden bir çocuk için mahkeme vasi tayin eder.',
    relatedTerms: ['Velayet', 'Küçük', 'Kayyım'],
  ),
  _LegalTerm(
    title: 'Miras',
    category: 'Medeni Hukuku',
    definition: 'Bir kişinin ölümü ile mal varlığının mirasçılara geçmesidir. Yasal ve atanmış mirasçılık olmak üzere iki türü vardır.',
    example: 'Ölen kişinin mal varlığı vasiyetname yoksa yasal mirasçılar arasında paylaşılır.',
    relatedTerms: ['Vasiyetname', 'Saklı Pay', 'Tereке'],
  ),
  _LegalTerm(
    title: 'Boşanma',
    category: 'Medeni Hukuk',
    definition: 'Evlilik birliğinin mahkeme kararıyla sona erdirilmesidir. Anlaşmalı veya çekişmeli olabilir. Geçerli sebeplerin varlığı gerekir.',
    example: 'Eşlerin evlilik birliğini sürdürmesini çekilmez hale getiren sebeplerle boşanma davası açılabilir.',
    relatedTerms: ['Nafaka', 'Velayet', 'Tazminat'],
  ),
  _LegalTerm(
    title: 'Ticaret Unvanı',
    category: 'Ticaret Hukuku',
    definition: 'Tacirin ticari faaliyetlerinde kullandığı addır. Ticaret siciline tescil edilir ve korunur.',
    example: '"ABC Tekstil Limited Şirketi" bir ticaret unvanıdır.',
    relatedTerms: ['Ticaret Sicili', 'Marka', 'Ticari İşletme'],
  ),
  _LegalTerm(
    title: 'Ticari Defter',
    category: 'Ticaret Hukuku',
    definition: 'Tacirin ticari işlemlerini kaydetmek zorunda olduğu defterlerdir. Yevmiye defteri ve defteri kebir zorunludur.',
    example: 'Her ticari işletme gelir-gider kayıtlarını ticari defterlere işlemek zorundadır.',
    relatedTerms: ['Muhasebe', 'Envanter', 'Bilanço'],
  ),
  _LegalTerm(
    title: 'Ticari İşletme',
    category: 'Ticaret Hukuku',
    definition: 'Ticari faaliyette bulunmak üzere organize edilmiş insan gücü ve sermayenin bütünüdür. Devir ve intifa haklarına konu olabilir.',
    example: 'Bir market tüm demirbaşları, stoğu ve personeli ile birlikte devredebilir.',
    relatedTerms: ['Ticaret Unvanı', 'Ticari Mümessil', 'Haksız Rekabet'],
  ),
  _LegalTerm(
    title: 'Haksız Rekabet',
    category: 'Ticaret Hukuku',
    definition: 'Dürüstlük kuralına aykırı davranışlarla rakiplerin veya müşterilerin zararına yol açan rekabet davranışlarıdır.',
    example: 'Rakip firmanın ürününü kötülemek veya yanıltıcı reklam yapmak haksız rekabettir.',
    relatedTerms: ['Ticari Sır', 'Marka', 'Rekabet Yasağı'],
  ),
  _LegalTerm(
    title: 'Kıdem Kesme Cezası',
    category: 'İş Hukuku',
    definition: 'İşçinin disiplin kurallarına aykırı davranışları nedeniyle işverene tanınan, işçinin kıdemini sıfırlama yetkisidir. Ancak kıdem tazminatı hakkını etkilemez.',
    example: 'İşyeri kurallarına sürekli uymayan işçiye kıdem kesme cezası verilebilir.',
    relatedTerms: ['Disiplin Cezası', 'İhtar', 'İş Sözleşmesi'],
  ),
  _LegalTerm(
    title: 'Ücret',
    category: 'İş Hukuku',
    definition: 'İşçinin yaptığı iş karşılığında işverenden hak ettiği para veya ayni değerlerdir. Asgari ücretten az olamaz.',
    example: 'İşçinin maaşı, prim, ikramiye gibi ödemeler ücret kapsamındadır.',
    relatedTerms: ['Asgari Ücret', 'Fazla Çalışma', 'Brüt Ücret'],
  ),
  _LegalTerm(
    title: 'Fazla Çalışma',
    category: 'İş Hukuku',
    definition: 'Kanunda öngörülen haftalık 45 saatlik normal çalışma süresini aşan çalışmalardır. %50 zamlı ücretle ödenir.',
    example: 'Haftalık 50 saat çalışan işçinin 5 saatlik fazla mesaisi %50 zamlı ödenir.',
    relatedTerms: ['Ücret', 'Çalışma Süresi', 'Yıllık İzin'],
  ),
  _LegalTerm(
    title: 'Sendika',
    category: 'İş Hukuku',
    definition: 'İşçilerin veya işverenlerin çalışma ilişkilerinde ortak çıkarlarını korumak ve geliştirmek için kurdukları mesleki kuruluşlardır.',
    example: 'İşçiler sendika kurarak toplu iş sözleşmesi yapabilir ve grev hakkını kullanabilir.',
    relatedTerms: ['Grev', 'Toplu İş Sözleşmesi', 'İşçi Hakları'],
  ),
  _LegalTerm(
    title: 'İptal Davası',
    category: 'İdare Hukuku',
    definition: 'İdari işlemlerin hukuka aykırılığını ileri sürerek iptali için açılan davalardır. İdare mahkemelerinde görülür.',
    example: 'Ruhsat başvurusu reddedilen kişi bu karara karşı iptal davası açabilir.',
    relatedTerms: ['İdari İşlem', 'İdari Yargı', 'Yürütmenin Durdurulması'],
  ),
  _LegalTerm(
    title: 'Tam Yargı Davası',
    category: 'İdare Hukuku',
    definition: 'İdarenin hukuka aykırı eylem ve işlemlerinden kaynaklanan zararların tazmini için açılan davalardır.',
    example: 'Belediyenin açtığı çukurdan düşerek yaralanan kişi tazminat davası açabilir.',
    relatedTerms: ['Kusur Sorumluluğu', 'Tazminat', 'İdari İşlem'],
  ),
  _LegalTerm(
    title: 'İdari Yaptırım',
    category: 'İdare Hukuku',
    definition: 'İdarenin, hukuka aykırı davranışları caydırmak veya cezalandırmak için uyguladığı yaptırımlardır. İdari para cezası, lisans iptali gibi.',
    example: 'Trafik cezası bir idari para cezası yaptırımıdır.',
    relatedTerms: ['İdari Para Cezası', 'Ruhsat İptali', 'Disiplin Cezası'],
  ),
  _LegalTerm(
    title: 'Kamu Görevlisi',
    category: 'İdare Hukuku',
    definition: 'Kamu hukuku rejimine tabi olarak kamusal görev yapan kişilerdir. Memurlar, sözleşmeli personel ve geçici personeli kapsar.',
    example: 'Öğretmen, polis, belediye memuru kamu görevlisidir.',
    relatedTerms: ['Memur', 'Görev', 'Kamu Hizmeti'],
  ),
  _LegalTerm(
    title: 'İcra Takibi',
    category: 'İcra İflas Hukuku',
    definition: 'Alacağını tahsil edemeyen alacaklının devlet aracılığıyla alacağını tahsil etmesini sağlayan yoldur. İlamlı ve ilamsız takip olarak ikiye ayrılır.',
    example: 'Kira borcunu ödemeyen kiracıya icra takibi başlatılabilir.',
    relatedTerms: ['Haciz', 'İcra İflas Kanunu', 'Alacaklı'],
  ),
  _LegalTerm(
    title: 'İflas',
    category: 'İcra İflas Hukuku',
    definition: 'Borçların vade sonunda ödenememesi nedeniyle mahkeme kararıyla borçlunun bütün malvarlığına el konulması ve alacaklılar arasında paylaştırılmasıdır.',
    example: 'Konkordato talebi reddedilen şirket iflas ilan edilebilir.',
    relatedTerms: ['Konkordato', 'Haciz', 'Masa'],
  ),
  _LegalTerm(
    title: 'Haciz',
    category: 'İcra İflas Hukuku',
    definition: 'İcra takibinde borçlunun mal varlığına el konularak satılmasını ve bedelinin alacaklıya ödenmesini sağlayan işlemdir.',
    example: 'Borcunu ödemeyen kişinin hesabına haciz konabilir.',
    relatedTerms: ['İcra Takibi', 'Haczedilmezlik', 'Satış'],
  ),
  _LegalTerm(
    title: 'İhtiyati Haciz',
    category: 'İcra İflas Hukuku',
    definition: 'Alacaklının alacağını güvence altına almak için henüz kesinleşmemiş olsa bile borçlunun mallarına haciz konulmasını talep etmesidir.',
    example: 'Yurt dışına kaçma riski olan borçlunun malları ihtiyati hacze tabi tutulabilir.',
    relatedTerms: ['Haciz', 'Teminat', 'İcra Takibi'],
  ),
];

// English Terms
List<_LegalTerm> _getLegalTermsEn() => const [
  _LegalTerm(
    title: 'Notice Compensation',
    category: 'Labor Law',
    definition: 'Compensation that the employer must pay to the employee in case of termination of the employment contract. The party terminating the employment contract without complying with the notice period is obliged to pay compensation equal to the wages for the notice period.',
    example: 'If an employee who has been working for a company for 5 years is dismissed without just cause, they are entitled to 8 weeks of notice compensation.',
    relatedTerms: ['Severance Pay', 'Employment Contract', 'Termination'],
  ),
  _LegalTerm(
    title: 'Severance Pay',
    category: 'Labor Law',
    definition: 'Compensation that an employee who has worked for at least one year can claim from the employer when the employment contract ends under certain conditions. It is paid at the rate of 30 days\' gross wages for each full year.',
    example: 'An employee retiring after 15 years of service can claim severance pay.',
    relatedTerms: ['Notice Compensation', 'Retirement', 'Employment Contract'],
  ),
  _LegalTerm(
    title: 'Imprisonment',
    category: 'Criminal Law',
    definition: 'A type of punishment involving the deprivation of liberty of a person who has committed a crime. According to the Turkish Criminal Code, there are three types: aggravated life imprisonment, life imprisonment, and fixed-term imprisonment.',
    example: 'The Turkish Criminal Code prescribes imprisonment from 1 to 3 years for intentional injury.',
    relatedTerms: ['Judicial Fine', 'Security Measure', 'Criminal Code'],
  ),
  _LegalTerm(
    title: 'Alimony',
    category: 'Civil Law',
    definition: 'Monetary assistance to be paid by one spouse to the other spouse or children who are economically weaker in case of divorce or separation. Types include contribution alimony, poverty alimony, and interim alimony.',
    example: 'A divorced woman who worked as a homemaker during the marriage and has no income can claim poverty alimony from her ex-spouse.',
    relatedTerms: ['Divorce', 'Custody', 'Property Regime'],
  ),
  _LegalTerm(
    title: 'Limited Company',
    category: 'Commercial Law',
    definition: 'A capital company established under the Commercial Code, with a specified and divided capital, where the liability of the partners is limited to the capital they have invested. It can be established with at least one partner.',
    example: 'Small and medium-sized enterprises are often established as limited companies because the personal assets of the partners are protected.',
    relatedTerms: ['Joint Stock Company', 'Collective Company', 'Commercial Code'],
  ),
  _LegalTerm(
    title: 'Joint Stock Company',
    category: 'Commercial Law',
    definition: 'A capital company with a specified and divided capital, liable only with its assets for its debts. It can issue shares and go public.',
    example: 'Large companies are usually established as joint stock companies and their shares can be traded on the stock exchange.',
    relatedTerms: ['Limited Company', 'Stock Certificate', 'General Assembly'],
  ),
  _LegalTerm(
    title: 'Mortgaged Debt',
    category: 'Civil Law',
    definition: 'A real right established on immovable property or another real right registered in the land registry to secure a certain receivable.',
    example: 'A person taking out a home loan mortgages the house they purchased to the bank.',
    relatedTerms: ['Pledge', 'Immovable Property', 'Real Right'],
  ),
  _LegalTerm(
    title: 'Administrative Judiciary',
    category: 'Administrative Law',
    definition: 'The branch of judiciary where disputes arising from administrative acts and actions are resolved. It consists of administrative courts, regional administrative courts, and the Council of State.',
    example: 'A lawsuit filed by a public official against a salary cut penalty is heard in the administrative judiciary.',
    relatedTerms: ['Council of State', 'Administrative Act', 'Annulment Action'],
  ),
  _LegalTerm(
    title: 'Custody',
    category: 'Civil Law',
    definition: 'The totality of rights and powers to protect, supervise, and represent the person and property of non-adult children. Parents have equal rights and obligations in exercising custody.',
    example: 'Custody can be granted to one of the divorced parents or a decision for joint custody can be made.',
    relatedTerms: ['Alimony', 'Divorce', 'Guardianship'],
  ),
  _LegalTerm(
    title: 'Intentional Injury',
    category: 'Criminal Law',
    definition: 'Defined as an act that causes pain to another person\'s body or causes deterioration of their health or perception ability. If it can be remedied with simple medical intervention, it constitutes simple injury; otherwise, it constitutes aggravated injury.',
    example: 'Breaking someone\'s nose during a fight constitutes the crime of intentional injury.',
    relatedTerms: ['Imprisonment', 'Criminal Code', 'Defense Attorney'],
  ),
  _LegalTerm(
    title: 'Contract',
    category: 'Civil Law',
    definition: 'A legal transaction established by mutual and corresponding declarations of will of two or more parties. It can be written or oral.',
    example: 'There are various types such as lease contract, sales contract, employment contract.',
    relatedTerms: ['Declaration of Will', 'Debt', 'Performance'],
  ),
  _LegalTerm(
    title: 'Statute of Limitations',
    category: 'Civil Law',
    definition: 'The inability to exercise a right or the extinction of a debt due to the passage of a certain period of time. There are different statute of limitations periods for each type of receivable.',
    example: 'A rental claim not collected within the 10-year statute of limitations period expires.',
    relatedTerms: ['Forfeiture', 'Receivable', 'Filing a Lawsuit'],
  ),
  _LegalTerm(
    title: 'Work Accident',
    category: 'Labor Law',
    definition: 'An event that occurs in the workplace or due to the execution of work, causing death or physical or mental harm. It is different from occupational disease.',
    example: 'A construction worker falling from scaffolding and getting injured is a work accident.',
    relatedTerms: ['Occupational Disease', 'Social Security', 'Employer Liability'],
  ),
  _LegalTerm(
    title: 'Criminal Capacity',
    category: 'Criminal Law',
    definition: 'The ability to distinguish and control one\'s behavior, which is necessary for a person to be punished for their actions. Children under 12 years of age do not have criminal capacity.',
    example: 'Even if a 10-year-old child commits a crime, they have no criminal liability.',
    relatedTerms: ['Criminal Code', 'Fault', 'Intent'],
  ),
  _LegalTerm(
    title: 'Non-Attachability',
    category: 'Enforcement Law',
    definition: 'All goods and rights that cannot be attached because they are necessary for the debtor\'s livelihood. Minimum wage, a portion of retirement pension, essential household items cannot be attached.',
    example: 'Goods necessary for the debtor\'s livelihood such as beds, tables, chairs cannot be attached.',
    relatedTerms: ['Attachment', 'Enforcement Proceedings', 'Debtor'],
  ),
  _LegalTerm(
    title: 'Fraud',
    category: 'Criminal Law',
    definition: 'The crime of deceiving someone through fraudulent behavior and providing a benefit to oneself or someone else to the detriment of that person or someone else. It is regulated in Article 157 of the Criminal Code.',
    example: 'Drawing a bank loan by preparing fake documents constitutes the crime of fraud.',
    relatedTerms: ['Deceit', 'Abuse of Trust', 'Forgery'],
  ),
  _LegalTerm(
    title: 'Threat',
    category: 'Criminal Law',
    definition: 'A crime committed by threatening or attributing harm to someone. It aims to disturb the peace and tranquility of the person.',
    example: 'Saying that you will harm someone\'s family constitutes the crime of threat.',
    relatedTerms: ['Insult', 'Blackmail', 'Intimidation'],
  ),
  _LegalTerm(
    title: 'Embezzlement',
    category: 'Criminal Law',
    definition: 'A public official appropriating money or goods in their possession or someone else\'s possession through the convenience provided by their duty.',
    example: 'A municipal treasurer taking money from the cash register for personal use is embezzlement.',
    relatedTerms: ['Abuse of Office', 'Bribery', 'Corruption'],
  ),
  _LegalTerm(
    title: 'Insult',
    category: 'Criminal Law',
    definition: 'It is committed by attributing a concrete act or fact that can injure someone\'s honor, dignity and reputation, or by swearing.',
    example: 'Making heavy insults to someone on social media can constitute the crime of insult.',
    relatedTerms: ['Threat', 'Defamation', 'Personal Rights'],
  ),
  _LegalTerm(
    title: 'Theft',
    category: 'Criminal Law',
    definition: 'Taking a property from where it is without the consent of its possessor. The penalty increases in qualified cases such as at night, in a locked place.',
    example: 'Pocketing goods from a market constitutes the crime of theft.',
    relatedTerms: ['Robbery', 'Damage to Property', 'Possession'],
  ),
  _LegalTerm(
    title: 'Negligent Homicide',
    category: 'Criminal Law',
    definition: 'Causing the death of a person due to violation of the duty of attention and care. Traffic accidents are among the most common examples.',
    example: 'Causing someone\'s death in an accident while driving under the influence of alcohol constitutes this crime.',
    relatedTerms: ['Negligence', 'Intentional Killing', 'Traffic Crimes'],
  ),
  _LegalTerm(
    title: 'Marriage Conditions',
    category: 'Civil Law',
    definition: 'Conditions necessary for a marriage to be valid. Conditions such as being 17 years old, having marriage capacity, absence of marriage prohibition are required.',
    example: 'A person who has reached 16 years of age can marry with the approval of the judge.',
    relatedTerms: ['Engagement', 'Invalidity of Marriage', 'Civil Status'],
  ),
  _LegalTerm(
    title: 'Property Regime',
    category: 'Civil Law',
    definition: 'The legal status that regulates the relationship between the assets of spouses within the marriage union. Participation in acquired property regime is the legal property regime.',
    example: 'In divorce, acquired property is shared equally between the spouses.',
    relatedTerms: ['Divorce', 'Property Division', 'Personal Property'],
  ),
  _LegalTerm(
    title: 'Guardianship',
    category: 'Civil Law',
    definition: 'An institution established to protect the personal and property rights of minors who do not have parents or are deprived of custody and of persons under interdiction.',
    example: 'The court appoints a guardian for a child whose parents have passed away.',
    relatedTerms: ['Custody', 'Minor', 'Trustee'],
  ),
  _LegalTerm(
    title: 'Inheritance',
    category: 'Civil Law',
    definition: 'The transfer of a person\'s assets to heirs upon death. There are two types: legal and designated heirs.',
    example: 'If there is no will, the assets of the deceased person are divided among the legal heirs.',
    relatedTerms: ['Will', 'Reserved Portion', 'Estate'],
  ),
  _LegalTerm(
    title: 'Divorce',
    category: 'Civil Law',
    definition: 'The termination of the marriage union by court decision. It can be by mutual consent or contested. The existence of valid reasons is required.',
    example: 'A divorce lawsuit can be filed for reasons that make it unbearable for the spouses to continue the marriage union.',
    relatedTerms: ['Alimony', 'Custody', 'Compensation'],
  ),
  _LegalTerm(
    title: 'Trade Name',
    category: 'Commercial Law',
    definition: 'The name used by a merchant in their commercial activities. It is registered in the trade registry and protected.',
    example: '"ABC Textile Limited Company" is a trade name.',
    relatedTerms: ['Trade Registry', 'Trademark', 'Commercial Enterprise'],
  ),
  _LegalTerm(
    title: 'Commercial Books',
    category: 'Commercial Law',
    definition: 'Books that the merchant is obliged to record commercial transactions in. The journal and ledger are mandatory.',
    example: 'Every commercial enterprise must record income-expense records in commercial books.',
    relatedTerms: ['Accounting', 'Inventory', 'Balance Sheet'],
  ),
  _LegalTerm(
    title: 'Commercial Enterprise',
    category: 'Commercial Law',
    definition: 'The totality of human resources and capital organized to engage in commercial activity. It can be subject to transfer and usufruct rights.',
    example: 'A market can be transferred together with all its fixtures, stock and personnel.',
    relatedTerms: ['Trade Name', 'Commercial Representative', 'Unfair Competition'],
  ),
  _LegalTerm(
    title: 'Unfair Competition',
    category: 'Commercial Law',
    definition: 'Competitive behaviors that cause damage to competitors or customers by actions contrary to the rule of honesty.',
    example: 'Denigrating a rival company\'s product or making misleading advertising is unfair competition.',
    relatedTerms: ['Trade Secret', 'Trademark', 'Non-Competition Clause'],
  ),
  _LegalTerm(
    title: 'Seniority Reduction Penalty',
    category: 'Labor Law',
    definition: 'The authority granted to the employer to reset the employee\'s seniority due to the employee\'s behavior contrary to disciplinary rules. However, it does not affect the right to severance pay.',
    example: 'A seniority reduction penalty can be given to an employee who constantly fails to comply with workplace rules.',
    relatedTerms: ['Disciplinary Penalty', 'Warning', 'Employment Contract'],
  ),
  _LegalTerm(
    title: 'Wage',
    category: 'Labor Law',
    definition: 'Money or in-kind values that the employee is entitled to from the employer in return for the work done. It cannot be less than the minimum wage.',
    example: 'Payments such as employee salary, premium, bonus are within the scope of wages.',
    relatedTerms: ['Minimum Wage', 'Overtime', 'Gross Wage'],
  ),
  _LegalTerm(
    title: 'Overtime',
    category: 'Labor Law',
    definition: 'Working that exceeds the normal working time of 45 hours per week stipulated by law. It is paid with 50% premium.',
    example: 'An employee working 50 hours per week has 5 hours of overtime paid with a 50% premium.',
    relatedTerms: ['Wage', 'Working Time', 'Annual Leave'],
  ),
  _LegalTerm(
    title: 'Union',
    category: 'Labor Law',
    definition: 'Professional organizations established by workers or employers to protect and develop their common interests in working relationships.',
    example: 'Workers can make collective labor agreements and exercise the right to strike by establishing a union.',
    relatedTerms: ['Strike', 'Collective Labor Agreement', 'Worker Rights'],
  ),
  _LegalTerm(
    title: 'Annulment Action',
    category: 'Administrative Law',
    definition: 'Lawsuits filed for the annulment of administrative acts by claiming their illegality. They are heard in administrative courts.',
    example: 'A person whose license application is rejected can file an annulment action against this decision.',
    relatedTerms: ['Administrative Act', 'Administrative Judiciary', 'Stay of Execution'],
  ),
  _LegalTerm(
    title: 'Full Remedy Action',
    category: 'Administrative Law',
    definition: 'Lawsuits filed for compensation for damages arising from the administration\'s illegal actions and acts.',
    example: 'A person who is injured by falling into a hole opened by the municipality can file a compensation lawsuit.',
    relatedTerms: ['Fault Liability', 'Compensation', 'Administrative Act'],
  ),
  _LegalTerm(
    title: 'Administrative Sanction',
    category: 'Administrative Law',
    definition: 'Sanctions applied by the administration to deter or punish illegal behaviors. Such as administrative fines, license cancellation.',
    example: 'A traffic fine is an administrative monetary penalty sanction.',
    relatedTerms: ['Administrative Fine', 'License Cancellation', 'Disciplinary Penalty'],
  ),
  _LegalTerm(
    title: 'Public Official',
    category: 'Administrative Law',
    definition: 'Persons who perform public duties subject to public law regime. It includes civil servants, contract personnel and temporary personnel.',
    example: 'Teacher, police, municipality officer are public officials.',
    relatedTerms: ['Civil Servant', 'Duty', 'Public Service'],
  ),
  _LegalTerm(
    title: 'Enforcement Proceedings',
    category: 'Enforcement Law',
    definition: 'A way for the creditor who cannot collect their receivable to collect it through the state. It is divided into two as enforcement with and without judgment.',
    example: 'Enforcement proceedings can be initiated against a tenant who does not pay rent.',
    relatedTerms: ['Attachment', 'Enforcement and Bankruptcy Code', 'Creditor'],
  ),
  _LegalTerm(
    title: 'Bankruptcy',
    category: 'Enforcement Law',
    definition: 'By court order, all of the debtor\'s assets are seized and distributed among the creditors because the debts cannot be paid at maturity.',
    example: 'A company whose concordat request is rejected can be declared bankrupt.',
    relatedTerms: ['Concordat', 'Attachment', 'Estate'],
  ),
  _LegalTerm(
    title: 'Attachment',
    category: 'Enforcement Law',
    definition: 'An operation that enables the seizure of the debtor\'s assets in enforcement proceedings, their sale and payment of the proceeds to the creditor.',
    example: 'The account of a person who does not pay their debt can be attached.',
    relatedTerms: ['Enforcement Proceedings', 'Non-Attachability', 'Sale'],
  ),
  _LegalTerm(
    title: 'Precautionary Attachment',
    category: 'Enforcement Law',
    definition: 'The creditor\'s request to attach the debtor\'s assets to secure their receivable even if it has not yet been finalized.',
    example: 'The assets of a debtor at risk of fleeing abroad can be subject to precautionary attachment.',
    relatedTerms: ['Attachment', 'Guarantee', 'Enforcement Proceedings'],
  ),
];

class _CategoryData {
  final String label;
  final String key;
  
  _CategoryData(this.label, this.key);
}
