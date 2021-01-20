provider "aws" {
  region = "us-east-1"
  profile = "terraform-operator"
}

locals {
  bucket = var.domain_name
  bucket_name = var.domain_name
}


# log bucket
module "s3_bucket_log" {
  source                        = "terraform-aws-modules/s3-bucket/aws"
  version                       = "1.17.0"
  bucket             = "${local.bucket_name}-logs"
  acl                           = "log-delivery-write"
  block_public_acls             = true
  block_public_policy           = true
  ignore_public_acls            = true
  restrict_public_buckets       = true
}

data "aws_iam_policy_document" "s3_bucket_site" {
  statement {
    sid = "1"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

# site bucket
module "s3_bucket_site" {
  source                        = "terraform-aws-modules/s3-bucket/aws"
  version                       = "1.17.0"
  bucket             = local.bucket_name
  acl                           = "public-read"
  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_bucket_site.json
  website = {
      index_document = "index.html"
      error_document = "error.html"
  }
  logging ={
      target_bucket = module.s3_bucket_log.this_s3_bucket_id
      target_prefix = "${var.domain_name}/s3/root"
  }
  block_public_acls             = false
  block_public_policy           = false
  ignore_public_acls            = false
  restrict_public_buckets       = false
}

data "aws_iam_policy_document" "s3_bucket_www" {
  statement {
    sid = "1"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::www.${local.bucket_name}/*",
    ]
  }
}

# www bucket
module "s3_bucket_www" {
  source                        = "terraform-aws-modules/s3-bucket/aws"
  version                       = "1.17.0"
  bucket             = "www.${local.bucket_name}"
  acl                           = "public-read"
  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_bucket_www.json
  website = {
      redirect_all_requests_to = var.domain_name
  }
  logging ={
      target_bucket = module.s3_bucket_log.this_s3_bucket_id
      target_prefix = "${var.domain_name}/s3/root"
  }
  block_public_acls             = true
  block_public_policy           = true
  ignore_public_acls            = true
  restrict_public_buckets       = true
}