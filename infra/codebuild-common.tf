# To build the container, we need the following components:
# 1. An ECR repository to store the built image in.
# 2. A CodeBuild job to build and push the container. The build steps are defined in the buildspec.yml file.
# 3. An IAM policy that the build runs as with access to create images and push to ECR.
# 4. A webhook to receive notifications when commits are pushed to GitHub.

data "template_file" "codebuild_policy" {
  template = "${file("templates/codebuild_iam_policy.json")}"

  vars = {
    codepipeline_bucket_arn = "${aws_s3_bucket.webinar_source.arn}"
    codepipeline_bucket_arn_new = "${aws_s3_bucket.webinar_source_new.arn}"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role"
  assume_role_policy = "${file("templates/codebuild_iam_role_policy.json")}"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild-policy"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}
