resource "aws_athena_workgroup" "example" {
    name = "private-isu-workgroup"

    configuration {
        enforce_workgroup_configuration    = true
        result_configuration {
            output_location = "s3://${aws_s3_bucket.lb_logs.bucket}/athena/"
        }
    }
}