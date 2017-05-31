# Terraform

## Overview
### tfvars file
* Used to store private key value pairs
* Should not be committed to repo

### tfstate and backends
* tfstate is used to store the last terraform execution's infrastructure
  * it is used to determine the diff of the previous run and current run
* tfstate needs to be read/write accessible by any users managing infrastructure
* remote backend management is now built-into terraform
* S3 + DynamoDB is the most commonly used remote backend - this allows locking with concurrent applies

## Providers
* handle creation of resources
  * ex. aws, google, azure, etc

## Provisioners
* used to execute scripts on either local control host or remote
  * ex. chef client provisioning

## Load order and semantics
* *.tf files are loaded alphabetically by default
* all *.tf files within the execution folder are executed

## Terraform Setup
### Initial Global Setup
* Run cloudformation ```s3-dynamo-remote-backend-setup.yaml``` to setup s3 and dynamo db backend

### Initial User Setup
* Install tfenv
    * Notes and link below
* Install aws cli
    * `brew install awscli`

    OR

    * http://docs.aws.amazon.com/cli/latest/userguide/installing.html
* Create an aws profile for the aws account where the remote backend is stored
    * From anywhere on command line execute ```aws configure --profile <profile name>``` and follow the wizard
    * The profile name is hardcoded in the environment's main.tf under remote state configuration

### Usage
* Change directory into the environment folder you wish to execute
    * Ex. terraform/environments/operations
* Execute ```tfenv install``` which will install the correct version of terraform
    *  This looks at the .terraform-version file contained at the project root
* Execute `terraform init` to initialize the remote backend and download modules
* Create terraform.tfvars file with aws credentials
* ```terraform plan``` shows a preview
* ```terraform apply``` executes infrastructure provisioning

#### Install TFEnv
https://github.com/kamatama41/tfenv
1. `brew install tfenv`

OR

1. Check out tfenv into any path (here is `${HOME}/.tfenv`)

  ```sh
  $ git clone https://github.com/kamatama41/tfenv.git ~/.tfenv
  ```

2. Add `~/.tfenv/bin` to your `$PATH` any way you like

  ```sh
  $ echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
  ```

  OR you can make symlinks for `tfenv/bin/*` scripts into a path that is already added to your `$PATH` (e.g. `/usr/local/bin`) `OSX/Linux Only!`

  ```sh
  ln -s ~/.tfenv/bin/* /usr/local/bin
  ```

#### Create terraform.tfvars
Create a terraform.tfvars file inside the environment folder you want to execute i.e. terraform/environments/operations

These credentials will be used during terraform execution time to create the resources defined in your terraform files
```
access_key="YOURACCESSKEY"
secret_key="YOURSECRETKEY"
```
