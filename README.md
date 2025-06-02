# AWS Infrastructure and Kubernetes Demo

## Terraform Setup

The Terraform code to provision AWS infrastructure is located in:

```
aws-infrastructure/
```

## EBS StatefulSet and Backup Demo

EBS and StatefulSet demonstration files are in:

```
ebs-demo/
```

### Folder Structure

- `ebs-demo/ebs`: YAML files to create StatefulSets and EBS volumes.
- `ebs-demo/backup-ebs`: YAML files to demonstrate EBS backup operations.
- `ebs-demo/commands.txt`: Contains CLI commands used during the demo.

## LoadBalancer and Cluster AutoScaler Demo

Deployment YAML files for LoadBalancer and Cluster AutoScaler demo are located in:

```
nginx-deployment/
```
## Demo Images

### Terraform Cloud
This project uses Terraform Cloud as a remote backend to manage and store the state files of AWS resources securely.
![image](https://github.com/user-attachments/assets/8c333f14-0ec0-4dd7-bb3f-9f102183a565)

### IAM Setup
I need an IAM User with permissions to create an EKS cluster.
First, I create an IAM user group and attach the necessary permissions (e.g., for managing EKS, EC2, etc.) to this group.
![image](https://github.com/user-attachments/assets/ad44be64-54cf-4598-8080-f96eafd9b3c7)

Then, I create a User and add it to the group so that the user inherits those permissions.
I will use this IAM User to deploy the EKS cluster.
![image](https://github.com/user-attachments/assets/28ebfff3-0702-44f0-800e-4cc3bf8b9f93)

### Set up a private network for deploying EKS services
I create a **separate VPC (Virtual Private Cloud)** to host the services of the EKS cluster.
The **Kubernetes worker nodes** are placed in **private subnets**, without direct access to the internet.

To access the internet, traffic from the private subnets goes through a **NAT Gateway**, and external requests are received via a **Load Balancer**.

The **NAT Gateway** and **Load Balancer** are placed in **public subnets**, are assigned **public IP addresses**, and connect to the internet through an **Internet Gateway**.

Purpose: This architecture improves security and performance by ensuring that internal services communicate with each other through the private network, rather than over the public internet.
![image](https://github.com/user-attachments/assets/c7e4d1b5-35b3-41c1-86fb-8df473eec4ea)

### Worker Node Group of the EKS Cluster
The image shows the Worker Node Group of the Kubernetes (K8s) cluster.

After multiple attempts and debugging, I discovered that with this configuration, **each node needs to run many pods**, which caused resource limitations.

Initially, I used the `t3.micro` instance type, but it **did not have enough resources** to handle the workload.
After switching to `t3.medium`, the deployment was successful.

![image](https://github.com/user-attachments/assets/0dda994a-8c30-4e26-8fe7-cb9bc6663c22)

### Demo: Cluster Autoscaler
In the image, I initially set the desired node count to 2.
Later, the Cluster Autoscaler automatically detected that **only one node was sufficient** for the current workload, so it **scaled down** the number of nodes to 1.

The lower section of the image shows that **only one node remains active**, confirming that autoscaling worked as expected.

![image](https://github.com/user-attachments/assets/3fba438f-51af-438c-905e-5d1bf05e7d97)

Demo: LoadBalancer
The LoadBalancer is configured to forward requests directly to specific Pods, bypassing the Kube-Proxy.

In the image, it shows that the LoadBalancer is aware of the IP addresses of the individual Pods and will send traffic directly to those Pods.

![image](https://github.com/user-attachments/assets/701266db-d5b0-4bad-b2af-4e596e2e5fd7)

### Billing....
![eks-billing](https://github.com/user-attachments/assets/3ba027f0-247f-419c-b193-0534ae2706a0)
