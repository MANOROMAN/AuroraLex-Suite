import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/i18n/app_localizations.dart';
import '../data/events_service.dart';

class CalendarTab extends HookConsumerWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = useState(DateTime.now());
    final focusedDay = useState(DateTime.now());
    final eventsAsync = ref.watch(userEventsProvider);
    final eventsService = ref.watch(eventsServiceProvider);
    final l10n = AppLocalizations.of(context);
    
    return eventsAsync.when(
      data: (allEvents) {
        // Seçili güne ait etkinlikler
        final selectedDayEvents = allEvents.where((event) {
          return isSameDay(event.date, selectedDay.value);
        }).toList();

        // Etkinliği olan günleri işaretle
        final eventDates = allEvents.map((e) => e.date).toSet();

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.calendar,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddEventDialog(
                      context,
                      eventsService,
                      selectedDay.value,
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addEvent),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1173d4),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFF1a2633),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TableCalendar(
                  locale: l10n.localeName, // Dil ayarı
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedDay.value,
                  selectedDayPredicate: (day) =>
                      isSameDay(selectedDay.value, day),
                  onDaySelected: (selected, focused) {
                    selectedDay.value = selected;
                    focusedDay.value = focused;
                  },
                  calendarFormat: CalendarFormat.month,
                  // Etkinliği olan günleri işaretle
                  eventLoader: (day) {
                    return eventDates.where((d) => isSameDay(d, day)).toList();
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return null;
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF59FFD5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.grey.shade400),
                    weekendStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF1173d4).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF1173d4),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.white),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              selectedDayEvents.isEmpty
                  ? l10n.noEvents
                  : isSameDay(selectedDay.value, DateTime.now())
                      ? l10n.todaysEvents
                      : l10n.selectedDayEvents,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (selectedDayEvents.isEmpty)
              Card(
                color: const Color(0xFF1a2633),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noEventsOnDate,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...selectedDayEvents.map(
                (event) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color(0xFF1a2633),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Color(event.color).withOpacity(0.2),
                      child: Icon(Icons.event, color: Color(event.color)),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${event.time}  •  ${event.description}',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade500,
                      ),
                      color: const Color(0xFF1a2633),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                event.reminderEnabled
                                    ? Icons.notifications_off
                                    : Icons.notifications_active,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                event.reminderEnabled
                                    ? l10n.reminderOn
                                    : l10n.reminderOff,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await eventsService.updateEvent(
                              eventId: event.id,
                              reminderEnabled: !event.reminderEnabled,
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.edit,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _showEditEventDialog(
                                context,
                                eventsService,
                                event,
                              );
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _showDeleteConfirmation(
                                context,
                                eventsService,
                                event.id,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1173d4),
        ),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Etkinlikler yüklenirken hata oluştu',
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  void _showAddEventDialog(
    BuildContext context,
    EventsService eventsService,
    DateTime selectedDate,
  ) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    // Parse existing time
    TimeOfDay selectedTime = TimeOfDay.now();
    
    int selectedColor = 0xFF1173d4;

    final colorOptions = [
      0xFF1173d4, // Mavi
      0xFF59FFD5, // Turkuaz
      0xFF4CAF50, // Yeşil
      0xFFFF6B6B, // Kırmızı
      0xFFFFE66D, // Sarı
      0xFFA8DADC, // Açık mavi
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1a2633),
          title: Text(
            l10n.newEvent,
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.eventTitle,
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1173d4)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1173d4)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF1173d4),
                              onPrimary: Colors.white,
                              surface: Color(0xFF1a2633),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.eventTime,
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1173d4)),
                      ),
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: Color(0xFF1173d4),
                      ),
                    ),
                    child: Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Renk Seç',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: colorOptions.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen bir başlık girin'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await eventsService.addEvent(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  date: selectedDate,
                  time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  color: selectedColor,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.eventAdded),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                }
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

  void _showEditEventDialog(
    BuildContext context,
    EventsService eventsService,
    CalendarEvent event,
  ) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController(text: event.title);
    final descriptionController = TextEditingController(text: event.description);
    
    // Parse existing time
    final timeParts = event.time.split(':');
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 9,
      minute: int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
    );
    
    int selectedColor = event.color;

    final colorOptions = [
      0xFF1173d4,
      0xFF59FFD5,
      0xFF4CAF50,
      0xFFFF6B6B,
      0xFFFFE66D,
      0xFFA8DADC,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1a2633),
          title: const Text(
            'Etkinliği Düzenle',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1173d4)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1173d4)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF1173d4),
                              onPrimary: Colors.white,
                              surface: Color(0xFF1a2633),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.eventTime,
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1173d4)),
                      ),
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: Color(0xFF1173d4),
                      ),
                    ),
                    child: Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Renk Seç',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: colorOptions.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen bir başlık girin'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await eventsService.updateEvent(
                  eventId: event.id,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  color: selectedColor,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Etkinlik güncellendi'),
                      backgroundColor: Color(0xFF4CAF50),
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
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    EventsService eventsService,
    String eventId,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a2633),
        title: const Text(
          'Etkinliği Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu etkinliği silmek istediğinizden emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await eventsService.deleteEvent(eventId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.eventDeleted),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

