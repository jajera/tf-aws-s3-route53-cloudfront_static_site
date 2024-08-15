# tf-aws-s3-route53-cloudfront_static_site

## build

```bash
terraform -init
```

```bash
domain="mywebsite.nz"
```

```bash
terraform apply --auto-approve -var "domain=${domain}" -target=random_string.suffix
```

```bash
terraform apply --auto-approve -var "domain=${domain}" -target=aws_acm_certificate.web
```

```bash
terraform apply --auto-approve -var "domain=${domain}"
```

## cleanup

```bash
terraform destroy --auto-approve -var "domain=${domain}"
```
