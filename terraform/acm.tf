# reference source https://github.com/terraform-aws-modules/terraform-aws-acm/blob/master/examples/complete-dns-validation/main.tf
locals { 
    use_existing_route53_zone = true
    domain = var.domain_name
    domain_name = trimsuffix(local.domain, ".")
}

data "aws_route53_zone" "this" {
    count = local.use_existing_route53_zone ? 1 : 0
    name = local.domain_name
    private_zone = false
}

resource "aws_route53_zone" "this" {
    count = ! local.use_existing_route53_zone ? 1 : 0
    name = local.domain_name
}

module "acm" {
    source = "terraform-aws-modules/acm/aws"
    version = "~> v2.0"

    domain_name = local.domain_name
    zone_id = coalescelist(data.aws_route53_zone.this.*.zone_id, aws_route53_zone.this.*.zone_id)[0]
    subject_alternative_names = [
        "*.${local.domain_name}"
    ]

    wait_for_validation = true
    tags = {
        name = local.domain_name
        terraform = "true"
    }
}