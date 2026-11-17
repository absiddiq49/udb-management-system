import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/official_access_request.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';

class IoRequestsManagerView extends StatefulWidget {
  const IoRequestsManagerView({super.key});

  @override
  State<IoRequestsManagerView> createState() => _IoRequestsManagerViewState();
}

class _IoRequestsManagerViewState extends State<IoRequestsManagerView> {
  String _filterStatus = 'all';

  void _review(OfficialAccessRequest req, bool approve) {
    final auth = context.read<AuthProvider>();
    final reviewerName = '${auth.session.rank} ${auth.session.fullName}';

    if (approve) {
      context.read<RequestProvider>().reviewIORequest(
            requestId: req.id,
            approve: true,
            reviewerName: reviewerName,
            notes: 'Approved by $reviewerName (Valid for 72 hours)',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access Request ${req.requestCode} Approved. Pass token generated & SMS dispatched.'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      context.read<RequestProvider>().reviewIORequest(
            requestId: req.id,
            approve: false,
            reviewerName: reviewerName,
            notes: 'Administrative denial: insufficient Thana verification.',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access Request ${req.requestCode} Rejected.'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reqProvider = context.watch<RequestProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

    final allRequests = reqProvider.requests;
    final filtered = allRequests.where((r) {
      if (_filterStatus == 'pending') return r.isPending;
      if (_filterStatus == 'approved') return r.isApproved;
      if (_filterStatus == 'rejected') return r.isRejected;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 16,
        vertical: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.vpn_key_outlined, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'External Investigation Officer (IO) Access Requests Queue',
                            style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Review and authorize external police officers requesting access to restricted forensic dossiers, autopsy notes, and DNA records.',
                            style: TextStyle(color: textSec, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.goldBorder),
                      ),
                      child: Text(
                        '${reqProvider.pendingRequestsCount} Pending Review',
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter Tabs
              Row(
                children: [
                  _filterButton('All Requests (${allRequests.length})', 'all', isLight, textSec),
                  const SizedBox(width: 8),
                  _filterButton('Pending (${reqProvider.pendingRequestsCount})', 'pending', isLight, textSec),
                  const SizedBox(width: 8),
                  _filterButton('Approved', 'approved', isLight, textSec),
                  const SizedBox(width: 8),
                  _filterButton('Rejected', 'rejected', isLight, textSec),
                ],
              ),

              const SizedBox(height: 16),

              // Request Cards List
              if (filtered.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = filtered[index];
                    return _buildRequestCard(req, isLight, cardBg, borderColor, textPri, textSec);
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text('No access requests found matching this filter.', style: TextStyle(color: textSec)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label, String status, bool isLight, Color textSec) {
    final isSelected = _filterStatus == status;
    return ElevatedButton(
      onPressed: () => setState(() => _filterStatus = status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primary
            : (isLight ? AppColors.slate100 : AppColors.darkSurface),
        foregroundColor: isSelected ? Colors.white : textSec,
        elevation: isSelected ? 1 : 0,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isLight ? AppColors.slate200 : AppColors.darkBorder),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildRequestCard(OfficialAccessRequest req, bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    Color statusBg = AppColors.goldLight;
    Color statusColor = AppColors.gold;
    Color statusBorder = AppColors.goldBorder;

    if (req.isApproved) {
      statusBg = AppColors.greenLight;
      statusColor = AppColors.green;
      statusBorder = AppColors.greenBorder;
    }
    if (req.isRejected) {
      statusBg = AppColors.redLight;
      statusColor = AppColors.red;
      statusBorder = AppColors.redBorder;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: req.isPending ? AppColors.goldBorder : borderColor,
          width: req.isPending ? 1.5 : 1,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      req.requestCode,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${req.officerRank} ${req.officerName}',
                    style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text('(${req.bpNumber})', style: TextStyle(color: textSec, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusBorder),
                ),
                child: Text(
                  req.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isLight ? AppColors.slate50 : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
            ),
            child: Row(
              children: [
                Expanded(child: _field('Posting Unit / Thana', req.postingUnit, isLight, textPri)),
                Expanded(child: _field('Target Case', req.targetCaseReference, isLight, textPri)),
                Expanded(child: _field('Investigation GD/FIR', req.investigationGdFir, isLight, textPri)),
                Expanded(child: _field('Contact', '${req.contactPhone} • ${req.officialEmail}', isLight, textPri)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Legal Justification: ${req.reasonForAccess}',
            style: TextStyle(color: textPri, fontSize: 12, height: 1.4),
          ),

          if (req.accessToken != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.greenBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key, color: AppColors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Active Token Pass: ${req.accessToken} (${req.tokenExpiresAt})',
                    style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],

          if (req.isPending) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _review(req, false),
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Reject Request', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.redBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _review(req, true),
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Approve & Generate Pass', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(String label, String value, bool isLight, Color textPri) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: isLight ? AppColors.slate400 : AppColors.darkTextMuted, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: textPri, fontSize: 11, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
