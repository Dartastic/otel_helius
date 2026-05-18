// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_helius_suppression.dart';

const _tracerName = 'dartastic_otel_libs_helius';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class HeliusResult {
  const HeliusResult({
    this.cluster,
    this.surface,
    this.rpcMethod,
    this.batchSize,
    this.creditsUsed,
    this.responseBytes,
    this.commitment,
    this.slot,
    this.account,
    this.tokenStandard,
    this.assetCount,
    this.collection,
    this.priorityFeeMicroLamports,
    this.webhookId,
    this.webhookKind,
    this.lasersAddress,
    this.parsedTxKind,
    this.rateLimitRemaining,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `mainnet-beta`, `devnet`.
  final String? cluster;

  /// `rpc`, `enhanced`, `das`, `priority_fees`, `webhooks`, `lasers`,
  /// `mints`, `parsed_transactions`, `staking`.
  final String? surface;

  /// JSON-RPC or DAS method (`getAsset`, `getAssetsByOwner`,
  /// `searchAssets`, `getSignaturesForAsset`, `getTransaction`,
  /// `getPriorityFeeEstimate`, `getAccountInfo`, `getProgramAccounts`,
  /// `sendTransaction`, `simulateTransaction`, ...).
  final String? rpcMethod;

  final int? batchSize;

  /// Helius credits charged (primary billing).
  final int? creditsUsed;

  final int? responseBytes;

  /// `processed`, `confirmed`, `finalized`.
  final String? commitment;

  final int? slot;

  /// Account / wallet address.
  final String? account;

  /// DAS asset standard (`FungibleToken`, `NonFungible`, `ProgrammableNFT`,
  /// `MplCoreAsset`, `FungibleAsset`, `Inscription`).
  final String? tokenStandard;

  /// Result asset count for DAS endpoints.
  final int? assetCount;

  final String? collection;

  /// Suggested priority fee in micro-lamports per CU.
  final int? priorityFeeMicroLamports;

  // ── Webhooks ───────────────────────────────────────────────────
  final String? webhookId;

  /// `enhanced`, `raw`, `discord`, `metadata`.
  final String? webhookKind;

  // ── Lasers (stream) ────────────────────────────────────────────
  final String? lasersAddress;

  /// Parsed-transaction event kind
  /// (`NFT_SALE`, `NFT_LISTING`, `NFT_BID`, `TRANSFER`, `SWAP`,
  /// `BURN`, `STAKE`, `UNSTAKE`, ...).
  final String? parsedTxKind;

  final int? rateLimitRemaining;

  /// Helius / JSON-RPC error code.
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class HeliusCallResult<T> {
  const HeliusCallResult({required this.value, this.result});
  final T value;
  final HeliusResult? result;
}

/// Wraps a Helius API call in a CLIENT span. [operation] is one of
/// `rpc.send`, `rpc.sendBatch`, `enhanced.parseTransaction`,
/// `enhanced.parseTransactionHistory`, `das.getAsset`,
/// `das.getAssetBatch`, `das.getAssetsByOwner`, `das.getAssetsByGroup`,
/// `das.getAssetsByAuthority`, `das.getAssetsByCreator`,
/// `das.searchAssets`, `das.getSignaturesForAsset`,
/// `das.getTokenAccounts`, `priorityFees.estimate`,
/// `webhooks.create`, `webhooks.list`, `webhooks.delete`, `webhooks.edit`,
/// `lasers.subscribe`, `lasers.unsubscribe`, `mint.create`, `mint.update`,
/// `staking.getValidators`, `staking.stake`, `staking.unstake`.
Future<T> tracedHelius<T>({
  required String operation,
  required Future<HeliusCallResult<T>> Function() invoke,
}) async {
  if (heliusInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'helius',
    'rpc.method': operation,
    'helius.operation': operation,
  };

  final span = _tracer().startSpan(
    'helius $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.cluster != null) {
        extras.add(OTel.attributeString('helius.cluster', res.cluster!));
      }
      if (res.surface != null) {
        extras.add(OTel.attributeString('helius.surface', res.surface!));
      }
      if (res.rpcMethod != null) {
        extras.add(OTel.attributeString('helius.rpc.method', res.rpcMethod!));
      }
      if (res.batchSize != null) {
        extras.add(OTel.attributeInt('helius.batch.size', res.batchSize!));
      }
      if (res.creditsUsed != null) {
        extras.add(OTel.attributeInt(
          'helius.credits.used',
          res.creditsUsed!,
        ));
      }
      if (res.responseBytes != null) {
        extras.add(OTel.attributeInt(
          'helius.response.bytes',
          res.responseBytes!,
        ));
      }
      if (res.commitment != null) {
        extras.add(OTel.attributeString('helius.commitment', res.commitment!));
      }
      if (res.slot != null) {
        extras.add(OTel.attributeInt('helius.slot', res.slot!));
      }
      if (res.account != null) {
        extras.add(OTel.attributeString('helius.account', res.account!));
      }
      if (res.tokenStandard != null) {
        extras.add(OTel.attributeString(
          'helius.token.standard',
          res.tokenStandard!,
        ));
      }
      if (res.assetCount != null) {
        extras.add(OTel.attributeInt(
          'helius.asset.count',
          res.assetCount!,
        ));
      }
      if (res.collection != null) {
        extras.add(OTel.attributeString(
          'helius.collection',
          res.collection!,
        ));
      }
      if (res.priorityFeeMicroLamports != null) {
        extras.add(OTel.attributeInt(
          'helius.priority_fee.micro_lamports',
          res.priorityFeeMicroLamports!,
        ));
      }
      if (res.webhookId != null) {
        extras.add(OTel.attributeString(
          'helius.webhook.id',
          res.webhookId!,
        ));
      }
      if (res.webhookKind != null) {
        extras.add(OTel.attributeString(
          'helius.webhook.kind',
          res.webhookKind!,
        ));
      }
      if (res.lasersAddress != null) {
        extras.add(OTel.attributeString(
          'helius.lasers.address',
          res.lasersAddress!,
        ));
      }
      if (res.parsedTxKind != null) {
        extras.add(OTel.attributeString(
          'helius.parsed_tx.kind',
          res.parsedTxKind!,
        ));
      }
      if (res.rateLimitRemaining != null) {
        extras.add(OTel.attributeInt(
          'helius.rate_limit.remaining',
          res.rateLimitRemaining!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'helius.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Helius ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'helius.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'Helius HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
