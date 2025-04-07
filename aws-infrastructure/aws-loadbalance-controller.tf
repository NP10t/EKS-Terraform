
// Tạo ra một dữ liệu tạm dạng json (data) chứ không tạo
// ra tài nguyên trên aws (resource)
// Dữ liệu tạm này sẽ được dùng ở nơi khác trong code terraform
// Tạo ra một chính sách mà chỉ có các pod trong EKS mới có thể sử dụng
// chính sách này cho phép pod assume cái role mà policy này gắn vào
// Đây không phải chính sách để cấp quyền mà là chính sách giả định vai trò

// Khi pod chạy k8s gán cho nó một ServiceAccount, pod dùng ServiceAccount này
// để gọi k8s api để get pods...
// hoặc kết nối tới CloudWatch, S3...
data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

// Tạo ra một role có id là aws_lbc
// Ai được phép assume role này? Nhờ có chính sách giả định vai trò
// gắn vào thuộc tính assume_role_policy để xác định ai có thể assume role này
resource "aws_iam_role" "aws_lbc" {
  name               = "${aws_eks_cluster.eks.name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

// Tạo ra policy tên AWSLoadBalancerController
// Policy được nạp lên từ file .json và đẩy lên aws 
resource "aws_iam_policy" "aws_lbc" {
  policy = file("./policies/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

// Gắn policy vừa được đẩy lên aws cho role aws_lbc
resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

// Trao một role cho một ServiceAccount của một Pod 
// AWS Load Balancer Controller sẽ được chạy trong một pod
// pod này cần các quyền để tạo, xóa, cập nhật các load balancer
// như NLB, ALB
resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc.arn
}


// Cài đặt LB Controller trên một pod trong cụm
// Chỉ cho controller biết tên cụm EKS mà nó đang chạy
// Chỉ cho controller biết tên serviceAccount mà nó sẽ sử dụng
// Chỉ cho controller biết VPC mà cụm EKS đang chạy

// Helm chart mặc định đã định nghĩa requests/limits rồi
resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  depends_on = [helm_release.cluster_autoscaler]
}