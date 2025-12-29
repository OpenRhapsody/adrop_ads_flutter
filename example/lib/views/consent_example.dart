import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

/// Consent Manager Example
///
/// This example demonstrates how to use AdropConsentManager to handle
/// user consent for GDPR, CCPA, and other privacy regulations.
class ConsentExample extends StatefulWidget {
  const ConsentExample({super.key});

  @override
  State<ConsentExample> createState() => _ConsentExampleState();
}

class _ConsentExampleState extends State<ConsentExample> {
  String _statusText = 'Not checked';
  String _resultText = '';
  bool _isLoading = false;
  AdropConsentDebugGeography _selectedGeography =
      AdropConsentDebugGeography.disabled;

  /// Request consent info update and show consent form if required
  Future<void> _requestConsentInfoUpdate() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Requesting...';
    });

    Adrop.consentManager.requestConsentInfoUpdate((result) {
      setState(() {
        _isLoading = false;
        _resultText = '''
Status: ${result.status.name}
Can Request Ads: ${result.canRequestAds}
Can Show Personalized Ads: ${result.canShowPersonalizedAds}
Error: ${result.error ?? 'None'}
''';
      });
    });
  }

  /// Get current consent status
  Future<void> _getConsentStatus() async {
    final status = await Adrop.consentManager.getConsentStatus();
    setState(() {
      _statusText = status.name;
    });
  }

  /// Check if ads can be requested
  Future<void> _checkCanRequestAds() async {
    final canRequest = await Adrop.consentManager.canRequestAds();
    setState(() {
      _resultText = 'Can Request Ads: $canRequest';
    });
  }

  /// Reset consent (for testing)
  Future<void> _resetConsent() async {
    await Adrop.consentManager.reset();
    setState(() {
      _statusText = 'Reset completed';
      _resultText = '';
    });
  }

  /// Apply debug settings
  Future<void> _applyDebugSettings() async {
    await Adrop.consentManager.setDebugSettings(_selectedGeography);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug settings applied: ${_selectedGeography.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Consent Example'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Section
              const Text(
                'Current Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusText),
              ),
              const SizedBox(height: 16),

              // Actions Section
              const Text(
                'Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _requestConsentInfoUpdate,
                    child: const Text('Request Consent Update'),
                  ),
                  ElevatedButton(
                    onPressed: _getConsentStatus,
                    child: const Text('Get Status'),
                  ),
                  ElevatedButton(
                    onPressed: _checkCanRequestAds,
                    child: const Text('Can Request Ads?'),
                  ),
                  ElevatedButton(
                    onPressed: _resetConsent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Result Section
              const Text(
                'Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(_resultText.isEmpty ? 'No result yet' : _resultText),
              ),
              const SizedBox(height: 24),

              // Debug Settings Section
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Debug Settings (Testing Only)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: Debug settings only work when AdropAdsBackfill is installed.\nDevice ID is automatically applied.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Geography Selection
              const Text('Debug Geography:'),
              const SizedBox(height: 4),
              DropdownButton<AdropConsentDebugGeography>(
                value: _selectedGeography,
                isExpanded: true,
                items: AdropConsentDebugGeography.values.map((geography) {
                  return DropdownMenuItem(
                    value: geography,
                    child: Text(_getGeographyDescription(geography)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGeography = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _applyDebugSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[100],
                ),
                child: const Text('Apply Debug Settings'),
              ),
              const SizedBox(height: 24),

              // Info Section
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Consent Status Values',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('unknown', 'Not yet determined'),
              _buildInfoRow('required', 'Consent is required (show popup)'),
              _buildInfoRow('notRequired', 'Consent not required (region)'),
              _buildInfoRow('obtained', 'Consent has been obtained'),
            ],
          ),
        ),
      ),
    );
  }

  String _getGeographyDescription(AdropConsentDebugGeography geography) {
    switch (geography) {
      case AdropConsentDebugGeography.disabled:
        return 'Disabled (Use actual location)';
      case AdropConsentDebugGeography.eea:
        return 'EEA (European Economic Area - GDPR)';
      case AdropConsentDebugGeography.regulatedUSState:
        return 'Regulated US State (CCPA)';
      case AdropConsentDebugGeography.other:
        return 'Other (No regulations)';
    }
  }

  Widget _buildInfoRow(String status, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              status,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
