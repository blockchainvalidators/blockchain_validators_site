locals {
    s3_origin_id = "s3-web-${module.s3_bucket_site.this_s3_bucket_id}"
}

resource "aws_cloudfront_distribution" "site" {
    origin {
        origin_id = local.s3_origin_id
        domain_name = module.s3_bucket_site.this_s3_bucket_website_endpoint
        custom_origin_config {
            http_port               = "80"
            https_port              = "443"
            origin_protocol_policy  = "http-only"
            origin_ssl_protocols    = ["TLSv1.2"]
        }
    }

    enabled = true
    is_ipv6_enabled = true
    price_class = "PriceClass_100"
    aliases = [ var.domain_name ]
    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id
        viewer_protocol_policy = "redirect-to-https"
        compress = true
        forwarded_values  {
            query_string = false

            cookies {
                forward = "none"
            }
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = module.acm.this_acm_certificate_arn
        ssl_support_method = "sni-only"
    }

    logging_config {
        include_cookies = false
        bucket = module.s3_bucket_log.this_s3_bucket_bucket_domain_name
        prefix = "${var.domain_name}/cf/"
    }
}