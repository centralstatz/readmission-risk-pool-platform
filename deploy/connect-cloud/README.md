# Generated Readmission Risk Pool Connect Cloud repository

This repository is a disposable generated deployment realization. Its source
of truth is the clean `readmission-risk-pool-platform` repository and the
embedded validated reduced application artifact. Do not maintain application
or product changes here; regenerate the repository from the platform instead.

The repository is intentionally local, remote-free, and uncommitted. Generated
files are staged on branch `main`. Before external publication, an operator
must review the repository, commit using their own Git identity, choose and
create an appropriate remote, configure that remote, and push. The operator may
then authorize Posit Connect Cloud to read that repository and select `app.R`
as the primary file.

Run the independent local validation before publication:

```sh
Rscript validate-connect-cloud.R
```

`manifest.json` is generated for Posit Connect Cloud and is colocated with the
root `app.R`. The deployment-specific `renv.lock` is pruned to the artifact's
Shiny/YAML dependency closure and is retained as reproducible generator input;
Connect Cloud consumes `manifest.json`, not that lock, to establish R. The
unchanged target-neutral artifact is under `artifact/`.

This repository contains fictional, nonclinical demonstration data. It makes
no security, compliance, privacy, clinical, production-fitness, hosting, or
service-availability claim. Real hospital deployment remains subject to the
adopter's infrastructure, privacy, security, access-control, networking, and
governance requirements.
