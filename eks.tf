resource "aws_eks_cluster" "eks" {
  name     = "demo-eks"
  role_arn = aws_iam_role.master.arn
  version  = "${var.eks_version}"

  vpc_config {
    subnet_ids = [aws_subnet.public-1.id, aws_subnet.public-2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    # aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    #aws_subnet.pub_sub1,
    #aws_subnet.pub_sub2,
  ]

}

resource "aws_instance" "kubectl-server" {
  ami                         = "ami-0c1ce90bf42d9802b"
  key_name                    = "eks-key"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public-1.id
  vpc_security_group_ids      = [aws_security_group.eks_sg.id]
  tags = {
    Name = "kubectl-server"
  }
}


resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "dev"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = [aws_subnet.public-1.id, aws_subnet.public-2.id]
  capacity_type   = "ON_DEMAND"
  disk_size       = "20"
  instance_types  = ["t2.small"]
  remote_access {
    ec2_ssh_key               = "eks-key"
    source_security_group_ids = [aws_security_group.eks_sg.id]
  }

  labels = tomap({ env = "dev" })

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    #aws_subnet.pub_sub1,
    #aws_subnet.pub_sub2,
  ]
}
