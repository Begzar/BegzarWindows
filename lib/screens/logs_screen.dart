import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:iconsax/iconsax.dart';

class LogsScreen extends StatefulWidget {
  final ValueNotifier<String> logs;
  final ValueNotifier<Locale> languageNotifier;

  const LogsScreen({
    Key? key,
    required this.logs,
    required this.languageNotifier,
  }) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  Map<String, bool> filters = {
    'error': true,
    'warnings': true,
    'debugging': true,
    'full_info': true,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    setState(() {
      _showScrollToTop = _scrollController.offset > 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: widget.languageNotifier,
      builder: (context, locale, child) {
        return Scaffold(
          backgroundColor: const Color(0xff192028),
          appBar: AppBar(
            backgroundColor: const Color(0xff192028),
            elevation: 0,
            title: Text(
              'logs'.tr(),
              style: const TextStyle(
                fontFamily: 'sb',
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Iconsax.copy, size: 22),
                onPressed: () => _copyLogs(context),
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, size: 22),
                onPressed: () => _clearLogs(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: _showScrollToTop ? FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF2A2A2A),
            child: const Icon(Icons.arrow_upward, size: 20),
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
          ) : null,
          body: Column(
            children: [
              _buildLogTypeFilters(),
              Expanded(
                child: _buildLogsContent(),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLogTypeFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('error'.tr(), Colors.red[400]!, 'error'),
          _buildFilterChip('warnings'.tr(), Colors.orange[400]!, 'warnings'),
          _buildFilterChip('debugging'.tr(), Colors.blue[400]!, 'debugging'),
          _buildFilterChip('full_info'.tr(), Colors.green[400]!, 'full_info'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, String filterKey) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: filters[filterKey]! ? color : Colors.grey[400],
            fontSize: 13,
            fontFamily: 'sm',
          ),
        ),
        selected: filters[filterKey]!,
        onSelected: (bool value) {
          setState(() {
            filters[filterKey] = value;
          });
        },
        backgroundColor: const Color(0xFF2A2A2A),
        selectedColor: color.withOpacity(0.15),
        checkmarkColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: filters[filterKey]! ? color.withOpacity(0.5) : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildLogsContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: widget.logs,
        builder: (context, logsValue, _) {
          final List<String> filteredLogs = logsValue
              .split('\n')
              .where((line) {
                if (line.trim().isEmpty) return false;
                if (!filters['error']! && (line.contains('ERROR') || line.contains('error') || line.contains('FATAL') || line.contains('fatal'))) return false;
                if (!filters['warnings']! && (line.contains('WARN') || line.contains('warn'))) return false;
                if (!filters['debugging']! && (line.contains('DEBUG') || line.contains('debug'))) return false;
                if (!filters['full_info']! && (line.contains('INFO') || line.contains('info'))) return false;
                return true;
              })
              .toList();

          return SingleChildScrollView(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(16),
            child: filteredLogs.isEmpty 
                ? Center(
                    child: Text(
                      'No logs available',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontFamily: 'sm',
                      ),
                    ),
                  )
                : SelectableText.rich(
                    TextSpan(
                      children: filteredLogs.map((line) {
                        Color textColor = Colors.grey[300]!;
                        double fontSize = 12.0;
                        FontWeight fontWeight = FontWeight.normal;

                        if (line.contains('ERROR') || line.contains('error') || line.contains('FATAL') || line.contains('fatal')) {
                          textColor = Colors.red[400]!;
                          fontWeight = FontWeight.bold;
                        } else if (line.contains('WARN') || line.contains('warn')) {
                          textColor = Colors.orange[400]!;
                        } else if (line.contains('INFO') || line.contains('info')) {
                          textColor = Colors.green[400]!;
                        } else if (line.contains('DEBUG') || line.contains('debug')) {
                          textColor = Colors.blue[400]!;
                        }

                        return TextSpan(
                          text: '$line\n',
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontSize: fontSize,
                            height: 1.5,
                            fontWeight: fontWeight,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _copyLogs(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.logs.value));
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      desc: 'logs_copied'.tr(),
      width: 400,
      btnOkText: 'close'.tr(),
      btnOkOnPress: () {},
    ).show();
  }

  void _clearLogs(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: 'clear_logs'.tr(),
      desc: 'clear_logs_confirm'.tr(),
      width: 400,
      btnCancelText: 'close'.tr(),
      btnOkText: 'clear_logs'.tr(),
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        widget.logs.value = '';
      },
    ).show();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 