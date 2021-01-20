# blockchain_validators_site

This a quick rundown demonstrating how to create a blog using [Hugo](https://gohugo.io/), [AWS](https://aws.amazon.com/) (S3, ACM and Cloudfront) and [Terraform](https://www.terraform.io/).  I may update this later with more Terraform and HUGO details.

Similar to the validator builds, there is a docker-compose file that creates two containers.  One for the AWS CLI and the other for Terraform.  The Terraform container leverages the terraform-operator AWS CLI profile.

The docker-compose file:

```yaml
version : '3.7'

services:
    aws:
        image: amazon/aws-cli:2.1.3
        volumes:
            - .:/code
            - aws-creds:/root/.aws
        restart: "no"
        working_dir: /code
        entrypoint: aws
        environment:
            AWS_PROFILE: terraform-operator

    terraform:
        image: hashicorp/terraform:0.14.3
        volumes:
            - .:/code
            - aws-creds:/root/.aws
        working_dir: /code
        environment:
            AWS_PROFILE: terraform-operator
volumes:
    aws-creds:
        name: aws-creds
```

Run docker-compose to create the containers.

```bash
docker-compose up
```

The site uses [AWS ACM](https://aws.amazon.com/certificate-manager/), [Cloudfront](https://aws.amazon.com/cloudfront/) and [s3 buckets](https://aws.amazon.com/s3/).  Three s3 buckets are used for the site.  One for the HUGO files, another to redirect http requests, and the last for logging.

Donwload the code from [github]().  Before running terraform, update ./terraform/infrastructure/terraform.tfvars with your domain name.  For example, this site would use blockchainvalidators.io for the domain name.

```json
domain_name = "DOMAIN_NAME_GOES_HERE"
```

To build the site run the follwoing Terraform commands.

Terraform init to initialize the project.
```bash
docker-compose run --rm terraform init
```

Terraform plan to view what is being built.
```bash
docker-compose run --rm terraform plan
```

Terraform apply and then *yes* to build the infrastructure.
```bash
docker-compose run --rm terraform apply
```

Terraform will produce the following information from the output.tf file that is needed for the HUGO deployment.

```bash
cloudFront_Distribution_id = "XXXXXXXX"
s3_bucket_site = "s3://DOMAIN_NAME?region=us-east-1"
```

Use these values in the HUGO config.toml file.  There are many tutorials for using HUGO.  I followed the official [quick start](https://gohugo.io/getting-started/quick-start/).  Once the blog is ready, update the config.toml with the deployer information as follows.  I typically add these lines to the end of the config.toml file.

```
[deployment]
  [[deployment.targets]]
    name = "s3"
    URL = "s3://DOMAIN_NAME?region=us-east-1"
    cloudFrontDistributionID = "XXXXXXXX"
```


Deploy the code using HUGO.

```bash
cd ./site
hugo deploy --maxDeletes -1 --invalidateCDN --confirm
```

Go check your blog is online.