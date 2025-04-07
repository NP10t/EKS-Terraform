// Trả về endpoint của API server của EKS

// Terraform lấy khóa công khai của cụm, ghi nhớ nó để sau này terraform
// có thể xác thực rằng cụm EKS mà nó gửi lệnh đến là cụm EKS thật
// Để tránh gửi dữ liệu nhạy cảm đên một cụm EKS giả mạo
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

// Trả về token để chứng minh rằng Terraform có quyền truy cập
// vào cụm (dựa trên vai trò IAM của người dùng chạy Terraform)
data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
