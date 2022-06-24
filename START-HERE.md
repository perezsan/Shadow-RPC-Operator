# Shadow-RPC-Operator

Shadow Operator resources for running a high performance &amp; high stability Shadow Node to earn rewards

# Overview

Please make sure to review this comprehensive overview of the [Shadow Infrastructure Overview](https://shdw.genesysgo.com/shadow-infrastructure-overview/shadow-operators)

This guide is currently intended only for setting up servers from the [Solana Server Program](https://solana.foundation/server-program).

**IMPORTANT:** We are currently in closed beta testing of Shadow Node Operators. Please reach out to a team member of GenesysGo to express interest in being an beta tester. During this phase of testing, beta operators will receive automated emission payments from the Shadow Smart Contracts covering independent operators. Details are in the "Shadow Infrastructure Overview linked above."

**UPDATE** 06/06 - Alpha testing pool is closed. Closed beta is live with all smart contract operating on mainnet. Open beta is next. 

**HARDWARE CONSIDERATIONS**
A Solana Shadow Node has similar hardware requirements to the Solana RPC with the added preference of additional storage capacity. This will change over time as the Shadow Protocol evolves.

If you are utilizing the Solana Server Program for your hardware, please make sure you are provisioning the following at a minimum:

Minimums from Solana Server Program:
*  CPU - 24 core, 2.8Ghz, AVX2 support (Prefer 3.0Ghz+ native) - **must sustain boost above 3.0Ghz across all cores**
*  RAM - 256GB (512GB prefered)
*  HD  - x2 Boot ~200GB SSD, Storage - 3.8TB NVME, (additional 3.8TB or greater prefered for additional storage)
*  NIC - 10gig (dual 10gig bonded prefered)
*  Connection - 1GB/s symmetrical

**IMPORTANT**: Please avoid the 7402p generation 2 AMD processor. It will not be able to handle the workload. This CPU is issued in the EQ2 model from Equinix, but possibly elsewhere within the SSP. If you are looking at generation 2 AMDs, 7502p with 512gig ram are currently able to peform decent. We recommend generation 3 AMDs if possible (such as the AMD 7513 found in higher spec Equinix options). Intel ice-lakes and dual sockets intel that can boost (sustain the boost) over 3Ghz are also performant but are not supported in these docs.

Custom Builders see above minimums or the below general guidance. These are generalizations and subject to change.
# Operating a Shadow Node

This resource has a step by step guide covering:
1) [Configuring a Shadow Node](https://github.com/Shadowy-Super-Coder-DAO/Shadow-RPC-Operator/blob/main/1-How-to-configure-RPC-node.md)
2) [Connecting](https://portal.genesysgo.net/) the Shadow Node to the `SSC-DAO Shadow Network` via the portal
3) [Maintaining](https://github.com/Shadowy-Super-Coder-DAO/Shadow-RPC-Operator/blob/main/3-FAQ-how-to-maintain-rpc-node.md) your Shadow Node for maximum rewards payouts

If you are just getting started, walking through the `1-Configuring a Shadow Node` will be immensely helpful in learning the design of the machines and basic linux commands. The guide is designed to support a Linux novice. 

Once you have completed Steps 1-3 you should notify the GenesysGo team and receive the Shadow Operator role in Discord. This grants you access to the Shadow Ops and Shadow health monitoring channels.
# Rewards for Operating a Shadow Node

Please see this [resource](https://shdw.genesysgo.com/shadow-infrastructure-overview/shadow-operators) for how rewards will work:

# Other Resources & Learning

Official Solana RPC resources to reference are located in the [Solana Documentation](https://docs.solana.com/running-validator).

For developers interested in a more automated control we are releasing an advanced Shadow Node operator manual in due time.

