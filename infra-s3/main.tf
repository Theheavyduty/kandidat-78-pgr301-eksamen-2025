# S3-bucket
resource "aws_s3_bucket" "this" {
bucket = var.bucket_name
force_destroy = false # hindrer utilsiktet sletting av data ved destroy
tags = var.tags
}


# Eierskap/ACL (moderne standard uten ACL-er)
resource "aws_s3_bucket_ownership_controls" "this" {
bucket = aws_s3_bucket.this.id
rule {
object_ownership = "BucketOwnerEnforced"
}
}


# Blokker offentlig tilgang (sikker default hei)
resource "aws_s3_bucket_public_access_block" "this" {
bucket = aws_s3_bucket.this.id
block_public_acls = true
block_public_policy = true
ignore_public_acls = true
restrict_public_buckets = true
}


# Versjonering (nyttig ved utilsiktet sletting)
resource "aws_s3_bucket_versioning" "this" {
bucket = aws_s3_bucket.this.id
versioning_configuration {
status = "Enabled"
}
}


# Server-side kryptering (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
bucket = aws_s3_bucket.this.id
rule {
apply_server_side_encryption_by_default {
sse_algorithm = "AES256"
}
}
}


# Lifecycle-konfigurasjon: gjelder KUN for objekter under "midlertidig/"
resource "aws_s3_bucket_lifecycle_configuration" "this" {
bucket = aws_s3_bucket.this.id


rule {
id = "midlertidig-transition-and-expire"
status = "Enabled"


filter {
prefix = var.temp_prefix
}


# Flytt til billigere klasse etter X dager (GLACIER_IR: Instant Retrieval)
transition {
days = var.transition_days
storage_class = "GLACIER_IR"
}


# Slett helt etter Y dager
expiration {
days = var.expiration_days
}


# Rydd opp hengende multipart-uploads
abort_incomplete_multipart_upload {
days_after_initiation = 7
}
}
}