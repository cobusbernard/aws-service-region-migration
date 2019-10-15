# To make use of CodePipeline, we will need a few components:
# 1. CodeBuild job (we already have one)
# 2. IAM role for CodePipeline to execute as
# 2. An S3 bucket to store the source code into
# 3. An ECS cluster to deploy to (which we already have)

resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline-role"
  assume_role_policy = "${file("templates/codepipeline_iam_role_policy.json")}"
}

data "template_file" "codepipeline_policy" {
  template = "${file("templates/codepipeline_iam_policy.json")}"

  vars = {
    codepipeline_bucket_arn = "${aws_s3_bucket.webinar_source.arn}"
    codepipeline_bucket_arn_new = "${aws_s3_bucket.webinar_source_new.arn}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}
