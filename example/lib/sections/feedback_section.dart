// Feedback demo - BcToastQueue, BcNotification, BcResult, BcEmpty,
// BcBackdrop, BcLoadingOverlay, BcTour, BcInplace.
library feedback_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class FeedbackSection extends StatefulWidget {
  const FeedbackSection({super.key});

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  late final BcToastQueueController _toastController;
  final bool _notifInfo = true;
  final bool _notifSuccess = true;
  bool _tourOpen = false;
  int _tourStep = 0;
  String _inplaceValue = 'Click to edit';

  @override
  void initState() {
    super.initState();
    _toastController = BcToastQueueController();
  }

  @override
  void dispose() {
    _toastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Feedback',
          subtitle: 'Toasts, notifications, result states, tours, and inline editing.',
        ),

        // -- BcToastQueue --
        DemoCard(
          title: 'BcToastQueue',
          description: 'Stacked toast notifications with auto-dismiss.',
          child: BcYStack(
            gap: 12,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => _toastController.info('Info toast',
                        description: 'Something happened.'),
                    child: const Text('Info'),
                  ),
                  ElevatedButton(
                    onPressed: () => _toastController.success('Saved!',
                        description: 'Your changes are stored.'),
                    child: const Text('Success'),
                  ),
                  ElevatedButton(
                    onPressed: () => _toastController.warning('Warning',
                        description: 'Check your input.'),
                    child: const Text('Warning'),
                  ),
                  ElevatedButton(
                    onPressed: () => _toastController.error('Error',
                        description: 'Operation failed.'),
                    style: ElevatedButton.styleFrom(backgroundColor: BcTheme.destructive, foregroundColor: Colors.white),
                    child: const Text('Error'),
                  ),
                ],
              ),
              SizedBox(
                height: 120,
                child: BcToastQueue(
                  controller: _toastController,
                  position: BcToastQueuePosition.topRight,
                ),
              ),
            ],
          ),
        ),

        // -- BcNotification --
        DemoCard(
          title: 'BcNotification',
          description: 'Inline banner notifications by severity.',
          child: BcYStack(
            gap: 8,
            children: [
              BcNotification(
                open: _notifInfo,
                severity: BcNotificationSeverity.info,
                title: 'Heads up',
                description: 'A new version is available.',
              ),
              BcNotification(
                open: _notifSuccess,
                severity: BcNotificationSeverity.success,
                title: 'Success',
                description: 'Your profile was updated.',
              ),
              const BcNotification(
                open: true,
                severity: BcNotificationSeverity.warning,
                title: 'Warning',
                description: 'Your subscription expires soon.',
              ),
              const BcNotification(
                open: true,
                severity: BcNotificationSeverity.danger,
                title: 'Error',
                description: 'Could not connect to the server.',
              ),
            ],
          ),
        ),

        // -- BcResult --
        DemoCard(
          title: 'BcResult',
          description: 'Status result pages for success, error, warning, info.',
          child: BcXStack(
            gap: 12,
            wrap: WrapAlignment.start,
            crossAxisAlignment: BcXStackAlign.start,
            children: [
              _resultBox(BcResult(
                status: BcResultStatus.success,
                title: 'Success',
                subtitle: 'Operation completed.',
              )),
              _resultBox(BcResult(
                status: BcResultStatus.error,
                title: 'Failed',
                subtitle: 'Please retry.',
              )),
              _resultBox(BcResult(
                status: BcResultStatus.warning,
                title: 'Pending',
                subtitle: 'Awaiting review.',
              )),
              _resultBox(BcResult(
                status: BcResultStatus.info,
                title: 'Info',
                subtitle: 'For your awareness.',
              )),
            ],
          ),
        ),

        // -- BcEmpty --
        DemoCard(
          title: 'BcEmpty',
          description: 'Empty state placeholder with action.',
          child: BcEmpty(
            icon: const Icon(Icons.inbox_outlined, size: 48, color: BcTheme.mutedForeground),
            message: 'No items yet',
            action: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
          ),
        ),

        // -- BcTour --
        DemoCard(
          title: 'BcTour',
          description: 'Guided tour overlay that highlights target widgets.',
          child: BcYStack(
            gap: 8,
            children: [
              ElevatedButton(
                onPressed: () => setState(() {
                  _tourOpen = true;
                  _tourStep = 0;
                }),
                child: const Text('Start Tour'),
              ),
              BcTour(
                open: _tourOpen,
                step: _tourStep,
                steps: const [
                  BcTourStep(
                      title: 'Welcome',
                      description: 'This is the first step of the tour.'),
                  BcTourStep(
                      title: 'Explore',
                      description: 'Here you can explore features.'),
                  BcTourStep(
                      title: 'Finish',
                      description: 'You are all set!'),
                ],
                onStepChange: (step, _) => setState(() => _tourStep = step),
                onFinish: (_) => setState(() => _tourOpen = false),
                onSkip: (_) => setState(() => _tourOpen = false),
              ),
            ],
          ),
        ),

        // -- BcInplace --
        DemoCard(
          title: 'BcInplace',
          description: 'Inline editable text. Click to edit, Enter to save.',
          child: BcInplace(
            value: _inplaceValue,
            placeholder: 'Type something...',
            withButtons: true,
            onChange: (v, _) => setState(() => _inplaceValue = v),
          ),
        ),

        // -- BcAlert --
        DemoCard(
          title: 'BcAlert',
          description: 'Inline alert banner with 4 severity variants and dismissible control.',
          child: BcYStack(
            gap: 8,
            children: [
              BcAlert(
                severity: BcAlertSeverity.info,
                title: 'Information',
                description: 'This is an informational alert.',
              ),
              BcAlert(
                severity: BcAlertSeverity.success,
                title: 'Success',
                description: 'Operation completed successfully.',
              ),
              BcAlert(
                severity: BcAlertSeverity.warning,
                title: 'Warning',
                description: 'Please review this warning.',
                dismissible: true,
              ),
              BcAlert(
                severity: BcAlertSeverity.error,
                title: 'Error',
                description: 'Something went wrong.',
                dismissible: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resultBox(BcResult result) {
    return SizedBox(
      width: 180,
      child: BcBox(
        padding: 16,
        border: true,
        borderRadius: BcTheme.radius,
        backgroundColor: BcBoxColorToken.card,
        child: result,
      ),
    );
  }
}