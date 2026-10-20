import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile_app/core/constants/app_colors.dart';
import '../domain/bake_batch.dart';
import 'bake_sheet_notifier.dart';

class BakeSheetConsoleView extends ConsumerStatefulWidget {
  const BakeSheetConsoleView({super.key});

  @override
  ConsumerState<BakeSheetConsoleView> createState() => _BakeSheetConsoleViewState();
}

class _BakeSheetConsoleViewState extends ConsumerState<BakeSheetConsoleView> {
  void _openNewBatchDialog() {
    final formKey = GlobalKey<FormState>();
    final productCtrl = TextEditingController(text: 'Conchas Tradicionales (Vainilla & Chocolate)');
    final unitsCtrl = TextEditingController(text: '48');
    final tempCtrl = TextEditingController(text: '185');
    final timeCtrl = TextEditingController(text: '15');
    String selectedOven = 'Horno Rotativo 1';
    String selectedShift = 'Turno Matutino 06:00';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surfaceHighlight),
          ),
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(22),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.outdoor_grill_rounded, color: AppColors.primaryAmber, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'Programar Hornada',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.surfaceHighlight),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: productCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Receta / Producto',
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: unitsCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Piezas / Rendimiento',
                            labelStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Número inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedOven,
                          dropdownColor: AppColors.surfaceElevated,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Horno Asignado',
                            labelStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Horno Rotativo 1', child: Text('Horno Rotativo 1')),
                            DropdownMenuItem(value: 'Horno de Piedra 2', child: Text('Horno de Piedra 2')),
                            DropdownMenuItem(value: 'Horno Convector 3', child: Text('Horno Convector 3')),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => selectedOven = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tempCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Temperatura (°C)',
                            labelStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: timeCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Tiempo (minutos)',
                            labelStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          ref.read(bakeSheetProvider.notifier).addBatch(
                                productName: productCtrl.text.trim(),
                                productSku: 'PAST-CONC',
                                ovenName: selectedOven,
                                targetUnits: int.tryParse(unitsCtrl.text.trim()) ?? 24,
                                tempCelsius: int.tryParse(tempCtrl.text.trim()) ?? 180,
                                bakeDurationMinutes: int.tryParse(timeCtrl.text.trim()) ?? 15,
                                shift: selectedShift,
                              );
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.successGreen,
                              content: Text('✓ Hornada programada e iniciada en fermentación'),
                            ),
                          );
                        },
                        child: const Text('Iniciar Hornada', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openWasteDialog(BakeBatch batch) {
    final unitsCtrl = TextEditingController(text: '2');
    String selectedReason = 'Quemado / Sobrehorneado';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surfaceHighlight),
          ),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.remove_circle_outline_rounded, color: AppColors.alertRed, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Registrar Merma • ${batch.batchNumber}',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.surfaceHighlight),
                const SizedBox(height: 16),
                Text(
                  'Producto: ${batch.productName}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: unitsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Unidades Mermadas',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  dropdownColor: AppColors.surfaceElevated,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Motivo de Merma',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Quemado / Sobrehorneado', child: Text('Quemado / Sobrehorneado')),
                    DropdownMenuItem(value: 'Sobrefermentado / Caído', child: Text('Sobrefermentado / Caído')),
                    DropdownMenuItem(value: 'Roto / Deforme', child: Text('Roto / Deforme')),
                    DropdownMenuItem(value: 'Muestra / Degustación', child: Text('Muestra / Degustación')),
                    DropdownMenuItem(value: 'Caducidad del Día', child: Text('Caducidad del Día')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedReason = v);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final units = int.tryParse(unitsCtrl.text.trim()) ?? 0;
                        ref.read(bakeSheetProvider.notifier).recordWaste(batch.id, units, selectedReason);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.alertRed,
                            content: Text('✓ Se asentó merma de $units piezas por $selectedReason'),
                          ),
                        );
                      },
                      child: const Text('Asentar Merma', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bakeState = ref.watch(bakeSheetProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Consola de Horno & Hojas de Horneado',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Planificación de producción matutina y vespertina del maestro panadero',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _openNewBatchDialog,
                icon: const Icon(Icons.outdoor_grill_rounded, size: 18),
                label: const Text('Programar Hornada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tarjetas de Hornos Activos
          Row(
            children: [
              Expanded(child: _buildOvenCard('Horno Rotativo 1', '185°C', 'HORNEANDO', 'Conchas (Vainilla & Chocolate)', '12 min rest.', AppColors.primaryAmber)),
              const SizedBox(width: 14),
              Expanded(child: _buildOvenCard('Horno de Piedra 2', '235°C', 'HORNEANDO', 'Hogazas de Masa Madre', '24 min rest.', AppColors.primaryAmber)),
              const SizedBox(width: 14),
              Expanded(child: _buildOvenCard('Horno Convector 3', '160°C', 'DISPONIBLE', 'En espera de tanda', 'Listo para precalentar', AppColors.successGreen)),
            ],
          ),
          const SizedBox(height: 24),

          // Tabla de Hornadas Programadas
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cronograma de Hornadas del Día (Bake Sheet)',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${bakeState.batches.length} Tandas Registradas',
                        style: const TextStyle(color: AppColors.primaryAmber, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.surfaceHighlight),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bakeState.batches.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceHighlight),
                  itemBuilder: (context, idx) {
                    final batch = bakeState.batches[idx];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.surfaceHighlight),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              batch.batchNumber,
                              style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  batch.productName,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${batch.ovenName} • ${batch.tempCelsius}°C • ${batch.scheduledShift}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Objetivo: ${batch.targetUnits} pzs',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                if (batch.wasteUnits > 0)
                                  Text(
                                    'Merma: ${batch.wasteUnits} (${batch.wasteReason})',
                                    style: const TextStyle(color: AppColors.alertRed, fontSize: 11),
                                  )
                                else
                                  Text(
                                    batch.status == BakeBatchStatus.readyInShowcase
                                        ? 'Completado: ${batch.completedUnits} pzs en vitrina'
                                        : 'En proceso (${batch.minutesRemaining} min)',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildStatusPill(batch.status),
                            ),
                          ),
                          Row(
                            children: [
                              if (batch.status != BakeBatchStatus.readyInShowcase) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surfaceElevated,
                                    foregroundColor: AppColors.primaryAmber,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    side: const BorderSide(color: AppColors.surfaceHighlight),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => ref.read(bakeSheetProvider.notifier).advanceBatchStatus(batch.id),
                                  child: Text(_nextActionLabel(batch.status), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                              ],
                              IconButton(
                                tooltip: 'Registrar Merma',
                                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.textMuted, size: 20),
                                onPressed: () => _openWasteDialog(batch),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOvenCard(String name, String temp, String status, String product, String remaining, Color accent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(temp, style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(product, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(remaining, style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BakeBatchStatus status) {
    Color color;
    Color bg;

    switch (status) {
      case BakeBatchStatus.fermenting:
        color = const Color(0xFF3B82F6);
        bg = const Color(0x223B82F6);
        break;
      case BakeBatchStatus.baking:
        color = AppColors.primaryAmber;
        bg = const Color(0x22E89838);
        break;
      case BakeBatchStatus.cooling:
        color = const Color(0xFFA855F7);
        bg = const Color(0x22A855F7);
        break;
      case BakeBatchStatus.readyInShowcase:
        color = AppColors.successGreen;
        bg = AppColors.successGreenBg;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  String _nextActionLabel(BakeBatchStatus status) {
    switch (status) {
      case BakeBatchStatus.fermenting:
        return 'Meter a Horno →';
      case BakeBatchStatus.baking:
        return 'Sacar a Enfriar →';
      case BakeBatchStatus.cooling:
        return 'Pasar a Vitrina ✓';
      case BakeBatchStatus.readyInShowcase:
        return 'Listo';
    }
  }
}
