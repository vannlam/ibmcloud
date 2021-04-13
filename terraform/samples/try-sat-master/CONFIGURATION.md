# Once-only configuration

*   Copy `.envrc-template` to `.envrc` (e.g. `cp <where_you_checked_out_this_repo>/.envrc-template <where_you_checked_out_this_repo>/.envrc`).
*   Edit `.envrc` to set a few variable values (explanations are in the file).
*   Before you use any `try-sat` `make` command, you will need to either:

    1.  Run `direnv allow` to use this file via `direnv` (assuming you've installed `direnv` from the [pre-requisites document](PREREQS.md)), or:
    2.  Run `source .envrc` every time you enter this repo's directory and in each new terminal.
