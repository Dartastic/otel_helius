// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_helius/otel_helius.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_helius-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('das.getAssetsByOwner records standard + count', () async {
    await tracedHelius<String>(
      operation: 'das.getAssetsByOwner',
      invoke: () async => const HeliusCallResult(
        value: 'ok',
        result: HeliusResult(
          cluster: 'mainnet-beta',
          surface: 'das',
          rpcMethod: 'getAssetsByOwner',
          tokenStandard: 'NonFungible',
          assetCount: 27,
          creditsUsed: 30,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('helius das.getAssetsByOwner')!);
    expect(a['helius.token.standard'], 'NonFungible');
    expect(a['helius.asset.count'], 27);
  });

  test('priorityFees.estimate records micro-lamports', () async {
    await tracedHelius<String>(
      operation: 'priorityFees.estimate',
      invoke: () async => const HeliusCallResult(
        value: 'ok',
        result: HeliusResult(
          surface: 'priority_fees',
          priorityFeeMicroLamports: 50000,
          commitment: 'confirmed',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('helius priorityFees.estimate')!);
    expect(a['helius.priority_fee.micro_lamports'], 50000);
  });

  test('JSON-RPC error sets span error', () async {
    await tracedHelius<String>(
      operation: 'rpc.send',
      invoke: () async => const HeliusCallResult(
        value: 'ok',
        result: HeliusResult(
          rpcMethod: 'getTransaction',
          errorCode: '-32603',
          errorMessage: 'Internal error',
        ),
      ),
    );
    expect(
      spans.findSpanByName('helius rpc.send')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutHeliusInstrumentationAsync(() async {
      await tracedHelius<String>(
        operation: 'webhooks.list',
        invoke: () async => const HeliusCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('helius '), isEmpty);
  });
}
