# Azure Data Factory

Copying files from AWS S3 to Azure Blob (ADLS Gen2) using ADF.

Create the infrastructure:

```sh
terraform -chdir="infra" init
terraform -chdir="infra" apply -auto-approve
```

Generate the dummy data:

```sh
bash generateDummyData.sh
```

Upload the files to AWS S3:

```sh
# Change the bucket name
aws s3 sync ./dummydata s3://YOUR_BUCKET/data

# List objects
aws s3 ls s3://YOUR_BUCKET --recursive --human-readable --summarize
```
