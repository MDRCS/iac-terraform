## + Pre-requisites :

    - You must have Packer installed on your computer.
    - You must have an Amazon Web Services (AWS) account.

### + Configure your AWS access keys as environment variables:


    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)

### + To build the AMI:

    $ packer build webserver.json
