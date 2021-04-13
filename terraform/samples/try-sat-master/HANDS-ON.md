# Hands-on Method

This approach is potentially faster, if you are babysitting it. You'll also learn a bit more. Sometimes if the simple process fails, you might need to follow parts of this approach. You may benefit from running `make watch` in another terminal window to more easily see progress.

> NOTE: These instructions are not very frequently maintained, and may be a bit out-of-date. If unsure, please refer to what the `all_public` or `all_private` targets do [in the Makefile](https://github.ibm.com/garage-satellite-guild/try-sat/blob/master/Makefile).

*   Ensure you have completed the [once-only configuration](CONFIGURATION.md), and have run `source .envrc` if you are not using `direnv`.

*   Run `make create_location` to create the Satellite location. Current experience is that this will appear to initially fail; see [here](https://ibm-garage.slack.com/archives/C01149RMSCU/p1611859911187000) for information; nevertheless it will be being created.

*   Run `make apply_terraform`. This will create the VSIs and associated infrastructure for the Satellite Control Plane and Worker Nodes, and run the attach script against each host to attach them to the Satellite location. Wait until you see the nodes attach and change to Ready status.

*   Run `make setup_dns_controlplane`. Then wait until you see the new subdomains take effect in your watch window (the watch command does not appear to be reliable and sometimes the output will disappear for this section). In my experience, this may take a few minutes to several hours.

*   Run `make assign_controlplane`. This will set up the control plane. Then wait until you see the Location Message `R0001: The Satellite location is ready for operations.`.

*   Run `make setup_dns_controlplane`. Sometimes the new subdomains disappear again and revert to the original ones after the assign step above, and this step will be needed again. It's unclear why this unreliability happens.

*   Run `make create_cluster`. This will set up the initial OpenShift cluster master node infrastructure. Then wait for the cluster to move into Warning status.

*   Run `make setup_calico`. This will setup the calico networking rules on the cluster.

*   Run `make setup_network_cluster`. This will run post-setup steps to ensure the cluster networking is configured so it can be externally accessed. Wait until the NLB info shows the new IP address is mapped in the watch window.

*   Run `make assign_workernodes`. This will add worker nodes to the cluster. Wait until your satellite hosts are all listed as `Status=Ready, State=assigned` and the cluster is in state `normal`.

*   Run `make setup_network_cluster`. Sometimes the cluster NLB info will revert back to the internal VSI IPs, and this step will be needed again. It's unclear why this unreliability happens.
