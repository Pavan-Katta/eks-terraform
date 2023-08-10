variable "location"{
    type = string
    description = "used for selecting the loaction"
    default = "eu-west-2"
}
variable "vpc_cidr_block"{
    type        = string
    description = "used to assign ip address for vpc"
}
variable "subnet1_cidr_block"{
    type        = string
    description = "used to assign ip address for subnet1"
}
variable "subnet2_cidr_block"{
    type        = string
    description = "used to assign ip address for subnet2"
}
variable "route_cidr_block"{
    type        = string
    description = "used to assign network traffic"
}
variable "sg_protocol"{
    type        = string
    description = "used to assign sg protocol"
}
variable "eks_version"{
    type        = string
    description = "used to assign proper version to eks"
}