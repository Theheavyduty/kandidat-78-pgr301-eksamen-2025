output "bucket_name" {
description = "Navn på S3-bucketen."
value = aws_s3_bucket.this.bucket
}


output "bucket_arn" {
description = "ARN for S3-bucketen."
value = aws_s3_bucket.this.arn
}


output "region" {
description = "Region som provider bruker."
value = var.aws_region
}


output "lifecycle_rule_id" {
description = "ID for lifecycle-regelen (midlertidige filer)."
value = aws_s3_bucket_lifecycle_configuration.this.rule[0].id
}