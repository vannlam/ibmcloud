# Pre-requisite tools

You may skip the installation of all the following tools and use [a pre-built container image](https://github.com/l2fprod/ibmcloud-ci), maintained by Fred Lavigne, that includes most of them already.

To do this, run the Docker image, clone this repo, and run `make install`:
```bash
docker run -it --volume $PWD:/root/mnt/home --workdir /root/mnt/home l2fprod/ibmcloud-ci
git clone https://github.ibm.com/garage-satellite-guild/try-sat.git
cd try-sat
make install
```

Otherwise, the list of pre-requisites you need follows. This list is long-ish, but most of these are tools that either you likely already have, or will be important in this ecosystem.

### Mandatory

*   [IBM Cloud CLI](https://cloud.ibm.com/docs/cli). This should also install `kubectl` (or make sure you have it another way).

*   [oc, the OpenShift CLI](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli). You can also install this on MacOS, assuming you have Homebrew, with `brew install openshift-cli`.

*   Terraform. Please follow the instructions [here](https://github.com/IBM-Cloud/terraform-provider-ibm#using-the-provider) - you can skip steps 5 and 6, they are already covered by other `try-sat` configuration. On MacOS, assuming you have Homebrew, just run `brew install terraform` for Step 1. Terraform tends to be very version sensitive. Please make sure you have v0.14 (if you have `tfswitch` - see below - it should automatically obtain the correct version for you).

*   [jq](https://stedolan.github.io/jq/manual/). On MacOS, assuming you have Homebrew, just run `brew install jq`.

*   [calicoctl](https://github.com/projectcalico/calicoctl). On MacOS, assuming you have Homebrew, just run `brew install calicoctl`.

*   *WireGuard VPN Client*. For MacOS, install from [the Mac OS App Store](https://apps.apple.com/us/app/wireguard/id1451685025?mt=12).

*   Run `make install` to ensure that various IBM Cloud CLI plugins are installed.

### Optional (but useful)

*   [direnv](https://direnv.net/). This makes it easier to use `.envrc`. On MacOS, assuming you have Homebrew, just run `brew install direnv` (recommend then setting up `direnv` as per the man page).

*   [tfswitch](https://tfswitch.warrensbox.com/Install/). This tool makes it easier to make sure you are using the right Terraform version. If it's installed, `try-sat` will use it automatically.
