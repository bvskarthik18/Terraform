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
```ruby
.
├── main.tf                # Main file that ties the modules together
├── README.md              # Documentation of the setup
├── subnet-module/         # Module to create subnets
│   ├── subnets.tf         # Defines subnets, internet gateway, and route table
│   └── variables.tf       # Variables used by the subnet module
├── vpc-module/            # Module to create VPC
│   ├── vpc.tf             # Defines the VPC
│   └── variables.tf       # Variables used by the VPC module
```


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

- `cidr_block`: The IP range for the VPC, defined by the variable cidr.
- `tags`: Assigns a Name tag to the VPC using the `vpc_name` variable.
- `Output`: The VPC ID is exposed to be used in other modules.

## **File: `vpc-module/variables.tf`**
Here, we define the input variables that will be used in the VPC creation.

```hcl
variable "cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "my_vpc"
}
```

- `cidr`: The default CIDR block for the VPC.
- `vpc_name`: The name to assign to the VPC.

## **Step 2: Defining the Subnet Module**
## **File: `subnet-module/subnets.tf`**
This file defines the creation of multiple subnets. The module is flexible and allows you to create subnets in different Availability Zones.

```hcl
resource "aws_subnet" "my_subnets" {
  for_each = var.subnets
  tags = {
    Name = "${each.key}"
  }
  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.my_subnets[keys(aws_subnet.my_subnets)[0]].id
  route_table_id = aws_route_table.public_rt.id
}

```
- `Subnets`: This uses for_each to iterate over the subnets variable and create a subnet for each entry.
- `Internet Gateway`: We create an Internet Gateway (IGW) and associate it with the VPC.
- `Route Table`: A public route table is created, with a default route to the IGW.
- `Route Table Association`: The first subnet is associated with the public route table, allowing internet access.

## **File: `subnet-module/variables.tf`**
The variables defined in variables.tf are used to pass the necessary data into the module.

```hcl
variable "vpc_id" {}

variable "subnets" {}

```
- `vpc_id`: The ID of the VPC to which these subnets will be attached.
- `subnets`: A map containing the subnet details like CIDR block and Availability Zone.

## **Step 3: Main Terraform Configuration**
## **File: `main.tf`**
In the main.tf file, we instantiate both the VPC and the Subnet modules. This ties everything together and passes necessary inputs between the modules.
```hcl
module "aws_vpc" {
  source = "./vpc-module"
}

module "aws_subnet" {
  source   = "./subnet-module"
  vpc_id   = module.aws_vpc.my_vpc_id
  subnets = {
    subnet-1 = {
      cidr_block = "10.0.1.0/24"
      az         = "ca-central-1a"
    }
    subnet-2 = {
      cidr_block = "10.0.2.0/24"
      az         = "ca-central-1b"
    }
    subnet-3 = {
      cidr_block = "10.0.3.0/24"
      az         = "ca-central-1d"
    }
  }
}

```
- `VPC Module`: The aws_vpc module is called to create the VPC, and we output its ID to pass it to the subnet-module.
- `Subnet Module`: The aws_subnet module is called to create the subnets. The subnets map contains details about each subnet, such as CIDR block and AZ.

## **Step 4: Running Terraform**
Once you have all the files in place, follow these steps to apply the configuration:

1. Initialize the Terraform configuration:

```bash
terraform init
```
2. Validate the configuration:

```bash
terraform validate
```
3. Apply the configuration:
```bash
 terraform apply
```
Terraform will show a plan with all the changes that will be made. If everything looks good, type `yes` to proceed with the creation of the resources.

## **Step 5: Conclusion**
In this blog post, we demonstrated how to create a reusable Terraform configuration that defines a VPC and multiple subnets across different Availability Zones. By organizing the code into modules, we made the infrastructure scalable and easy to maintain.

Terraform allows you to quickly stand up infrastructure on AWS and other cloud providers with just a few simple commands. This modular approach ensures that our infrastructure is maintainable and adaptable to different use cases.
