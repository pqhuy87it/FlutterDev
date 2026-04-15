import 'package:flutter/material.dart';
import 'app_debug_logger.dart';

class LogConsoleViewer extends StatefulWidget {
  const LogConsoleViewer({super.key});

  @override
  State<LogConsoleViewer> createState() => _LogConsoleViewerState();
}

class _LogConsoleViewerState extends State<LogConsoleViewer> {
  bool _isVisible = false;
  EventType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    // Hidden state
    if (!_isVisible) {
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.redAccent.withOpacity(0.8),
              onPressed: () => setState(() => _isVisible = true),
              child: const Icon(Icons.bug_report, size: 20),
            ),
          ),
        ),
      );
    }

    // Display (Console)
    return SizedBox(
      height: 350,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: Colors.black87,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                // --- TOOLBAR ---
                _buildToolbarSection(),
                // ---------------

                // --- LIST LOG ---
                _buildLogListSection(),
                // ----------------
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarSection() {
    return Container(
      height: 48,
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Text(
            "LOG TYPE",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),

          const SizedBox(width: 10),

          // Dropdown Filter
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<EventType?>(
                  isExpanded: true,
                  value: _selectedFilter,
                  dropdownColor: Colors.grey[850],
                  icon: const Icon(
                    Icons.filter_list,
                    size: 16,
                    color: Colors.white70,
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  isDense: true,
                  alignment: Alignment.centerLeft,
                  hint: const Text(
                    "All Types",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(
                        "All Types",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...EventType.values.map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            Text(e.emoji),
                            const SizedBox(width: 6),
                            Text(e.name.toUpperCase()),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedFilter = val),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),
          // Clear log button
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.white70,
            ),
            tooltip: "Clear",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => AppDebugLogger.instance.clear(),
          ),
          const SizedBox(width: 12),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, size: 22, color: Colors.white),
            tooltip: "Close",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _isVisible = false),
          ),
        ],
      ),
    );
  }

  Widget _buildLogListSection() {
    return Expanded(
      child: ValueListenableBuilder<List<LogModel>>(
        valueListenable: AppDebugLogger.instance.logsNotifier,
        builder: (context, logs, child) {
          final filteredLogs = _selectedFilter == null
              ? logs
              : logs.where((log) => log.event == _selectedFilter).toList();

          if (filteredLogs.isEmpty) {
            return const Center(
              child: Text("No logs", style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: filteredLogs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SelectableText.rich(
                  TextSpan(
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                    children: [
                      TextSpan(
                        text: "[${log.timestamp}] ",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      TextSpan(text: "${log.event.emoji} "),
                      TextSpan(
                        text: log.message,
                        style: TextStyle(color: _getLogColor(log.event)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getLogColor(EventType type) {
    switch (type) {
      case EventType.error:
        return Colors.redAccent;
      case EventType.warning:
        return Colors.orangeAccent;
      case EventType.info:
        return Colors.lightBlueAccent;
      case EventType.debug:
        return Colors.white;
      default:
        return Colors.grey;
    }
  }
}
