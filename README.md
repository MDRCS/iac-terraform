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






