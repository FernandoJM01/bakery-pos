import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/branch.dart';
import '../../../core/api/generated/models/branch_create.dart';
import '../../../core/api/generated/models/branch_update.dart';
import '../../../core/api/generated/rest_client.dart';

final branchesServiceProvider =
    AsyncNotifierProvider<BranchesNotifier, List<Branch>>(BranchesNotifier.new);

class BranchesNotifier extends AsyncNotifier<List<Branch>> {
  RestClient get _client => ref.read(restClientProvider);

  @override
  Future<List<Branch>> build() async {
    return _fetchBranches();
  }

  Future<List<Branch>> _fetchBranches() async {
    return _client.branches.listBranches();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchBranches);
  }

  Future<Branch> createBranch(BranchCreate body) async {
    final newBranch = await _client.branches.createBranch(body: body);
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, newBranch]);
    return newBranch;
  }

  Future<Branch> updateBranch(String branchId, BranchUpdate body) async {
    final updated = await _client.branches.updateBranch(
      branchId: branchId,
      body: body,
    );
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((b) => b.id == branchId ? updated : b).toList(),
    );
    return updated;
  }
}
