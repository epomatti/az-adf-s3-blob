output "aws_bucket" {
  value = aws_s3_bucket.main.bucket_domain_name
}

output "aws_accesskey_id" {
  value = aws_iam_access_key.azure.id
}

output "aws_accesskey_secret" {
  value = aws_iam_access_key.azure.secret
  sensitive = true
}
