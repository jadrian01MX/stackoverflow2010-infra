# Shared seed-data storage

`shared.bicep` creates persistent Blob Storage for the Stack Overflow seed BACPAC. It is deliberately separate from the `dev`, `test`, and `prod` resource groups, so an environment destroy workflow cannot remove the seed artifact.

The deployment creates:

- `rg-stackoverflow2010-shared-<location>`
- a Standard, locally redundant (LRS), hot-tier storage account
- a private `database-seed` container
- blob versioning and 30-day blob/container soft delete

Run **Deploy Shared Seed Storage** manually from GitHub Actions before uploading `StackOverflow2010.bacpac`. The storage account name is deterministic from the Azure subscription ID; review the workflow deployment output to obtain it.

The account permits only Microsoft Entra ID (Azure RBAC) access; shared access keys are disabled. Grant your own upload identity `Storage Blob Data Contributor`, and give the GitHub Actions identity only `Storage Blob Data Reader` when the seed-import workflow is added.
