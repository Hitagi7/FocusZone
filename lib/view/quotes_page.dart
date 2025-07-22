import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({Key? key}) : super(key: key);

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String? _quote;
  String? _author;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Check connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _error = 'No internet connection. Please connect to the internet.';
        _loading = false;
        _quote = null;
        _author = null;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://corsproxy.io/?https://zenquotes.io/api/random'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _quote = data[0]['q'];
          _author = data[0]['a'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load quote.';
          _loading = false;
          _quote = null;
          _author = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
        _quote = null;
        _author = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.format_quote, color: Colors.white, size: 48),
              const SizedBox(height: 24),
              if (_loading)
                const CircularProgressIndicator(color: Colors.white)
              else if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                )
              else if (_quote != null)
                Column(
                  children: [
                    Text(
                      '"$_quote"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Noto Sans Display',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _author != null ? '- $_author' : '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Noto Sans Display',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loading ? null : _fetchQuote,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'New Quote',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
