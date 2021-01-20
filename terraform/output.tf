output "s3_bucket_site" {
    value = "s3://${module.s3_bucket_site.this_s3_bucket_id}=us-east-1"
    description = "Use this for the URL in the HUGO config.toml file"
}

output "cloudFront_Distribution_id" {
    value = aws_cloudfront_distribution.site.id
    description = "Use this for the cloudFrontDistributionID value in the HUGO config.toml file"
}