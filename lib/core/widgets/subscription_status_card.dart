import 'package:flutter/material.dart';
import '../auth/subscription_access.dart';

class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({super.key, required this.profile});
  final Map<String, dynamic>? profile;

  String? _date(String? raw) {
    final date = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    if (date == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final access = SubscriptionAccess.fromProfile(profile);
    final color = access.state == 'activa'
        ? Colors.greenAccent
        : Colors.orangeAccent;
    final end = _date(access.endDate);
    final grace = _date(access.graceEnd);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            access.canOperate ? Icons.info_outline : Icons.lock_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  access.title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  access.description(
                    isOwner: profile?['puede_gestionar_cuenta'] == true,
                  ),
                  style: TextStyle(color: scheme.onSurface),
                ),
                if (end != null)
                  Text(
                    'Vencimiento: $end',
                    style: TextStyle(color: scheme.onSurface),
                  ),
                if (grace != null &&
                    (access.state == 'en_gracia' || access.state == 'vencida'))
                  Text(
                    'Fin de la gracia: $grace',
                    style: TextStyle(color: scheme.onSurface),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
