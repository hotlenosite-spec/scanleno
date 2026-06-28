import 'package:flutter/material.dart';

import '../../../app/app_shell.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/ad_service.dart';
import '../../ads/presentation/ad_banner_slot.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      currentIndex: 0,
      child: AppScreen(
        title: l.appName,
        trailing: const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.softBlue,
          child: Icon(Icons.person_rounded, color: AppColors.primary),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          children: [
            Text(l.welcomeBack, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.xs),
            Text(l.quickAccess, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.lg),
            _ScanBanner(title: l.scanDocument, subtitle: l.startNewScan, onTap: () => Navigator.of(context).pushNamed(AppRoutes.scanner)),
            const SizedBox(height: AppSpacing.md),
            const AdBannerSlot(placement: AdPlacement.home),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(child: _QuickTool(icon: Icons.draw_rounded, label: l.signPdf, tint: const Color(0xFFEAF3FF), onTap: () => Navigator.of(context).pushNamed(AppRoutes.signature))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _QuickTool(icon: Icons.compress_rounded, label: l.compressPdf, tint: const Color(0xFFF0EAFE), onTap: () => Navigator.of(context).pushNamed(AppRoutes.tools))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _QuickTool(icon: Icons.file_copy_outlined, label: l.mergePdf, tint: AppColors.softTurquoise, onTap: () => Navigator.of(context).pushNamed(AppRoutes.tools))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _QuickTool(icon: Icons.image_outlined, label: l.imagesToPdf, tint: const Color(0xFFEAF3FF), onTap: () => Navigator.of(context).pushNamed(AppRoutes.export))),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(title: l.recentDocuments, action: l.viewAll, onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.files)),
            const SizedBox(height: AppSpacing.sm),
            const _RecentList(),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(child: _StorageCard(title: l.usedStorage)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _PremiumCard(title: l.upgradeToPremium, subtitle: l.premiumDescription, button: l.upgradeNow)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ScanBanner extends StatelessWidget { const _ScanBanner({required this.title,required this.subtitle,required this.onTap}); final String title,subtitle; final VoidCallback onTap; @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:AppRadii.large,child:Container(height:178,padding:const EdgeInsets.all(AppSpacing.lg),decoration:const BoxDecoration(borderRadius:AppRadii.large,gradient:LinearGradient(colors:[Color(0xFF174C93),Color(0xFF061E55)]),boxShadow:AppShadows.card),child:Row(children:[const Expanded(child:Icon(Icons.document_scanner_rounded,size:88,color:Color(0xFFA9DFFF))),Expanded(flex:2,child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(title,style:Theme.of(context).textTheme.headlineSmall?.copyWith(color:Colors.white,fontWeight:FontWeight.w800)),const SizedBox(height:AppSpacing.xs),Text(subtitle,style:const TextStyle(color:Colors.white70)),const SizedBox(height:AppSpacing.sm),const CircleAvatar(backgroundColor:AppColors.accent,foregroundColor:Colors.white,child:Icon(Icons.document_scanner_outlined))]))])));}
class _QuickTool extends StatelessWidget { const _QuickTool({required this.icon,required this.label,required this.tint,required this.onTap}); final IconData icon;final String label;final Color tint;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:AppRadii.medium,child:SoftCard(padding:const EdgeInsets.symmetric(vertical:AppSpacing.xs,horizontal:AppSpacing.xs),child:SizedBox(height:94,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:tint,borderRadius:AppRadii.small),child:Icon(icon,color:AppColors.interactive,size:24)),const SizedBox(height:AppSpacing.xs),Flexible(child:Text(label,textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.labelSmall))]))));}
class _SectionTitle extends StatelessWidget { const _SectionTitle({required this.title,required this.action,required this.onTap}); final String title,action;final VoidCallback onTap;@override Widget build(BuildContext context)=>Row(children:[Expanded(child:Text(title,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800))),TextButton(onPressed:onTap,child:Text(action))]);}
class _RecentList extends StatelessWidget { const _RecentList(); @override Widget build(BuildContext context)=>SoftCard(padding:EdgeInsets.zero,child:Column(children:const[_DocumentRow(icon:Icons.picture_as_pdf_outlined),Divider(height:1),_DocumentRow(icon:Icons.picture_as_pdf_outlined),Divider(height:1),_DocumentRow(icon:Icons.image_outlined)]));}
class _DocumentRow extends StatelessWidget { const _DocumentRow({required this.icon}); final IconData icon; @override Widget build(BuildContext context)=>ListTile(leading:Container(padding:const EdgeInsets.all(10),decoration:const BoxDecoration(color:AppColors.softBlue,borderRadius:AppRadii.small),child:Icon(icon,color:AppColors.interactive)),title:const SizedBox(height:12),subtitle:const SizedBox(height:10),trailing:const Icon(Icons.more_vert_rounded,color:AppColors.muted));}
class _StorageCard extends StatelessWidget { const _StorageCard({required this.title}); final String title; @override Widget build(BuildContext context)=>SoftCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.cloud_outlined,color:AppColors.accent),const SizedBox(height:AppSpacing.xs),Text(title,style:Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:AppSpacing.sm),const LinearProgressIndicator(value:.26,color:AppColors.accent,backgroundColor:AppColors.softBlue),const SizedBox(height:AppSpacing.xs),Text(context.l10n.storageUsage,style:const TextStyle(color:AppColors.accent))]));}
class _PremiumCard extends StatelessWidget { const _PremiumCard({required this.title,required this.subtitle,required this.button});final String title,subtitle,button;@override Widget build(BuildContext context)=>SoftCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.workspace_premium_outlined,color:Color(0xFFFFB52C)),const SizedBox(height:AppSpacing.xs),Text(title,style:Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:AppSpacing.xs),Text(subtitle,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,color:AppColors.muted)),const SizedBox(height:AppSpacing.sm),SizedBox(width:double.infinity,child:FilledButton(onPressed:(){},style:FilledButton.styleFrom(minimumSize:const Size(0,34)),child:Text(button)))]));}
