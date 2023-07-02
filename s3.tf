# aws_s3_bucket
resource "aws_s3_bucket" "nginx" {
  bucket        = local.s3_bucket_name
  force_destroy = true
  tags          = local.common_tags
}

# aws_s3_policy
resource "aws_s3_bucket_policy" "nginx" {
  bucket = aws_s3_bucket.nginx.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.nginx.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}"
    }
  ]
}
POLICY
}

# aws_s3_object
resource "aws_s3_object" "website_index" {
  bucket = aws_s3_bucket.nginx.bucket
  key    = "/website/index.html"
  source = "./website/index.html"
  tags   = local.common_tags
}

resource "aws_s3_object" "website_image" {
  bucket = aws_s3_bucket.nginx.bucket
  key    = "/website/Globo_logo_Vert.png"
  source = "./website/Globo_logo_Vert.png"
  tags   = local.common_tags
}