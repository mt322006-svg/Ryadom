import 'package:flutter/material.dart';

import '../../requests/domain/help_request.dart';
import '../../requests/domain/request_preview.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Рядом',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Помощь рядом,\nкогда она нужна сейчас',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Первый экран MVP держит фокус на скорости, понятности и человеческом отклике.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const _PrimaryActions(),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Рядом', actionLabel: 'Радиус 1.2 км'),
            const SizedBox(height: 12),
            ...sampleRequests.map(_RequestCard.new),
            const SizedBox(height: 24),
            const _QuickOverview(),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Мои запросы', actionLabel: 'Смотреть все'),
            const SizedBox(height: 12),
            const _OwnRequestCard(),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavigation(),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ActionCard(
          title: 'Нужна помощь',
          subtitle: 'Создать запрос за минуту',
          icon: Icons.campaign_rounded,
          accent: Color(0xFF2F6B5F),
          alignRight: false,
        ),
        SizedBox(height: 12),
        _ActionCard(
          title: 'Могу помочь',
          subtitle: 'Открыть ближайшие просьбы',
          icon: Icons.volunteer_activism_rounded,
          accent: Color(0xFFC97C5D),
          alignRight: true,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.alignRight,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            if (alignRight)
              Expanded(
                child: _ActionText(title: title, subtitle: subtitle),
              ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accent, size: 28),
            ),
            if (!alignRight) const SizedBox(width: 16),
            if (!alignRight)
              Expanded(
                child: _ActionText(title: title, subtitle: subtitle),
              ),
            if (alignRight) const SizedBox(width: 16),
            Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.headlineSmall)),
        Text(
          actionLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard(this.request);

  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MetaChip(
                    label: _compensationLabel(request.compensation),
                    color: request.compensation == RequestCompensation.free
                        ? const Color(0xFF2F6B5F)
                        : const Color(0xFFC97C5D),
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    label: _urgencyLabel(request.urgency),
                    color: _urgencyColor(request.urgency),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(request.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(request.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.areaLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.timeLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _QuickOverview extends StatelessWidget {
  const _QuickOverview();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _OverviewCard(
            value: '12',
            label: 'активных запросов',
            color: Color(0xFF2F6B5F),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            value: '7 мин',
            label: 'средний отклик',
            color: Color(0xFFC97C5D),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(color: color),
            ),
            const SizedBox(height: 6),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _OwnRequestCard extends StatelessWidget {
  const _OwnRequestCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _MetaChip(label: 'in_progress', color: Color(0xFF2F6B5F)),
                SizedBox(width: 8),
                _MetaChip(label: '1 помощник', color: Color(0xFF7B6A58)),
              ],
            ),
            const SizedBox(height: 14),
            Text('Помочь заменить лампу', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Откликнулся человек в 600 метрах. Следующий шаг MVP: открыть чат и подтверждение встречи.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationBar(
      height: 72,
      backgroundColor: const Color(0xFFFFFBF5),
      indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.near_me_outlined),
          selectedIcon: Icon(Icons.near_me_rounded),
          label: 'Рядом',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: 'Запросы',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Профиль',
        ),
      ],
    );
  }
}

String _compensationLabel(RequestCompensation compensation) {
  switch (compensation) {
    case RequestCompensation.free:
      return 'Бесплатно';
    case RequestCompensation.paid:
      return 'Платно';
  }
}

String _urgencyLabel(RequestUrgency urgency) {
  switch (urgency) {
    case RequestUrgency.low:
      return 'Спокойно';
    case RequestUrgency.normal:
      return 'Сегодня';
    case RequestUrgency.urgent:
      return 'Срочно';
  }
}

Color _urgencyColor(RequestUrgency urgency) {
  switch (urgency) {
    case RequestUrgency.low:
      return const Color(0xFF7B6A58);
    case RequestUrgency.normal:
      return const Color(0xFF2F6B5F);
    case RequestUrgency.urgent:
      return const Color(0xFFB6543A);
  }
}
