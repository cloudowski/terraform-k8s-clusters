output k8s_context {
  value = local.k8s_context
}

output vpc_id {
  value = module.aws_vpc.vpc_id
}

output public_subnets {
  value = module.aws_vpc.public_subnets
}

output private_subnets {
  value = module.aws_vpc.private_subnets
}
