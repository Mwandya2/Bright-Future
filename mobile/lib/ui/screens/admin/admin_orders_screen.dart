import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/print_order.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/info_row.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_chip.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadOrders();
    });
  }

  Future<void> _changeStatus(PrintOrder order) async {
    final OrderStatus? status = await showModalBottomSheet<OrderStatus>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Update order status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sheetContext.inkColor,
                ),
              ),
            ),
            ...OrderStatusX.all.map(
              (OrderStatus s) => ListTile(
                leading: Icon(
                  s == order.status
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: s == order.status
                      ? AppColors.primary
                      : sheetContext.mutedColor,
                ),
                title: Text(s.label),
                onTap: () => Navigator.of(sheetContext).pop(s),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (status == null || status == order.status || !mounted) return;
    final String? error =
        await context.read<AdminProvider>().setOrderStatus(order.id, status);
    if (!mounted) return;
    if (error == null) {
      AppSnack.success(context, 'Order marked ${status.label.toLowerCase()}.');
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AdminProvider admin = context.watch<AdminProvider>();
    final List<PrintOrder> items = _filter == null
        ? admin.allOrders
        : admin.allOrders.where((PrintOrder o) => o.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Print orders')),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                ...OrderStatusX.all.map(
                  (OrderStatus s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.label),
                      selected: _filter == s,
                      onSelected: (_) => setState(() => _filter = s),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: admin.loading && admin.allOrders.isEmpty
                ? const SkeletonList(count: 4)
                : admin.error != null && admin.allOrders.isEmpty
                    ? ErrorView(
                        message: admin.error!,
                        onRetry: () => admin.loadOrders(),
                      )
                    : items.isEmpty
                        ? const EmptyState(
                            icon: Icons.print_disabled_outlined,
                            title: 'No orders here',
                            message: 'Nothing matches this filter right now.',
                          )
                        : RefreshIndicator(
                            onRefresh: () => admin.loadOrders(refresh: true),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 32),
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int i) {
                                final PrintOrder o = items[i];
                                return AppCard(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  onTap: () => _changeStatus(o),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              o.user?.displayName ?? 'Member',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: context.inkColor,
                                              ),
                                            ),
                                          ),
                                          StatusChip.order(o.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      InfoRow(
                                        label: 'Service',
                                        value: o.serviceType.label,
                                      ),
                                      InfoRow(
                                        label: 'Copies',
                                        value:
                                            '${o.copies} - ${o.color ? 'colour' : 'black & white'}',
                                      ),
                                      InfoRow(
                                        label: 'Estimate',
                                        value: Fmt.price(o.estimatedPrice),
                                        valueColor: AppColors.primary,
                                      ),
                                      if ((o.description ?? '').isNotEmpty)
                                        InfoRow(
                                          label: 'Details',
                                          value: o.description!,
                                        ),
                                      InfoRow(
                                        label: 'Submitted',
                                        value: Fmt.dateTime(o.createdAt),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () => _changeStatus(o),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('Change status'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
