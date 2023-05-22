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

Upload the files to AWS:

```sh
aws s3 sync ./dummydata s3://your-bucket-name 
```
