# Caveats and Disclaimers

*   This is still *very much alpha*, and not widely tested. It is in *no way official*, and there is no support. It may break for you, and this should not be shared with customers in its current form. Feedback welcome as issues/pull requests on this Git repository, please.

*   This has not been fully evaluated from a security perspective. Depending on the path you choose, the cluster itself may be public. Do not put anything sensitive on this cluster or location.

*   It's very CLI/automation-focused, not GUI-focused. If you are interested in the guts of how it works/want to hack on it, most of the work is done by the Makefile/Terraform recipe.

*   This has been developed on MacOS. It may work on Linux. It is unlikely to work on Windows, except perhaps WSL. Feedback welcome on how to make it more cross-platform.

*   The 'private' method for deploying cannot support an automated Cloud Pak installation. See [here](https://ibm-garage.slack.com/archives/C01149RMSCU/p1617873885312400) for discussion thread.

*   `try-sat` does not currently support system languages/locales other than English, it forces English in the Makefile to be able to parse the output of `ibmcloud`. See [this bug](https://github.ibm.com/garage-satellite-guild/try-sat/issues/82) for more.
