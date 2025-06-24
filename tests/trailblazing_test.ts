import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.5.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
  name: "Validate Living Trailblazing UI Platform Initialization",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const account1 = accounts.get('wallet_1')!;

    let block = chain.mineBlock([
      Tx.contractCall('trailblazing-platform', 'create-challenge', [
        types.ascii("Summer Storytelling Challenge"),
        types.utf8("Craft a compelling summer-themed narrative"),
        types.ascii("fiction"),
        types.uint(43200),   // 12 hours
        types.uint(43200),   // 12 hours voting
        types.uint(100000),  // 0.1 STX submission fee
        types.uint(1000000)  // 1 STX stake
      ], deployer.address)
    ]);

    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectUint(1);
  }
});

Clarinet.test({
  name: "Validate Challenge Submission Process",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const account1 = accounts.get('wallet_1')!;

    // First, create a challenge
    let block = chain.mineBlock([
      Tx.contractCall('trailblazing-platform', 'create-challenge', [
        types.ascii("Summer Storytelling Challenge"),
        types.utf8("Craft a compelling summer-themed narrative"),
        types.ascii("fiction"),
        types.uint(43200),   // 12 hours
        types.uint(43200),   // 12 hours voting
        types.uint(100000),  // 0.1 STX submission fee
        types.uint(1000000)  // 1 STX stake
      ], deployer.address)
    ]);

    block = chain.mineBlock([
      Tx.contractCall('trailblazing-platform', 'submit-work', [
        types.uint(1),
        types.ascii("Sunset Memories"),
        types.buff(Buffer.from('12345'))
      ], account1.address)
    ]);

    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
  }
});