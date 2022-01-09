# How to connect

We are currently in early alpha testing of independent RPC operators. We are conducting internal testing and refining documentation to assist in the onboarding of more Operators. Please stay tuned as this section will eventually include more specifics. The below process is the steps once alpha testing has completed.

12/15/21
UPDATE: Alpha Shadow Node testing is still ongoing <br>
12/22/21
UPDATE: Alpha Shadow Node pool has reached the ideal number of test ShadowOps and will closing until after the IDO.<br>
01/08/**22**
UPDATE: Adding script and information on how to connect your node automatically via discord.

Connecting to our network currently involves three steps:

1. Run the getShadowInfo.sh shell script located in the Shadow-RPC-Operator folder. Once you download this, you may need to run `chmod +x getShadowInfo.sh` to make the file exectuable. Then run `./getShadowInfo.sh` to run the file. **NOTE: YOU WILL BE REQUIRED TO GRAB THE WEBHOOK URL FROM THE SHADOW OPERATORS DISCORD. THIS IS NOT BEING PLACED IN THE GITHUB FOR SECURITY REASONS.**

2. When your node is ready and you're ready to put into the shadow network, you will run the following command in the shadow-operators channel:

`!activate-node <hostname>`

3. Verify connection to health check bots in SSC DAO discord channel and confirming calls are properly serving.
