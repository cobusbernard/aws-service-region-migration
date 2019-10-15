output "alb_dns" {
  value = "${aws_alb.webinar_alb.dns_name}"
}

output "alb_dns_new" {
  value = "${aws_alb.webinar_alb_new.dns_name}"
}