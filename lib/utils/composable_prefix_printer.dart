import 'package:logger/logger.dart';

class ComposablePrefixPrinter extends LogPrinter {
  final LogPrinter printer;
  final LogPrinter errorPrinter;
  final String prefix;

  ComposablePrefixPrinter({
    LogPrinter? printer,
    LogPrinter? errorPrinter,
    required this.prefix,
  }) : printer = printer ?? SimplePrinter(),
       errorPrinter = errorPrinter ?? PrettyPrinter();

  @override
  List<String> log(LogEvent event) {
    final isError = event.level == Level.error || event.level == Level.fatal;
    final activePrinter = isError ? errorPrinter : printer;

    final logs = activePrinter.log(event);
    return logs.map((line) => '[$prefix] $line').toList();
  }
}
