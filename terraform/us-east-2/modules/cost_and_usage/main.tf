resource "aws_s3_bucket" "cur_bucket" {
  bucket = "my-cost-usage-report"
}

resource "aws_cur_report_definition" "cur" {
  report_name            = "cost_and_usage_report"
  time_unit              = "HOURLY"
  format                 = "textORcsv"
  compression            = "GZIP"
  s3_bucket              = aws_s3_bucket.cur_bucket.bucket
  s3_prefix              = "reports"
  s3_region              = "us-east-2"
  additional_schema_elements = ["RESOURCES"]
  refresh_closed_reports = true
  report_versioning      = "CREATE_NEW_REPORT"
  billing_view_arn       = data.aws_billing_service_account.main.arn
}

resource "aws_athena_database" "cost_usage" {
  name   = "cost_usage_db"
  bucket = aws_s3_bucket.cur_bucket.bucket
}

resource "aws_athena_table" "cur_table" {
  database = aws_athena_database.cost_usage.name
  name     = "cur"
  bucket   = aws_s3_bucket.cur_bucket.bucket
  query    = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS ${self.database}.${self.name} (
  `identity` struct<TimeInterval:string, ProductName:string, ...>
  ... other fields here ...
) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ','
) LOCATION 's3://${self.bucket}/reports/'
EOF
}
