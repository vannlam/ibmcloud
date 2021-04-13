# try-sat

This set of scripts provides a mostly-automated way to set up a Satellite location and RedHat OpenShift cluster on IBM Cloud VPC Gen2 infrastructure.
This is not a model we would ever deploy for a real-world workload, but is useful for learning/experimenting/understanding.

## What Does try-sat Create?

* A dedicated Resource Group.
* A VPC (Gen 2) on IBM Cloud.
* 7 VSIs with RHEL v7: 3 Control Planes + 3 Worker Nodes + 1 Wireguard VPN server
* A Satellite location, with 3 VSIs assigned as control plane nodes.
* A ROKS cluster on the location, with 3 VSIs assigned as worker nodes.

## How to Use

* Install the [pre-requisite tools](PREREQS.md). You may already have many of these.
* Complete the [once-only configuration](CONFIGURATION.md).
* [Complete Method 1](#method-1-one-click-private-cluster), which is the simplest, or one of the [other methods](#other-methods) listed below.

> Note: for all of these methods, you may see quite a few "error" messages as `try-sat` proceeds, such as `Registering a subdomain for control plane hosts...  FAILED. The specified location could not be found`. While this is not by design, [it is to be expected](https://github.ibm.com/garage-satellite-guild/try-sat/issues/47), as there is no other reliable way to detect certain creation events than to poll the CLI repeatedly until artifacts are created. Do not be alarmed if you see a number of these.

### Method 1: 'One-click' Private ROKS cluster on private endpoints, with WireGuard VPN

> Estimated time: 90mins

1.  Ensure you have completed the [once-only configuration](CONFIGURATION.md), and have run `source .envrc` in your terminal if you are not using `direnv`.
1.  Run `make all_private`.

### Method 2: 'One-click'  Public ROKS cluster on public endpoints, with WireGuard VPN in addition

> Estimated time: 250mins

1.  Ensure you have completed the [once-only configuration](CONFIGURATION.md), and have run source .envrc in your terminal if you are not using direnv.
1.  Run `make all_public`.

> CAUTION: This approach currently appears to be quite unreliable due to some as-yet unresolved DNS issues in the Satellite world and you may not get a stable result.

### Method 3: Hands-on step-by-step ROKS cluster on public endpoints also, with WireGuard VPN in addition

> Estimated time: 180mins

See [here](HANDS-ON.md).

## Using Your Generated Cluster

*   If you are using the Simple (private cluster) method, open the WireGuard client and import the generated WireGuard configuration file from the root of the checkout directory (`wireguard-$(RESOURCE_PREFIX).conf`). Activate the VPN.

*   Run `make login_cluster`. You should then be able to run `oc` commands and work with your new cluster from the command line using `kubectl`/`oc`.  Or... open the OpenShift console through the IBM Cloud console.

## Removing All Generated Resources

*   Run `make clean`

> If the cloud setup is still in a messy state, this will sometimes fail on the first run. If you want a more aggressive clean, run `make aggressive_clean`, which will run continuously until the clean passes.

> **IMPORTANT NOTE**: If you destroy your location using `make clean` (or other methods), you may get quite a lot of random timeouts in the automation when you then to try recreate your setup again. For now, recommend using a fresh `RESOURCE_PREFIX` in `.envrc` each time you destroy an environment and re-run. This appears to be an issue with Satellite (see [here](https://github.ibm.com/alchemy-containers/satellite-planning/issues/1337) for issue and [here](https://ibm-garage.slack.com/archives/C01149RMSCU/p1614795537486000) for Slack discussion thread).

## Troubleshooting

*   If you are trying to debug `try-sat`, you may want to run `make watch` (in a spare terminal window). This will help you watch the status of various key resources as they are created and will give a greater understanding of what's going on. Note that many errors will show in the early stages of creation - this is to be expected as resources won't exist yet.

## Contacts

If you want to discuss try-sat, try the [try-sat-friends](https://ibm-garage.slack.com/archives/C01PCPAB9HS) Slack channel.
If you're thinking about using it for anything important, please read the [disclaimers and limitations](DISCLAIMERS.md)! Also, there are some [known issues](https://github.ibm.com/garage-satellite-guild/try-sat/issues?q=is%3Aissue+is%3Aopen+label%3Abug).

## Thanks

* Jake Kitchener's walkthrough videos [1](https://ibm.ent.box.com/s/c2p4bi1mxfo3xf5s8mi3u6fagz2f87mm), [2](https://ibm.ent.box.com/s/l5cebiychfcm72hbthrv6cpxetevhmbc) were very helpful in putting this together, although we've taken a slightly different approach here in places.

* John Pape for a lot of help on Slack.

* Ilene Seeleman and the Security Guild for [Terraform-izing WireGuard](https://github.ibm.com/ibm-garage-for-cloud/guild-automation-scripts).

* Chris Weber for the new project name!

* Frederic Lavigne for doing some testing and sending a pull request with lots of improvements.

* Raimond van Stijn for fixing the region issue so any region can be used.

* Lionel Mace for some detailed feedback on UX of `try-sat`.
