import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/print_order.dart';
import '../../../providers/print_order_provider.dart';
import '../../../routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/info_row.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_chip.dart';

class PrintOrdersScreen extends StatefulWidget {
  const PrintOrdersScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PrintOrdersScreen> createState() => _PrintOrdersScreenState();
}

class _PrintOrdersScreenState extends State<PrintOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final PrintOrderProvider p = context.read<PrintOrderProvider>();
      if (p.orders.isEmpty) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final PrintOrderProvider provider = context.watch<PrintOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Printing'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(Routes.newPrintOrder),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New order'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          const OfflineBanner(),
          Expanded(child: _body(context, provider)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, PrintOrderProvider provider) {
    if (provider.loading && provider.orders.isEmpty) {
      return const SkeletonList(count: 3);
    }
    if (provider.error != null && provider.orders.isEmpty) {
      return ErrorView(message: provider.error!, onRetry: () => provider.load());
    }
    if (provider.orders.isEmpty) {
      return EmptyState(
        icon: Icons.print_outlined,
        title: 'No print orders yet',
        message:
            'Documents, posters, banners, business cards and photos - submit '
            'an order and track it here.',
        actionLabel: 'Create an order',
        onAction: () => Navigator.of(context).pushNamed(Routes.newPrintOrder),
      );
    }

    final List<PrintOrder> active = provider.active;
    final List<PrintOrder> history = provider.history;

    return RefreshIndicator(
      onRefresh: () => provider.load(refresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
        children: <Widget>[
          if (active.isNotEmpty) ...<Widget>[
            _label(context, 'In the queue'),
            ...active.map((PrintOrder o) => _OrderCard(order: o)),
            const SizedBox(height: 18),
          ],
          if (history.isNotEmpty) ...<Widget>[
            _label(context, 'History'),
            ...history.map((PrintOrder o) => _OrderCard(order: o)),
          ],
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: context.mutedColor,
          ),
        ),
      );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PrintOrder order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color:
                      AppColors.softBg(AppColors.peach, dark: context.isDark),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 19,
                  color: AppColors.peach,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.serviceType.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.inkColor,
                      ),
                    ),
                    Text(
                      Fmt.relative(order.createdAt),
                      style:
                          TextStyle(fontSize: 12, color: context.mutedColor),
                    ),
                  ],
                ),
              ),
              StatusChip.order(order.status),
            ],
          ),
          const SizedBox(height: 10),
          if ((order.description ?? '').isNotEmpty)
            InfoRow(label: 'Details', value: order.description!),
          InfoRow(label: 'Copies', value: '${order.copies}'),
          InfoRow(
            label: 'Colour',
            value: order.color ? 'Full colour' : 'Black & white',
          ),
          InfoRow(
            label: 'Estimated price',
            value: Fmt.price(order.estimatedPrice),
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
