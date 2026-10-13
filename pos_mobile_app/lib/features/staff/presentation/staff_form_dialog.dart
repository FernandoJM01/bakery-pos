import 'package:flutter/material.dart';
import 'package:pos_mobile_app/core/constants/app_colors.dart';
import 'package:pos_mobile_app/features/auth/domain/user.dart';

class StaffFormDialog extends StatefulWidget {
  final User? staffToEdit;
  final void Function({
    required String fullName,
    required String username,
    required String pin,
    required UserRole role,
    String? avatarAsset,
  }) onSave;

  const StaffFormDialog({
    super.key,
    this.staffToEdit,
    required this.onSave,
  });

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _pinController;
  late UserRole _selectedRole;
  String? _selectedAvatar;

  final List<String> _availableAvatars = [
    'assets/users/maria_gonzalez.jpg',
    'assets/users/marco_rossi.jpg',
    'assets/users/elena_rostova.jpg',
  ];

  @override
  void initState() {
    super.initState();
    final staff = widget.staffToEdit;
    _nameController = TextEditingController(text: staff?.fullName ?? '');
    _usernameController = TextEditingController(text: staff?.username ?? '');
    _pinController = TextEditingController();
    _selectedRole = staff?.role ?? UserRole.cashier;
    _selectedAvatar = staff?.avatarAsset ?? _availableAvatars.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSave(
      fullName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      pin: _pinController.text.trim(),
      role: _selectedRole,
      avatarAsset: _selectedAvatar,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staffToEdit != null;

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceHighlight),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.manage_accounts_rounded : Icons.person_add_rounded,
                      color: AppColors.primaryAmber,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEditing ? 'Editar Empleado' : 'Registrar Nuevo Empleado',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.surfaceHighlight),
                const SizedBox(height: 16),

                // Selección de Avatar
                const Text(
                  'Foto de Perfil / Avatar',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _availableAvatars.map((asset) {
                    final isSelected = _selectedAvatar == asset;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = asset),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryAmber : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(asset),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Nombre Completo
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    hintText: 'ej. Carlos Santana',
                    hintStyle: const TextStyle(color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre completo' : null,
                ),
                const SizedBox(height: 14),

                // Usuario y Rol
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usernameController,
                        enabled: !isEditing, // ID de usuario inmutable al editar
                        style: TextStyle(color: isEditing ? AppColors.textMuted : AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Usuario de Acceso',
                          labelStyle: const TextStyle(color: AppColors.textMuted),
                          hintText: 'carlos1',
                          hintStyle: const TextStyle(color: AppColors.textDisabled),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el usuario' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceElevated,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Rol Operativo',
                          labelStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        items: UserRole.values
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    _roleLabel(r),
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // PIN de 4 dígitos
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 4),
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Nuevo PIN (dejar vacío para conservar)' : 'PIN de Acceso (4 dígitos)',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    hintText: '••••',
                    hintStyle: const TextStyle(color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  validator: (val) {
                    if (!isEditing && (val == null || val.trim().length != 4)) {
                      return 'El PIN debe ser exactamente de 4 dígitos';
                    }
                    if (isEditing && val != null && val.isNotEmpty && val.trim().length != 4) {
                      return 'El PIN debe ser de 4 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAmber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _submit,
                      child: Text(
                        isEditing ? 'Guardar Cambios' : 'Registrar Empleado',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.globalAdmin:
        return 'Administrador General';
      case UserRole.branchManager:
        return 'Gerente de Sucursal';
      case UserRole.localBaker:
        return 'Maestro Panadero';
      case UserRole.cashier:
        return 'Cajero / POS';
    }
  }
}
