# Infrastructure as Code - Terraform :

### + Preface :

    A long time ago, in a datacenter far, far away, an ancient group of powerful beings known as “sysadmins” used to deploy infrastructure manually.
    Every server, every database, every load balancer, and every bit of network configuration was created and managed by hand.
    It was a dark and fearful age: fear of downtime, fear of accidental misconfiguration, fear of slow and fragile deployments,
    and fear of what would happen if the sysadmins fell to the dark side (i.e., took a vacation). The good news is that thanks to the DevOps movement,
    there is now a better way to do things: Terraform.

    Terraform is an open source tool created by HashiCorp that allows you to define your infrastructure as code using a simple,
    declarative language and to deploy and manage that infrastructure across a variety of public cloud providers
    (e.g., Amazon Web Services, Microsoft Azure, Google Cloud Platform, DigitalOcean) and private cloud and virtualization platforms
    (e.g., OpenStack, VMWare) using a few commands. For example, instead of manually clicking around a web page or running dozens
    of commands, here is all the code it takes to configure a server on AWS:

    provider "aws" {
        region = "us-east-2"
    }

    resource "aws_instance" "example" {
        ami           = "ami-0c55b159cbfafe1f0"
        instance_type = "t2.micro"
    }

    -> name it main.tf

    And to deploy it, you just run the following:

    $ terraform init
    $ terraform apply

    - Why the author wrote that book :

    Terraform is a relatively new technology. As of May 2019, it has not yet hit a 1.0.0 release yet, and despite Terraform’s growing popularity,
    it’s still difficult to find books, blog posts, or experts to help you master the tool. The official Terraform documentation does a good
    job of introducing the basic syntax and features, but it includes little information on idiomatic patterns, best practices, testing,
    reusability, or team workflows. It’s like trying to become fluent in French by studying only the vocabulary but not any of the grammar or idioms.

### + Chapter 1. Why Terraform

    - What Is Infrastructure as Code?

    The idea behind infrastructure as code (IAC) is that you write and execute code to define, deploy, update, and destroy your infrastructure.

    + There are five broad categories of IAC tools:

    1- Ad hoc scripts
    2- Configuration management tools
    3- Server templating tools
    4- Orchestration tools
    5- Provisioning tools

    1- Ad hoc scripts :

    The most straightforward approach to automating anything is to write an ad hoc script. You take whatever task you were doing manually,
    break it down into discrete steps, use your favorite scripting language (e.g., Bash, Ruby, Python) to define each of those steps in code,
    and execute that script on your server.

    -> open a file setup-webserver.sh

    # Update the apt-get cache
    sudo apt-get update

    # Install PHP and Apache
    sudo apt-get install -y php apache2

    # Copy the code from the repository
    sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app

    # Start Apache
    sudo service apache2 start

    - Pros/Cons of using Ad hoc script :

    + If you’ve ever had to maintain a large repository of Bash scripts, you know that it almost always devolves into a mess of unmaintainable spaghetti code.
      Ad hoc scripts are great for small, one-off tasks, but if you’re going to be managing all of your infrastructure as code,
      then you should use an IaC tool that is purpose-built for the job.


    2- Configuration Management Tools :

    Chef, Puppet, Ansible, and SaltStack are all configuration management tools, which means that they are designed to install and manage software on existing servers.
    For example, here is an Ansible Role called web-server.yml that configures the same Apache web server as the setup-webserver.sh script:

    - name: Update the apt-get cache
      apt:
        update_cache: yes

    - name: Install PHP
      apt:
        name: php

    - name: Install Apache
      apt:
        name: apache2

    - name: Copy the code from the repository
      git: repo=https://github.com/brikis98/php-app.git dest=/var/www/html/app

    - name: Start Apache
      service: name=apache2 state=started enabled=yes

    The code looks similar to the Bash script, but using a tool like Ansible offers a number of advantages:

    - Coding conventions :

    Ansible enforces a consistent, predictable structure, including documentation, file layout, clearly named parameters,
    secrets management, and so on. While every developer organizes their ad hoc scripts in a different way,
    most configuration management tools come with a set of conventions that makes it easier to navigate the code.

    - Idempotence :

    Writing an ad hoc script that works once isn’t too difficult; writing an ad hoc script that works correctly even if you run it over and over again is a lot more difficult. Every time you go to create a folder in your script,
    you need to remember to check whether that folder already exists; every time you add a line of configuration to a file, you need to check that line doesn’t already exist; every time you want to run an app, you need to check
    that the app isn’t already running.

    Code that works correctly no matter how many times you run it is called idempotent code. To make the Bash script from the previous section idempotent, you’d need to add many lines of code, including lots of if-statements.
    Most Ansible functions, on the other hand, are idempotent by default. For example, the web-server.yml Ansible role will install Apache only if it isn’t installed already and will try to start the Apache web server only
    if it isn’t running already.

    - Distribution

    Ad hoc scripts are designed to run on a single, local machine. Ansible and other configuration management tools are designed specifically for managing large numbers of remote servers,
    as shown in Figure 1-2.

![](./static/ansible_install_distribution.png)

    For example, to apply the web-server.yml role to five servers, you first create a file called hosts that contains the IP addresses of those servers:

    -> create a file with hosts name.

    [webservers]
    11.11.11.11
    11.11.11.12
    11.11.11.13
    11.11.11.14
    11.11.11.15

    -> next you define the ansible playbook :

    $ create a file playbook.yml

    - hosts: webservers
      roles:
      - webserver

    $ ansible-playbook playbook.yml

    NB: This instructs Ansible to configure all five servers in parallel. Alternatively, by setting a parameter called serial in the playbook,
        you can do a rolling deployment, which updates the servers in batches. For example, setting serial to 2 directs Ansible to update two
        of the servers at a time, until all five are done. Duplicating any of this logic in an ad hoc script would take dozens or even hundreds of lines of code.

    - Server Templating Tools :

    An alternative to configuration management that has been growing in popularity recently are server templating tools such as Docker, Packer, and Vagrant.
    Instead of launching a bunch of servers and configuring them by running the same code on each one, the idea behind server templating tools is to create an
    image of a server that captures a fully self-contained “snapshot” of the operating system (OS), the software, the files, and all other relevant details.
    You can then use some other IaC tool to install that image on all of your servers, as shown in Figure 1-3.

![](/static/packer_server_templating.png)

    =+ As shown in Figure 1-4, there are two broad categories of tools for working with images:

    - Virtual Machines
    - Containers

![](./static/vm-vs-containers.png)

    For example, here is a Packer template called web-server.json that creates an Amazon Machine Image (AMI), which is a VM image that you can run on AWS:

    {
      "builders": [{
        "ami_name": "packer-example",
        "instance_type": "t2.micro",
        "region": "us-east-2",
        "type": "amazon-ebs",
        "source_ami": "ami-0c55b159cbfafe1f0",
        "ssh_username": "ubuntu"
      }],
      "provisioners": [{
        "type": "shell",
        "inline": [
          "sudo apt-get update",
          "sudo apt-get install -y php apache2",
          "sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app"
        ],
        "environment_vars": [
          "DEBIAN_FRONTEND=noninteractive"
        ]
      }]
    }

    + Pre-requisites :

    - You must have Packer installed on your computer.
    - You must have an Amazon Web Services (AWS) account.

    + Configure your AWS access keys as environment variables:

        export AWS_ACCESS_KEY_ID=(your access key id)
        export AWS_SECRET_ACCESS_KEY=(your secret access key)

    To build the AMI:

    $ packer build webserver.json

    This Packer template configures the same Apache web server that you saw in setup-webserver.sh using the same Bash code.4
    The only difference between the preceding code and previous examples is that this Packer template does not start
    the Apache web server (e.g., by calling sudo service apache2 start). That’s because server templates are typically
    used to install software in images, but it’s only when you run the image—for example, by deploying it on a server—that
    you should actually run that software.

    Note that the different server templating tools have slightly different purposes. Packer is typically used to create images that
    you run directly on top of production servers, such as an AMI that you run in your production AWS account.
    Vagrant is typically used to create images that you run on your development computers, such as a VirtualBox image that you
    run on your Mac or Windows laptop. Docker is typically used to create images of individual applications.
    You can run the Docker images on production or development computers, as long as some other tool has configured that computer with the Docker Engine.

    - Docker + Packer -> cluster of servers on aws :

    For example, a common pattern is to use Packer to create an AMI that has the Docker Engine installed, deploy that AMI on a cluster of servers in your AWS account,
    and then deploy individual Docker containers across that cluster to run your applications.

    4- Orchestration Tools :

    + Server templating tools are great for creating VMs and containers, but how do you actually manage them? For most real-world use cases, you’ll need a way to do the following:

    1- Deploy VMs and containers, making efficient use of your hardware.
    2- Roll out updates to an existing fleet of VMs and containers using strategies such as rolling deployment, blue-green deployment, and canary deployment.
    3- Monitor the health of your VMs and containers and automatically replace unhealthy ones (auto healing).
    4- Scale the number of VMs and containers up or down in response to load (auto scaling).
    5- Distribute traffic across your VMs and containers (load balancing).
    6- Allow your VMs and containers to find and talk to one another over the network (service discovery).

    - Tooling :

    Handling these tasks is the realm of orchestration tools such as Kubernetes, Marathon/Mesos, Amazon Elastic Container Service (Amazon ECS), Docker Swarm, and Nomad.
    For example, Kubernetes allows you to define how to manage your Docker containers as code. You first deploy a Kubernetes cluster, which is a group of servers that
    Kubernetes will manage and use to run your Docker containers. Most major cloud providers have native support for deploying managed Kubernetes clusters, such as
    Amazon Elastic Container Service for Kubernetes (Amazon EKS), Google Kubernetes Engine (GKE), and Azure Kubernetes Service (AKS).


    -> create a file and name it deployment.yml :

    apiVersion: apps/v1

    # Use a Deployment to deploy multiple replicas of your Docker
    # container(s) and to declaratively roll out updates to them
    kind: Deployment

    # Metadata about this Deployment, including its name
    metadata:
      name: example-app

    # The specification that configures this Deployment
    spec:
      # This tells the Deployment how to find your container(s)
      selector:
        matchLabels:
          app: example-app

      # This tells the Deployment to run three replicas of your
      # Docker container(s)”
      replicas: 3

      # Specifies how to update the Deployment. Here, we
      # configure a rolling update.
      strategy:
        rollingUpdate:
          maxSurge: 3
          maxUnavailable: 0
        type: RollingUpdate

      # This is the template for what container(s) to deploy
      template:

        # The metadata for these container(s), including labels
        metadata:
          labels:
            app: example-app

        # The specification for your container(s)
        spec:
          containers:

            # Run Apache listening on port 80
            - name: example-app
              image: httpd:2.4.39
              ports:
                 - containerPort: 80


    - This file instructs Kubernetes to create a Deployment, which is a declarative way to define:

    + One or more Docker containers to run together. This group of containers is called a Pod. The Pod defined in the preceding code contains a single Docker container that runs Apache.

    + The settings for each Docker container in the Pod. The Pod in the preceding code configures Apache to listen on port 80.

    + How many copies (aka replicas) of the Pod to run in your cluster. The preceding code configures three replicas. Kubernetes automatically figures out where in your cluster to deploy each Pod,
    using a scheduling algorithm to pick the optimal servers in terms of high availability (e.g., try to run each Pod on a separate server so a single server crash doesn’t take down your app),
    resources (e.g., pick servers that have available the ports, CPU, memory, and other resources required by your containers), performance (e.g., try to pick servers with the least load and fewest containers on them),
    and so on.

    + Kubernetes also constantly monitors the cluster to ensure that there are always three replicas running, automatically replacing any Pods that crash or stop responding.

    + How to deploy updates. When deploying a new version of the Docker container, the preceding code rolls out three new replicas, waits for them to be healthy, and then undeploys the three old replicas.

    ++ That’s a lot of power in just a few lines of YAML! You run kubectl apply -f example-app.yml to instruct Kubernetes to deploy your app. You can then make changes to the YAML file and run kubectl apply again to roll out the updates.

    5- Provisioning Tools :

    Whereas configuration management, server templating, and orchestration tools define the code that runs on each server, provisioning tools such as Terraform, CloudFormation, and OpenStack Heat are responsible for creating the servers themselves.
    In fact, you can use provisioning tools to not only create servers, but also databases, caches, load balancers, queues, monitoring, subnet configurations, firewall settings, routing rules, Secure Sockets Layer (SSL) certificates,
    and almost every other aspect of your infrastructure.

    For example, the following code deploys a web server using Terraform:

    Don’t worry if you’re not yet familiar with some of the syntax. For now, just focus on two parameters:

    ami
    This parameter specifies the ID of an AMI to deploy on the server. You could set this parameter to the ID of an AMI built from the web-server.json Packer template in the previous section, which has PHP, Apache, and the application source code.

    user_data
    This is a Bash script that executes when the web server is booting. The preceding code uses this script to boot up Apache.

![](./static/terraform_provisionning_schema.png)

    +++ The Benefits of Infrastructure as Code :

    The answer is that code is powerful. In exchange for the upfront investment of converting your manual practices to code, you get dramatic improvements in your ability to deliver software. According to the 2016 State of DevOps Report,
    organizations that use DevOps practices, such as IaC, deploy 200 times more frequently, recover from failures 24 times faster, and have lead times that are 2,555 times lower.


    +++ How IaC improve software delivery process :

    Self-service
    Most teams that deploy code manually have a small number of sysadmins (often, just one) who are the only ones who know all the magic incantations to make the deployment work and are the only ones with access to production.
    This becomes a major bottleneck as the company grows. If your infrastructure is defined in code, the entire deployment process can be automated, and developers can kick off their own deployments whenever necessary.

    Speed and safety
    If the deployment process is automated, it will be significantly faster, since a computer can carry out the deployment steps far faster than a person; and safer, given that an automated process will be more consistent,
    more repeatable, and not prone to manual error.

    Documentation
    Instead of the state of your infrastructure being locked away in a single sysadmin’s head, you can represent the state of your infrastructure in source files that anyone can read. In other words, IaC acts as documentation,
    allowing everyone in the organization to understand how things work, even if the sysadmin goes on vacation.

    Version control
    You can store your IaC source files in version control,which means that the entire history of your infrastructure is now captured in the commit log. This becomes a powerful tool for debugging issues, because any time a problem pops up,
    your first step will be to check the commit log and find out what changed in your infrastructure, and your second step might be to resolve the problem by simply reverting back to a previous, known-good version of your IaC code.

    Validation
    If the state of your infrastructure is defined in code, for every single change, you can perform a code review, run a suite of automated tests, and pass the code through static analysis tools—all practices
    that are known to significantly reduce the chance of defects.

    Reuse
    You can package your infrastructure into reusable modules, so that instead of doing every deployment for every product in every environment from scratch, you can build on top of known, documented, battle-tested pieces.

    Happiness
    There is one other very important, and often overlooked, reason for why you should use IaC: happiness. Deploying code and managing infrastructure manually is repetitive and tedious. Developers and sysadmins resent this type of work, since it
    involves no creativity, no challenge, and no recognition. You could deploy code perfectly for months, and no one will take notice—until that one day when you mess it up. That creates a stressful and unpleasant environment. IaC offers a
    better alternative that allows computers to do what they do best (automation) and developers to do what they do best (coding).

    ++ Exampe of Terraform code :

    resource "aws_instance" "example" {
      ami           = "ami-0c55b159cbfafe1f0"
      instance_type = "t2.micro"
    }

    resource "google_dns_record_set" "a" {
      name         = "demo.google-example.com"
      managed_zone = "example-zone"
      type         = "A"
      ttl          = 300
      rrdatas      = [aws_instance.example.public_ip]
    }

    Even if you’ve never seen Terraform code before, you shouldn’t have too much trouble reading it. This snippet instructs Terraform to make API calls to AWS to deploy a server and then make API calls to Google Cloud to create a
    DNS entry pointing to the AWS server’s IP address. In just a single, simple syntax,
    Terraform allows you to deploy interconnected resources across multiple cloud providers.

    to deploy :

    $ terraform apply

    -> The terraform binary parses your code, translates it into a series of API calls to the cloud providers specified in the code, and makes those API calls as efficiently as possible.

    - To Update/Change the provisionned servers :

    ++ When someone on your team needs to make changes to the infrastructure, instead of updating the infrastructure manually and directly on the servers, they make their changes in the Terraform configuration files,
    validate those changes through automated tests and code reviews, commit the updated code to version control, and then run the terraform apply command to have Terraform make the necessary API calls to deploy the changes.

    -> TRANSPARENT PORTABILITY BETWEEN CLOUD PROVIDERS :

    ++ could you instruct Terraform to deploy exactly the same infrastructure in another cloud provider, such as Azure or Google Cloud, in just a few clicks?

    Answer: The reality is that you can’t deploy “exactly the same infrastructure” in a different cloud provider because the cloud providers don’t offer the same types of infrastructure! The servers, load balancers, and databases.
    More : Terraform’s approach is to allow you to write code that is specific to each provider, taking advantage of that provider’s unique functionality, but to use the same language, toolset, and IaC practices under the hood for all providers.

    - Templating server (Docker) + Provisionning tools (Terraform) vs Configuration managment (Ansible) :

    1- Mutable Infrastructure Versus Immutable Infrastructure :

    Configuration management tools such as Chef, Puppet, Ansible, and SaltStack typically default to a mutable infrastructure paradigm. For example, if you instruct Chef to install a new version of OpenSSL,
    it will run the software update on your existing servers and the changes will happen in place. Over time, as you apply more and more updates, each server builds up a unique history of changes. As a result,
    each server becomes slightly different than all the others, leading to subtle configuration bugs that are difficult to diagnose and reproduce (this is the same configuration drift problem that happens when
    you manage servers manually, although it’s much less problematic when using a configuration management tool). Even with automated tests these bugs are difficult to catch; a configuration management
    change might work just fine on a test server, but that same change might behave differently on a production server because the production server has accumulated months of changes that aren’t reflected in the test environment.

    If you’re using a provisioning tool such as Terraform to deploy machine images created by Docker or Packer, most “changes” are actually deployments of a completely new server. For example, to deploy a new version of OpenSSL,
    you would use Packer to create a new image with the new version of OpenSSL, deploy that image across a set of new servers, and then terminate the old servers. Because every deployment uses immutable images on fresh servers,
    this approach reduces the likelihood of configuration drift bugs, makes it easier to know exactly what software is running on each server, and allows you to easily deploy any previous version of the software (any previous image) at any time.
    It also makes your automated testing more effective, because an immutable image that passes your tests in the test environment is likely to behave exactly the same way in the production environment.

    - Some downsides of Immutability :

    Of course, it’s possible to force configuration management tools to do immutable deployments, too, but it’s not the idiomatic approach for those tools, whereas it’s a natural way to use provisioning tools. It’s also worth mentioning that
    the immutable approach has downsides of its own. For example, rebuilding an image from a server template and redeploying all your servers for a trivial change can take a long time. Moreover, immutability lasts only until you actually run
    the image. After a server is up and running, it will begin making changes on the hard drive and experiencing some degree of configuration drift (although this is mitigated if you deploy frequently).

    2- Procedural Language Versus Declarative Language :

    Chef and Ansible encourage a procedural style in which you write code that specifies, step by step, how to achieve some desired end state. Terraform, CloudFormation, SaltStack, Puppet, and Open Stack Heat all encourage a more declarative
    style in which you write code that specifies your desired end state, and the IaC tool itself is responsible for figuring out how to achieve that state.

    Examples : (Ansible vs Terraform)

    Ansible :

        - ec2:
            count: 10
            image: ami-0c55b159cbfafe1f0
            instance_type: t2.micro”

    Terraform :

        resource "aws_instance" "example" {
            count         = 15
            ami           = "ami-0c55b159cbfafe1f0"
            instance_type = "t2.micro"
        }

    For example, imagine traffic has gone up and you want to increase the number of servers to 15. With Ansible, the procedural code you wrote earlier is no longer useful; if you just updated the number of servers
    to 15 and reran that code, it would deploy 15 new servers, giving you 25 total! So instead, you need to be aware of what is already deployed and write a totally new procedural script to add the five new servers:

    - ec2:
        count: 5
        image: ami-0c55b159cbfafe1f0
        instance_type: t2.micro

    With declarative code, because all you do is declare the end state that you want, and Terraform figures out how to get to that end state, Terraform will also be aware of any state it created in the past.
    Therefore, to deploy five more servers, all you need to do is go back to the same Terraform configuration and update the count from 10 to 15:

    resource "aws_instance" "example" {
      count         = 15
      ami           = "ami-0c55b159cbfafe1f0"
      instance_type = "t2.micro"
    }

    If you applied this configuration, Terraform would realize it had already created 10 servers and therefore all it needs to do is create five new servers.
    In fact, before applying this configuration, you can use Terraform’s plan command to preview what changes it would make:

    $ terraform plan

    - Making changes between (Ansible vs Terraform) :

    Now what happens when you want to deploy a different version of the app, such as AMI ID ami-02bcbb802e03574ba? With the procedural approach, both of your previous Ansible templates are again not useful,
    so you need to write yet another template to track down the 10 servers you deployed previously (or was it 15 now?) and carefully update each one to the new version. With the declarative approach of Terraform,
    you go back to the exact same configuration file again and simply change the ami parameter to ami-02bcbb802e03574ba:

    resource "aws_instance" "example" {
      count         = 15
      ami           = "ami-02bcbb802e03574ba"
      instance_type = "t2.micro”
    }

### + Best Combination Provisionning + Server templating :

- PROVISIONING PLUS SERVER TEMPLATING PLUS ORCHESTRATION :


    Example: Terraform, Packer, Docker, and Kubernetes. You use Packer to create a VM image that has Docker and Kubernetes installed. You then use Terraform to deploy (a) a cluster of servers, each of which runs this VM image,
    and (b) the rest of your infrastructure, including the network topology (i.e., VPCs, subnets, route tables), data stores (e.g., MySQL, Redis), and load balancers. Finally, when the cluster of servers boots up, it forms a
    Kubernetes cluster that you use to run and manage your Dockerized applications, as shown in Figure 1-11.

![](./static/terraform_docker_packer_kubernetes.png)

### + Getting Started with Terraform :

    + First Tutorial that combine Terraform and AWS :

        - Setting up your AWS account Installing Terraform
        - Deploying a single server
        - Deploying a single web server
        - Deploying a configurable web server
        - Deploying a cluster of web servers
        - Deploying a load balancer
        - Cleaning up


    - Advice about AWS Root account :
    -> it’s not a good idea to use the root user on a day-to-day basis. In fact, the only thing you should use the root user for is to create other user accounts with more-limited permissions, and then switch to one of those accounts immediately.

    ++ after creating the IAM account AWS will show you the security credentials for that user, which consist of an Access Key ID and a Secret Access Key, You must save these immediately because they will never be shown again, and you’ll need them later on in this tutorial.
    Remember that these credentials give access to your AWS account, so store them somewhere secure.

    + Add account permissions :

        AmazonEC2FullAccess
        AmazonS3FullAccess
        AmazonDynamoDBFullAccess
        AmazonRDSFullAccess
        CloudWatchFullAccess
        IAMFullAccess

    + About Virtual Private Cloud :

    A NOTE ON DEFAULT VIRTUAL PRIVATE CLOUDS

    If you are using an existing AWS account, it must have a Default VPC in it. A VPC, or Virtual Private Cloud, is an isolated area of your AWS account that has its own virtual network and IP address space. Just about every AWS resource deploys into a VPC.
    If you don’t explicitly specify a VPC, the resource will be deployed into the Default VPC, which is part of every new AWS account. All of the examples in this book rely on this Default VPC, so if for some reason you deleted the one in your account,
    either use a different region (each region has its own Default VPC) or create a new Default VPC using the AWS Web Console. Otherwise, you’ll need to update almost every example to include a vpc_id or subnet_id parameter pointing to a custom VPC.


    + Install Terraform on OSX :

    $ brew install terraform

    run :
    $ terraform

    2- For Terraform to be able to make changes in your AWS account, you will need to set the AWS credentials for the IAM user you created earlier as the environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.

         $ export AWS_ACCESS_KEY_ID=(your access key id)
         $ export AWS_SECRET_ACCESS_KEY=(your secret access key)

    NB: Note that these environment variables apply only to the current shell, so if you reboot your computer or open a new terminal window, you’ll need to export these variables again.

    - First Of All we should authenticate to aws cli/sdk :

    1- we should install `aws cli` on our machine.
    -> https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html

    2- run : `aws configure` and enter your credentials (keys, region etc)

    - AUTHENTICATION OPTIONS :
    In addition to environment variables, Terraform supports the same authentication mechanisms as all AWS CLI and SDK tools. Therefore, it’ll also be able to use credentials in $HOME/.aws/credentials, which are automatically 
    generated if you run the configure command on the AWS CLI, or IAM Roles, which you can add to almost any resource in AWS.

    1- Deploy a single Server :

    1-1 The first step to using Terraform is typically to configure the provider(s) you want to use. Create an empty folder and put a file in it called main.tf that contains the following contents:
    
    ```
        provider "aws" {
            region = "us-east-2"
        }
    ```
    
    - For each type of provider, there are many different kinds of resources that you can create, such as servers, databases, and load balancers. The general syntax for creating a resource in Terraform is:
    
    ```
        resource "<PROVIDER>_<TYPE>" "<NAME>" {
            [CONFIG ...]
        }
    ```

    -- where PROVIDER is the name of a provider (e.g., aws), TYPE is the type of resource to create in that provider (e.g., instance), NAME is
       an identifier you can use throughout the Terraform code to refer to this resource (e.g., my_instance), and CONFIG consists of one or more arguments that are specific to that resource.

    # For example, to deploy a single (virtual) server in AWS, known as an EC2 Instance, use the aws_instance resource in main.tf as follows:
    
    ```
        resource "aws_instance" "web_server_instance" {
            ami = "ami-0c55b159cbfafe1f0"
            instance_type = "t2.micro"
        }
    ```

    The aws_instance resource supports many different arguments, but for now, you only need to set the two required ones:
    
    - ami
    The Amazon Machine Image (AMI) to run on the EC2 Instance. You can find free and paid AMIs in the AWS Marketplace or create your own using tools such as Packer 
    (see “Server Templating Tools” for a discussion of machine images and server templating). The preceding code example sets the ami parameter to the ID of an 
    Ubuntu 18.04 AMI in us-east-2. This AMI is free to use.
    
    - instance_type
    The type of EC2 Instance to run. Each type of EC2 Instance provides a different amount of CPU, memory, disk space, and networking capacity. 
    The EC2 Instance Types page lists all the available options. The preceding example uses t2.micro, which has one virtual CPU, 1 GB of memory, 
    and is part of the AWS free tier.
    
    - link to terraform documentation :
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
    
    - Finally :
    ++ In a terminal, go into the folder where you created main.tf and run the `terraform init` command.
    
    NB: just be aware that you need to run init any time you start with new Terraform code, and that it’s safe to run init multiple times
    
    - Now that you have the provider code downloaded, run the `terraform plan` command.
    
    -> about `terraform plan` command :

    The plan command lets you see what Terraform will do before actually making any changes. This is a great way to sanity check your code before 
    unleashing it onto the world. The output of the plan command is similar to the output of the diff command that is part of Unix, Linux, 
    and git: anything with a plus sign (+) will be created, anything with a minus sign (–) will be deleted, and anything with a tilde sign (~) 
    will be modified in place. In the preceding output, you can see that Terraform is planning on creating a single EC2 Instance and nothing else, which is exactly what you want.
    
    - then run `terraform apply` command.

    Congrats, you’ve just deployed an EC2 Instance in your AWS account using Terraform! To verify this, head over to the EC2 console; 
    
    - Update EC2 Instance :

    Sure enough, the Instance is there, though admittedly, this isn’t the most exciting example. Let’s make it a bit more interesting. First, notice that the EC2 Instance doesn’t have a name. 
    To add one, you can add tags to the aws_instance resource:

    ```
        resource "aws_instance" "web_server_instance" {
            ami = "ami-0c55b159cbfafe1f0"
            instance_type = "t2.micro"
    
            tags = {
                Name = "terraform-instance"
            }
        }
    ```
    
    2- Deploy a Single web-srver :

    The next step is to run a web server on this Instance. The goal is to deploy the simplest web architecture possible: 
    a single web server that can respond to HTTP requests

![](./static/simple-architecture.png)

    In a real-world use case, you’d probably build the web server using a web framework like Ruby on Rails or Django, 
    but to keep this example simple, let’s run a `dirt-simple web server` that always returns the text “Hello, World”:

    This is a Bash script that writes the text “Hello, World” into index.html and runs a tool called busybox 
    (which is installed by default on Ubuntu) to fire up a web server on port 8080 to serve that file. 

    -> file `server.sh` :
    ```
    echo "Hello, world" > index.html
    nohup busybox httpd -f -p 8080 &
    ```
    
    -- I wrapped the busybox command with nohup and & so that the web server runs permanently in the background, 
       whereas the Bash script itself can exit.

    ++ PORT NUMBERS :
    The reason this example uses port 8080, rather than the default HTTP port 80, is that listening on any port less than 1024 
    requires root user privileges. This is a security risk, because any attacker who manages to compromise your server would 
    get root privileges, too.
    Therefore, it’s a best practice to run your web server with a non-root user that has limited permissions. 
    That means you have to listen on higher-numbered ports, but as you’ll see later in this chapter, 
    you can configure a load balancer to listen on port 80 and route traffic to the high-numbered ports on your server(s).

    -- How do you get the EC2 Instance to run this script? 

    Normally, as discussed in “Server Templating Tools”, you would use a tool like Packer to create a custom AMI that has 
    the web server installed on it. Since the dummy web server in this example is just a one-liner that uses busybox, 
    you can use a plain Ubuntu 18.04 AMI, and run the “Hello, World” script as part of the EC2 Instance’s User Data configuration. 
    When you launch an EC2 Instance, you have the option of passing either a shell script or cloud-init directive to User Data, 
    and the EC2 Instance will execute it during boot. You pass a shell script to User Data by setting the user_data argument 
    in your Terraform code as follows:
    
    ```
        resource "aws_instance" "web_server_instance" {
          ami = "ami-0c55b159cbfafe1f0"
          instance_type = "t2.micro"
          user_data = <<-EOF
                      #!/bin/bash
                      echo "Hello, world" > index.html
                      nohup busybox httpd -f -p 8080 &
                      EOF
          tags = {
            Name = "terraform-instance"
          }
        }
    ```
    
    -- The <<-EOF and EOF are Terraform’s heredoc syntax, which allows you to create multiline strings without having to insert newline 
       characters all over the place.
    
    - Allow EC2 Instance to receive Traffic :

    You need to do one more thing before this web server works. By default, AWS does not allow any incoming or outgoing traffic from an EC2 Instance. 
    To allow the EC2 Instance to receive traffic on port 8080, you need to create a security group:
    
    ```
        resource "aws_security_group" "instance" {
          name = "terraform-example-instance"
        
          ingress {
            from_port = 8080
            to_port = 8080
            protocol = "tcp"
            cidr_blocks = ["0", "0", "0", "0"]
          }
        
        }
    ```
    
    This code creates a new resource called aws_security_group (notice how all resources for the AWS provider begin with aws_) and specifies that this group allows incoming TCP requests on port
    8080 from the CIDR block 0.0.0.0/0. CIDR blocks are a concise way to specify IP address ranges. For example, a CIDR block of 10.0.0.0/24 represents all IP addresses between 10.0.0.0 and 10.0.0.255. 
    The CIDR block 0.0.0.0/0 is an IP address range that includes all possible IP addresses, so this security group allows incoming requests on port 8080 from any IP.
    
    - Connect EC2 with security group to allow Traffic :
    ++ Simply creating a security group isn’t enough; you also need to tell the EC2 Instance to actually use it by passing the ID of the security group into the vpc_security_group_ids argument of the aws_instance resource. 
       To do that, you first need to learn about Terraform expressions.

    One particularly useful type of expression is a reference, which allows you to access values from other parts of your code. To access the ID of the security group resource, you are going to need to use a resource attribute reference, which uses the following syntax:
    --  `<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>`
    
    ++ Complete the expression :
    - where PROVIDER is the name of the provider (e.g., aws), TYPE is the type of resource (e.g., security_group), NAME is the name of that resource (e.g., the security group is named "instance"), 
      and ATTRIBUTE is either one of the arguments of that resource (e.g., name) or one of the attributes exported by the resource (you can find
      the list of available attributes in the documentation for each resource).
    
    add this expression to ec2 resource : `vpc_security_group_ids = [aws_security_group.instance.id]`
    
    +++ When you add a reference from one resource to another, you create an implicit dependency. Terraform parses these dependencies, builds a dependency graph from them, and uses that to automatically determine 
        in which order it should create resources.

    -- You can even get Terraform to show you the dependency graph by running the graph command :
    -> run `terraform graph`

-> you can turn this description language into a visual graph using this tool :
[here](http://dreampuf.github.io/GraphvizOnline/)

![](./static/viz_graph.png)
    
    
    NB: It’s worth mentioning that although the web server is being replaced, any users of that web server would experience downtime; 
        you’ll see how to do a zero-downtime deployment with Terraform.

    - Finally, we should ping public ip address that we could find when we click on the instance in aws console.
    
    ```
        $ curl http://<EC2_INSTANCE_PUBLIC_IP>:8080
        Hello, World
    ```

    Yay! You now have a working web server running in AWS!
    
    - Network Security :

    Therefore, for production systems, you should deploy all of your servers, and certainly all of your data stores, in private subnets, 
    which have IP addresses that can be accessed only from within the VPC and not from the public internet. 
    The only servers you should run in public subnets are a small number of reverse proxies and load balancers that you lock down as much as possible
    
    2- Deploy a Configurable Web Server :

    You might have noticed that the web server code has the port 8080 duplicated in both the security group and the User Data configuration. This violates the Don’t Repeat Yourself (DRY) principle: 
    every piece of knowledge must have a single, unambiguous, authoritative representation within a system.8 If you have the port number in two places, it’s easy to update it in one place but forget 
    to make the same change in the other place.
    To allow you to make your code more DRY and more configurable, Terraform allows you to define input variables. Here’s the syntax for declaring a variable:

    ```
    variable "NAME" {
        [CONFIG ...]
    }
    ```
    
    The body of the variable declaration can contain three parameters, all of them optional:
    
    - description :
    It’s always a good idea to use this parameter to document how a variable is used. Your teammates will not only be able to see this description
    while reading the code, but also when running the plan or apply commands
    
    - default
    There are a number of ways to provide a value for the variable, including passing it in at the command line (using the -var option), via a file (using the -var-file option), or via an environment variable (Terraform looks for environment variables
    of the name TF_VAR_<variable_name>). If no value is passed in, the variable will fall back to this default value. If there is no default value, Terraform will interactively prompt the user for one.
    
    - type
    This allows you enforce type constraints on the variables a user passes in. Terraform supports a number of type constraints, including string, number, bool, list, map, set, object, tuple, and any. If you don’t specify a type, Terraform assumes the type is any.
    
    Here is an example of an input variable that checks to verify that the value you pass in is a number:
    
    ```
    variable "number_example" {
        description = "An example of a number variable in
                        Terraform"
        type = number
        default = 42 
        }
    ```
    
    And here’s an example of a variable that checks whether the value is a list:
    
    ```
    variable "list_example" {
        description = "An example of a list in Terraform" type = list
        default = ["a", "b", "c"]
    }
    ```

    You can combine type constraints, too. For example, here’s a list input variable that requires all of the items in the list to be numbers:
    
    ```
    variable "list_numeric_example" {
        description = "An example of a numeric list in Terraform" 
        type = list(number)
        default = [1,2,3,4]
    ```
    
    And here’s a map that requires all of the values to be strings:

    ```
    variable "map_example" {
        description = "An example of a map in Terraform" type = map(string)
          default = {
            key1 = "value1"
            key2 = "value2"
            key3 = "value3"
        } 
    }
    ```

    ```
    variable "object_example" {
    
    description = "An example of a structural type in Terraform"    
    
    type = object({
        age = number
        name = string
        tags = list(string)
        enabled = bool
    })

    default = {
            age = 25
            name = "Mohamed El Rahali"
            tags = ["work", "hobbies"]
            enabled = true
        }
    }
    ```

    - Refactor terraform code to use server_port as a variable :
    ```
    variable "server_port" {
      description = "The port the server will use for HTTP requests"
      type = number
      default = 8080
    }
    ```

    you can also let `default` param empty and use terminal arg `-var` :
    
    - terraform plan -var "server_port"=8080 
    
    You could also set the variable via an environment variable named TF_VAR_<name>, where <name> is the name of the variable you’re trying to set:
    
    $ export TF_VAR_server_port=8080
    $ terraform plan
    
    - To use the value from an input variable in your Terraform code :

    + var.<VARIABLE_NAME>
    
    ALSO TO USE THE VARIABLE INSIDE `user_data` (string literal):

    user_data = <<-EOF #!/bin/bash
            echo "Hello, World" > index.html
            nohup busybox httpd -f -p ${var.server_port} &
            EOF

    2- to define output variable that you could request to check validity of a variable :
    
    ```
    output "<NAME>" {
        value = <VALUE>
        [CONFIG ...]
    }
    ```
    
    The NAME is the name of the output variable, and VALUE can be any Terraform expression that you would like to output. The CONFIG can contain two additional parameters, both optional:
    
    + description :
    It’s always a good idea to use this parameter to document what type of data is contained in the output variable.
    
    + sensitive :
    Set this parameter to true to instruct Terraform not to log this output at the end of terraform apply. This is useful if the output variable contains sensitive material or secrets such as passwords or private keys.
      
    For example, instead of having to manually poke around the EC2 console to find the IP address of your server, you can provide the IP address as an output variable:

    ```
    output "public_ip" {
        value       = aws_instance.example.public_ip
        description = "The public IP address of the web server"
    }
    ```

    - terraform apply

    NB: You can also use the terraform output command to list all outputs without applying any changes.
    
    -> terraform output
    or terraform output public_ip
    
    - Conclusion :

    This is particularly handy for scripting. For example, you could create a deployment script that runs terraform apply to deploy the web server, uses terraform output public_ip to grab its public IP, 
    and runs curl on the IP as a quick smoke test to validate that the deployment worked.
    
    3- Deploying a Cluster of Web Servers :

    Managing such a cluster manually is a lot of work. Fortunately, you can let AWS take care of it for by you using an Auto Scaling Group
    An ASG takes care of a lot of tasks for you completely automatically, including launching a cluster of EC2 Instances, monitoring 
    the health of each Instance, replacing failed Instances, and adjusting the size of the cluster in response to load.
    
![](./static/auto_scaling_group.png)
    
    The first step in creating an ASG is to create a launch configuration, which specifies how to configure each EC2 Instance in the ASG. The aws_launch_configuration resource uses 
    almost exactly the same parameters as the aws_instance resource (two of the parameters have different names: ami is now image_id and vpc_security_group_ids is now security_groups),    

    ```
        resource "aws_launch_configuration" "web_server_instance" {
          image_id = "ami-0c55b159cbfafe1f0"
          instance_type = "t2.micro"
          vpc_security_group = [aws_security_group.instance.id]
          user_data = <<-EOF
                      #!/bin/bash
                      echo "Hello, world" > index.html
                      nohup busybox httpd -f -p ${var.server_port} &
                      EOF
        
        }
    ```
    
    Now you can create the ASG itself using the aws_autoscaling_group resource:

    ```
        
        resource "aws_autoscaling_group" "example" {
        launch_configuration = aws_launch_configuration.example.name

        min_size = 2
        max_size = 10

          tag {
            key     = "Name"
            value   = "terraform-asg-example"
            propagate_at_launch = true
          }
    }
    ```

    PAY ATTENTION :

    This ASG will run between 2 and 10 EC2 Instances (defaulting to 2 for the initial launch), each tagged with the name terraform- asg-example. Note that the ASG uses a reference to fill in the launch configuration name. (THE VARIABLE `launch_configuration = aws_launch_configuration.example.name`) This leads to a problem: 
    launch configurations are immutable, so if you change any parameter of your launch configuration, Terraform will try to replace it. Normally, when replacing a resource, Terraform `deletes the old resource first` and `then creates its replacement`, but because your ASG now has a reference to the old resource, Terraform won’t be able to delete it.

    - That we should create the new launch configuration before destroying the old one like that we won't get this problem.
    
    ++ Lifecycles :

    To solve this problem, you can use a lifecycle setting. Every Terraform resource supports several lifecycle settings that configure how that resource is created, updated, and/or deleted. A particularly useful lifecycle setting is create_before_destroy. If you set create_before_destroy to true, Terraform will invert the order in which it replaces resources, 
    creating the replacement resource first (including updating any references that were pointing at the old resource to point to the replacement) and then deleting the old resource. Add the lifecycle block to your
    
    ```
        resource "aws_launch_configuration" "example" {
              image_id = "ami-0c55b159cbfafe1f0"
              instance_type = "t2.micro"
              security_groups = [aws_security_group.instance.id]
              user_data = <<-EOF
                          #!/bin/bash
                          echo "Hello, world" > index.html
                          nohup busybox httpd -f -p ${var.server_port} &
                          EOF
            -----------------------------------
              lifecycle {
                create_before_destroy = true
              }
            ------------------------------------
        }
    ```

    - Subnets :

    There’s also one other parameter that you need to add to your ASG to make it work: subnet_ids. This parameter specifies to the ASG into which VPC subnets the EC2 Instances should be deployed (see Network Security for background info on subnets). Each subnet lives in an isolated AWS AZ (that is, isolated datacenter), so by deploying your Instances across multiple subnets,
    you ensure that your service can keep running even if some of the datacenters have an outage. You could hardcode the list of subnets, but that won’t be maintainable or portable, so a better option is to use data sources to get the list of subnets in your AWS account.

    - Data sources :
    
    A data source represents a piece of read-only information that is fetched from the provider (in this case, AWS) every time you run Terraform. Adding a data source to your Terraform configurations does not create anything new; it’s just a way to query the provider’s APIs for data and to make that data available to the rest of your Terraform code. 
    Each Terraform provider exposes a variety of data sources. For example, the AWS provider includes data sources to look up VPC data, subnet data, AMI IDs, IP address ranges, the current user’s identity, and much more.
    
    ```
        data "<PROVIDER>_<TYPE>" "<NAME>" {
            [CONFIG ...]
        }
    ``` 

    Here, PROVIDER is the name of a provider (e.g., aws), TYPE is the type of data source you want to use (e.g., vpc), NAME is an identifier
    you can use throughout the Terraform code to refer to this data source, and CONFIG consists of one or more arguments that are specific to that data source. For example, here is how you can use the aws_vpc data source to look up the data for your Default VPC
    
    ```
        data "aws_vpc" "default" {
            default = true
        }
    ```

    Note that with data sources, the arguments you pass in are typically search filters that indicate to the data source what information you’re looking for. With the aws_vpc data source, the only filter you need is default = true, which directs Terraform to look up the Default VPC in your AWS account.

    To get the data out of a data source, you use the following attribute reference syntax:
    
    -> `data.<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>`

    For example, to get the ID of the VPC from the aws_vpc data
    source, you would use the following:

    -> `data.aws_vpc.default.id`

    You can combine this with another data source, aws_subnet_ids, to look up the subnets within that VPC:
    Finally, you can pull the subnet IDs out of the aws_subnet_ids data source and tell your ASG to use those subnets via the (somewhat oddly named) vpc_zone_identifier argument:
    
    ```
        data "aws_subnet_ids" "default" { 
            vpc_id = data.aws_vpc.default.id
        }
    ```

    3-2 Deploying a Load Balancer :
    
    At this point, you can deploy your ASG, but you’ll have a small problem: you now have multiple servers, each with its own IP address, but you typically want to give of your end users only a single IP to use. One way to solve this problem is to deploy a load balancer to distribute traffic across your servers and to give all your users the IP (actually, the DNS name) of the load balancer. 
    Creating a load balancer that is highly available and scalable is a lot of work. Once again, you can let AWS take care of it for you, this time by using Amazon’s Elastic Load Balancer (ELB) service, as shown in Figure 2-10.

![](./static/Elastic_load_balancer.png)    
    
    - AWS offers three different types of load balancers:    

    1- Application Load Balancer (ALB)
    Best suited for load balancing of HTTP and HTTPS traffic. Operates at the application layer (Layer 7) of the OSI model.
    
    2- Network Load Balancer (NLB)
    Best suited for load balancing of TCP, UDP, and TLS traffic. Can scale up and down in response to load faster than the ALB (the NLB is designed to scale to tens of millions of requests per second). Operates at the transport layer (Layer 4) of the OSI model.
    
    3- Classic Load Balancer (CLB)
    This is the “legacy” load balancer that predates both the ALB and NLB. It can handle HTTP, HTTPS, TCP, and TLS traffic, but with far fewer features than either the ALB or NLB. Operates at both the application layer (L7) and transport layer (L4) of the OSI model.
        
    --> Most applications these days should use either the ALB or the NLB. Because the simple web server example you’re working on is an HTTP app without any extreme performance requirements, the ALB is going to be the best fit.

    As shown in Figure 2-11, the ALB consists of several parts: 
    
    1- Listener
    Listens on a specific port (e.g., 80) and protocol (e.g., HTTP).
    
    2- Listener rule
    Takes requests that come into a listener and sends those that match specific paths 
    (e.g., /foo and /bar) or hostnames (e.g., foo.example.com and bar.example.com) to specific target groups.
    
    3- Target groups
    One or more servers that receive requests from the load balancer. The target group also performs health checks on these servers and only sends requests to healthy nodes.
    
![](./static/APPLICATION_LOAD_BALANCER.png)
    
    The first step is to create the ALB itself using the aws_lb resource:
    
    resource "aws_lb" "example" {
    name = "terraform-asg-example" load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    }
    
    Note that the subnets parameter configures the load balancer to use all the subnets in your Default VPC by using the aws_subnet_ids data source.
    NB:  AWS automatically scales the number of load balancer servers up and down based on traffic and handles failover if one of those servers goes down, so you get scalability and high availability out of the box.

    - Define a listener :

        resource "aws_lb_listener" "http" {
          load_balancer_arn = aws_lb.example.arn
          port = 80
          protocol = "HTTP"
        
          # By default, return a simple 404 page
          # Listener Rules
          default_action {
            type = "fixed-response"
        
            fixed_response {
              content_type = "text/plain"
              message_body = "404: page not found"
              status_code = 404
            }
          }
        }

    --> This listener configures the ALB to listen on the default HTTP port, port 80, use HTTP as the protocol, and send a simple 404 page as the default response for requests that don’t match any listener rules.
    
    Note that, by default, all AWS resources, including ALBs, don’t allow any incoming or outgoing traffic, so you need to create a new security group specifically for the ALB. This security group should 
    allow incoming requests on port 80 so that you can access the load
    balancer over HTTP, and outgoing requests on all ports so that the load balancer can perform health checks:

    NB: there is no problem using port 80 (under 1024) for the loadbalancer but it could be a threat using this port in the server this why we used 8080 in ec2 instances.
    
    ```
        resource "aws_security_group" "alb" {
          name = "terraform-example-alb"
        
          # Allow inbound HTTP requests
          ingress {
            from_port = 80
            protocol  = "tcp"
            to_port   = 80
            cidr_blocks = ["0.0.0.0/0"] # you can use any IP address
          }
        
          # Allow all outbound requests
        
          egress {
            from_port = 0
            protocol  = "-1"
            to_port   = 0
            cidr_blocks = ["0.0.0.0/0"]
          }
        
        }

    ```

    You’ll need to tell the aws_lb resource to use this security group via the security_groups argument:
    
    ````
    resource "aws_lb" "example" {
        name = "terraform-asg-example" 
        load_balancer_type = "application"
        subnets = data.aws_subnet_ids.default.ids
        security_groups    = [aws_security_group.alb.id]
    }
    ```

    Next, you need to create a target group for your ASG using the aws_lb_target_group resource:
    
    ```

    resource "aws_alb_target_group" "asg" {
      name = "terraform-asg-example"
      port = var.server_port
      protocol = "HTTP"
      vpc_id = data.aws_vpc.default.id
    
      health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
      }
    }
    
    ```

    +++ Note that this target group will health check your Instances by periodically 
        sending an HTTP request to each Instance and will consider the Instance “healthy” 
        only if the Instance returns a response that matches the configured matcher 
        (e.g., you can configure a matcher to look for a 200 OK response). If an Instance fails to respond, 
        perhaps because that Instance has gone down or is overloaded, it will be marked as “unhealthy,” and 
        the target group will automatically stop sending traffic to it to minimize disruption for your users.

    How does the target group know which EC2 Instances to send requests to? You could attach a static list of EC2 Instances 
    to the target group using the aws_lb_target_group_attachment resource, but with an ASG, Instances can launch or terminate at any time, 
    so a static list won’t work. Instead, you can take advantage of the first-class integration between the ASG and the ALB. 
    Go back to the aws_autoscaling_group resource and set its target_group_arns argument to point at your new target group:

    ``
    resource "aws_autoscaling_group" "example" {
      launch_configuration = aws_launch_configuration.example.name
      vpc_zone_identifier = data.aws_subnet_ids.default.ids
        ----------------------------------------
      target_group_arns = [aws_alb_target_group.asg.arn]
      health_check_type = "ELB"
        ----------------------------------------
      min_size = 2
      max_size = 10
    
      tag {
        key     = "Name"
        value   = "terraform-asg-example"
        propagate_at_launch = true
      }
    }
    ```

    - Health check type :

    You should also update the health_check_type to "ELB". The default health_check_type is "EC2", which is a minimal
    health check that considers an Instance unhealthy only if the AWS hypervisor says the VM is completely down or unreachable. 
    The "ELB" health check is more robust, because it instructs the ASG to use the target group’s health check to determine whether 
    an Instance is healthy and to automatically replace Instances if the target group reports them as unhealthy. That way, 
    Instances will be replaced not only if they are completely down, but also if, for example, they’ve stopped serving 
    requests because they ran out of memory or a critical process crashed.

    Finally, it’s time to tie all these pieces together by creating listener rules using the aws_lb_listener_rule resource:
    
    ```
        resource "aws_alb_listener_rule" "asg" {
          listener_arn = aws_lb_listener.http.arn
          priority = 100
        
          action {
            type = "forward"
            target_group_arn = aws_alb_target_group.asg.arn
          }
        
          condition {
            path_pattern {
                values = ["*"]
            }
          }
        }
    ```
    
    There’s one last thing to do before you deploy the load balancer— replace the old public_ip output of the single EC2 Instance you had before with an output that shows the DNS name of the ALB:
    
    ```
        output "alb_dns_name" {
          value = aws_alb.example.dns_name
          description = "The domain name of the load balancer"
        
        }
    ```

    Run terraform apply and read through the plan output. You should see that your original single EC2 Instance is being removed, and in its place, Terraform will create a launch configuration, 
    ASG, ALB, and a security group. If the plan looks good, type yes and hit Enter. 
    When apply completes, you should see the alb_dns_name output:

    Outputs:
    alb_dns_name = "terraform-asg-example-506010843.us-east-2.elb.amazonaws.com"
    
    - To make sure that all works good try to request the dns :
    -> curl terraform-asg-example-506010843.us-east-2.elb.amazonaws.com


    -> Finally to destroy all infra created, just run `terraform destroy` and you will delete all r4esources that are created.
    
    