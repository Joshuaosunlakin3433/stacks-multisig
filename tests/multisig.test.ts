import {
  Cl,
  getAddressFromPrivateKey,
  makeRandomPrivKey,
} from "@stacks/transactions";
import { it } from "node:test";
import { describe, beforeEach, expect } from "vitest";

const accounts = simnet.getAccounts(); // initialize simnet for testing
const deployer = accounts.get("deployer")!; // deployer for initializing multisig

// create 3 random private keys for Alice, Bob, and Charlie which are the actual signers
const alicePrivateKey = makeRandomPrivKey();
const bobPrivateKey = makeRandomPrivKey();
const charliePrivateKey = makeRandomPrivKey();

//Get the addresses from the private keys
const alice = getAddressFromPrivateKey(alicePrivateKey, "mocknet");
const bob = getAddressFromPrivateKey(bobPrivateKey, "mocknet");
const charlie = getAddressFromPrivateKey(charliePrivateKey, "mocknet");

//Get the contract principals for the token and multisig contracts
const token = Cl.contractPrincipal(deployer, "mock-token");
const multisig = Cl.contractPrincipal(deployer, "multisig");

describe("Multisig Tests", () => {
  beforeEach(() => {
    const allAccounts = [alice, bob, charlie];

    for (const account of allAccounts) {
      const mintResultOne = simnet.callPublicFn(
        "mock-token",
        "mint",
        [Cl.uint(1_000_000_000), Cl.principal(account)],
        account
      );
      expect(mintResultOne.events.length).toBeGreaterThan(0);

      simnet.mintSTX(account, 100_000_000n);
    }
  });

  it("allows initializing the multisig", () => {
    const initializeResult = simnet.callPublicFn(
      "multisig",
      "initialize",
      [
        Cl.list([
          Cl.principal(alice),
          Cl.principal(bob),
          Cl.principal(charlie),
        ]),
      ],
      deployer
    );

    expect(initializeResult.result).toStrictEqual(Cl.ok(Cl.bool(true)));

    const signers = simnet.getDataVar("multisig", "signers");
    expect(signers).toEqual(
      Cl.list([Cl.principal(alice), Cl.principal(bob), Cl.principal(charlie)])
    );

    const threshold = simnet.getDataVar("multisig", "threshold");
    expect(threshold).toEqual(Cl.uint(2));

    const initialized = simnet.getDataVar("multisig", "initialized");
    expect(initialized).toEqual(Cl.bool(true));
  });

  it("allows deployer to initialize the multisig", () => {
    const initializeResult = simnet.callPublicFn(
      "multisig",
      "initialize",
      [
        Cl.list([
          Cl.principal(alice),
          Cl.principal(bob),
          Cl.principal(charlie),
        ]),
        Cl.uint(2),
      ],
      alice
    );
    expect(initializeResult.result).toStrictEqual(Cl.error(Cl.uint(500)));
  });
});
