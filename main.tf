terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.40.0"
    }
  }
}

# need to set tokens later
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  access_key = var.aws_access_key_id
  secret_key = var.aws_secrey_access_key
}

# bucket where the data lives
resource "aws_s3_bucket" "input_bucket" {
  bucket = "${var.app_name}-input"
  acl    = "private"
  tags = {
    environment = "production"
  }

  versioning {
    enabled = true
  }
}

# bucket where the query result output lives
resource "aws_s3_bucket" "output_bucket" {
  bucket = "${var.app_name}-output"
  acl    = "private"
  tags = {
    environment = "production"
  }

  versioning {
    enabled = true
  }
}

# workgroup defines where output goes
resource "aws_athena_workgroup" "workgroup" {
  name = var.app_name
  description = "${var.app_name} workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.output_bucket.bucket}/output/"
    }
  }
}

# create a glue database for objects in the bucket
resource "aws_glue_catalog_database" "craas" {
  name = var.app_name
}

resource "aws_glue_catalog_table" "craas_links" {
  name          = "links"
  database_name = aws_glue_catalog_database.craas.name

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    location = "s3://${aws_s3_bucket.input_bucket.bucket}"
    input_format = "json"

    columns {
      name = "cname"
      type = "string"
    }

    columns {
      name = "redirect_to"
      type = "string"
    }

    columns {
      name = "redirect_by"
      type = "smallint"
    }
  }
}

