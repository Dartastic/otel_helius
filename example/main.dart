// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_helius/otel_helius.dart';

/// Traces Helius calls with OpenTelemetry.
///
/// `otel_helius` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Helius call in
/// [tracedHelius]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'helius-example');

  // Wraps a Helius API call in a CLIENT span.
  final heliusId = await tracedHelius<String>(
    operation: 'webhooks.create',
    invoke: () async {
      // Make the Helius call here, then report what it returned.
      const id = 'helius_8f3a2c';
      return const HeliusCallResult(
          value: id,
          result: HeliusResult(
              cluster: 'mainnet-beta',
              surface: 'rpc',
              rpcMethod: 'getAsset',
              batchSize: 512,
              creditsUsed: 1,
              responseBytes: 512,
              commitment: 'processed',
              slot: 1,
              account: 'example',
              tokenStandard: 'FungibleToken',
              assetCount: 3,
              collection: 'orders',
              priorityFeeMicroLamports: 443,
              webhookId: 'webhook_8f3a2c',
              webhookKind: 'enhanced',
              lasersAddress: 'example',
              parsedTxKind: 'NFT_SALE',
              rateLimitRemaining: 25,
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedHelius webhooks.create returned $heliusId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutHeliusInstrumentationAsync.
  await runWithoutHeliusInstrumentationAsync(
    () => tracedHelius<String>(
      operation: 'webhooks.create',
      invoke: () async {
        const id = 'helius_8f3a2c';
        return const HeliusCallResult(
            value: id,
            result: HeliusResult(
                cluster: 'mainnet-beta',
                surface: 'rpc',
                rpcMethod: 'getAsset',
                batchSize: 512,
                creditsUsed: 1,
                responseBytes: 512,
                commitment: 'processed',
                slot: 1,
                account: 'example',
                tokenStandard: 'FungibleToken',
                assetCount: 3,
                collection: 'orders',
                priorityFeeMicroLamports: 443,
                webhookId: 'webhook_8f3a2c',
                webhookKind: 'enhanced',
                lasersAddress: 'example',
                parsedTxKind: 'NFT_SALE',
                rateLimitRemaining: 25,
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
