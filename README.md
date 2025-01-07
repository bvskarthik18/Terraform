# **Creating a VPC with Subnets in AWS using Terraform Modules**

In this blog post, we'll walk you through how to create a Virtual Private Cloud (VPC) with subnets in AWS using Terraform modules. This setup involves:

- A **VPC** that defines the network.
- Multiple **subnets** spread across different Availability Zones (AZs).
- An **Internet Gateway** (IGW) to allow internet access.
- A **Route Table** for managing the routing of traffic.

The code is modularized using Terraform, making it reusable and easy to manage. Let's break down each component.

---

## **Project Structure**

Here’s a quick overview of the project structure:

. ├── main.tf # Main file that ties the modules together ├── README.md # Documentation of the setup ├── subnet-module/ # Module to create subnets │ ├── subnets.tf # Defines subnets, internet gateway, and route table │ └── variables.tf # Variables used by the subnet module ├── vpc-module/ # Module to create VPC │ ├── vpc.tf # Defines the VPC │ └── variables.tf # Variables used by the VPC module


In this tutorial, we'll focus on each of these files, and explain their purpose in detail.

---

## **Step 1: Defining the VPC Module**

### **File: `vpc-module/vpc.tf`**

The `vpc.tf` file defines the creation of the VPC resource. We use a simple `aws_vpc` resource to create a VPC within the provided CIDR block and name.

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr

  tags = {
    Name = var.vpc_name
  }
}

output "my_vpc_id" {
  value = aws_vpc.my_vpc.id
}
```

cidr_block: The IP range for the VPC, defined by the variable cidr.
tags: Assigns a Name tag to the VPC using the vpc_name variable.
Output: The VPC ID is exposed to be used in other modules.

File: vpc-module/variables.tf
Here, we define the input variables that will be used in the VPC creation.

```hcl
variable "cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "my_vpc"
}
```

cidr: The default CIDR block for the VPC.
vpc_name: The name to assign to the VPC.
