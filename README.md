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