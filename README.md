### Concepts
* Control Machine
  * Machine running the Ansible playbook
* Remote Hosts
  * Machines Ansible is logging into to execute the playbook
* Playbooks
  * YAML files describing the end state of remote hosts
* Inventories
  * INI files describing remote hosts
* Modules
  * Ansible ships with a number of modules that can be executed directly on remote hosts
  * Most of your Ansible code will be invoking these modules
* Roles
  * Ansible playbook code that can be re-used (libraries)
  * Ansible galaxy is the community repository for roles
* Variables
  * Variables used within playbooks
* Group Variables
  * Variables defined for specific groups within inventories
* Host Variables
  * Variables defined for specific hosts
* Facts
  * Information that is discovered about remote nodes automatically on every playbook run

### Example terraform.tfvars file
```
access_key="aws access key"
secret_key="aws secret key"
```

### Installation
* Control machine requires Python 2.6 or 2.7
* Remote hosts do not require a client installation
* http://docs.ansible.com/ansible/intro_installation.html
* Can be installed via python using pip
* Can be installed via package manager i.e. yum, apt after adding the PPA repository

### General
* Uses OpenSSH or paramiko to connect to remote hosts on linux
* Ansible changes only deltas when possible
* Uses powershell remote to connect to remote hosts on windows
  * Control machine requires ```pip install "pywinrm>=0.2.2"```
* Requires python 1.5 or higher on remote hosts
* Windows isn’t supported for the control machine
* Remote connections and tasks are executed in parallel
	* Can be disabled using the 'serial' parameter on a particular task
* The # of parallel connections can be changed via the ansible.cfg
* Adding ```--limit <groups/hosts>``` as an argument to an ```ansible-playbook``` command limits which hosts the playbook is executed on
* A playbook can be restarted from where it failed
	* A .retry file is created in your $HOME dir by default

### Text Editor setup with Syntax highlights (Optional)
* Install sublime text

  ```brew cask install sublimetext-3```
  or
  ```choco install -y sublimetext3```
* Install package control
https://packagecontrol.io/installation
* Install plugins ApplySyntax, Ansible, PrettyYaml, SidebarEnhancements
	* cmd + shift + p -> type Package Control: Ins -> type plugin name + enter (repeat for each plugin)

### Inventories
* ini format
* default location Ansible looks for inventory ```/etc/ansible/hosts```
* ```local-host``` is automatically added to the inventory
* At least one host is required other than ```local-host``` or you must run Ansible in local mode
* "behavioral inventory parameters" are a list of configurable parameters for hosts
	* Overrides ansible.cfg
* Can assign variables here but it's messy for large project and not used often
* Can be pointed to a directory with hosts files via -i or the ```hostfile``` param in ansible.cfg
* Hosts can be added at runtime via ```add_host module``` (rarely used)

### ansible.cfg
* Ansible looks for an ansible.cfg file in the following places, in this order:

1. File specified by the ANSIBLE_CONFIG environment variable
2. ./ansible.cfg (ansible.cfg in the current directory)
3. ~/.ansible.cfg (.ansible.cfg in your home directory)
4. /etc/ansible/ansible.cfg

Example.
```
[defaults]
hostfile = hosts
remote_user = ubuntu
private_key_file = ~/.ssh/thiskey.pem
host_key_checking = False
```
### Debugging
* Run ansible commands with -vvvv
* Debug statement ```debug: "msg=asdf"```
* Debug a variable ```debug: var=myvarname```
* Debugs and evaluates template ```debug: msg="{{ lookup('template', 'message.j2') }}"```

### Run Arbitrary Commands
* ```ansible -a <command>```
	* an implicit -m command is added for you
	* add -s for sudo
* Ex. ```ansible example.hostname.com -i hosts -m ping -vvvv```

### Module
* are 'Scripts' that come packaged with Ansible
	* Ex. apt, copy, file, service
* Documentation on modules is available via ```ansible-doc <module name>``` or online http://docs.ansible.com/ansible/modules_by_category.html

### YAML
* Files should start with ```---``` (Ansible doesn't care though)
* Use 2 spaces not tabs
* Comments ```#```
* YAML strings with no variable interpolation don't need to be quoted, even for spaces
* YAML strings with variable interpolation should be quoted
* Boolean ```True```, ```False```, ```yes```, ```no```
* Lists are hyphen delimited ```-``` or inline ```[a,b,c]```
* Dictionaries are ```key: value``` or inline ```{ key: value, key1: value1 }```
* Line folding ```>``` (multi-line strings)

### Playbooks
* Just a YAML dictionary
* List of 'plays', every play requires a set of hosts and a list of tasks to be executed
* Normally used a wrapper describing the order of which things should be run and some configuration
* Use ```ansible-playbook <playbook file>``` to run playbooks

### Play
* List of 'tasks'
* Should be named
* Can define variables
* Set flags for an entire play run like ```sudo: True```

### Tasks
* An action to be performed on host
* Should be named
* References a module and any arguments
* Arguments are treated as a string not a dictionary
	* Ansible does have a task syntax which I prefer
	* Can be used mixed between string and task syntax
* If you see ```action:``` inside tasks (that's a deprecated syntax)
* Can create a tracking file to leverage up-to-date checking using ```creates=``` in a command module task
* List available tasks in a playbook ```ansible-playbook --list-tasks example.yml```

### Variables
* Referenced with ```{{var_name}}```
	* Must use ```_``` .. not camelcase or hyphens
* Can reference any YAML type dictionaries, lists, string, boolean
* Syntax to access dictionary ```{{ db.primary.host }}``` or ```{{ db['primary']['host'] }}```
* Can be defined at the playbook, play, role level
* Can be placed into files and referenced in playbooks with ```vars_files:```
* Group or Hostname vars files are by convention inside ```host_vars``` dir and ```group_vars``` dir
	* Should be in playbook dir or adjacent to inventory file
	* See directory structure link below for more info
* Variables share a namespace
* Get value for env variable ```{{ lookup('env', 'SHELL') }}```

### Templates
* Text file that allows variable interpolation
* Uses Jinja2
* Reference variables with {{}}
* .j2 file extension is convention - not required

### Handlers
* Only runs when 'notified' by a task
* Runs AFTER all tasks have run and only run ONCE
* Used typically for restarting services or servers
* Only runs if task is not up-to-date ie. Changed
	* Sometimes troublesome during development

### Directory Structure
http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout

### Facts
* Operating system, hostname, IP and MAC addresses of all interfaces, etc
* Automatically invoked at ansible startup
* Print all facts ```ansible example.hostname.com -m setup```
	* Can be filtered ```-a 'filter=ansible_eth*'```
* Some modules set additional facts ex. ec2_facts
* Can place custom facts files on host @ ```/etc/ansible/facts.d``` and they will automatically be picked up by Ansible
* Can be set dynamically using ```set_fact```
* Can turn off fact collection for plays that do not require them using ```gather_facts: False```

### Escalated Privleges
* Can be attached at the playbook, play, role, or task level
* Takes a boolean value, default ```false```
* ```sudo_user:``` can be specified to sudo as a specific user
* For Ansible 2.x
  * To escalate privileges ```become: ```
  * To become a different user ```become_user: apache```

### Inventories:Groups
* are identified with this ```[example_group_name]```
* ```[all]``` or ```[*]``` group is automatically added
* Can be nested like this ```[example_groups:children]```
* Hostnames must be unique or aliased
* Supports numeric or alphabetic patterns
```
[web]
    web[1:20].example.com
```
* Can be dynamically created using ```group_by```

### Inventories:Dynamic
* A dynamic inventory script requires support for 2 command line flags
```--host=<hostname>``` for showing host details
```--list``` for listing groups
* ```--host``` should spit out the host output in json format including the 'behavioral variables'
* ```--list``` should spit out the groups in json format
* there is a starter script available called ec2.py from Ansible

### Variables:Advanced
* There are a number of built-in variables like ```hostvars```, ```group_names```, etc
* Can be set from command line ```ansible-playbook example.yml -e token=12345```
* Precedence
1. (Highest) ```ansible-playbook -e var=value```
3. On a host or group, either defined in inventory file or YAML file
4. Facts
5. In defaults/main.yml of a role.

### Iteration
* ```with_items:``` should contain the list to iterate over
* ```{{item}}``` is the variable for iteration
* There are several other iterables ```with_dict```, ```with_lines```, etc
	* http://docs.ansible.com/ansible/playbooks_loops.html

### Tasks:Advanced
* Pass environment variables using ```environment: <dictionary>```
* Conditional tasks using the ```when: <variable or expresion>``` clause

### Variables:Register
* Capture output of a task into a variables
* Output is a dictionary and dependent on the module called
	* Using debug on the variable is a good way to see the keys of the dictionary
* Can ignore errors using ```ignore_errors: True```

### Variables: Encrypted
* ```ansible-vault view``` to open read only
* ```ansible-vault edit``` to edit an encrypted file
* ```ansible-vault create``` to create an encrypted file
* is locked with a passphrase
* launches editor specified in $EDITOR env variable
* ```--ask-vault-pass``` prompts for pw or use a file ```--vault-password-file``` or set ```vault_password_file=``` in ```ansible.cfg```

### Roles
* Simplify complex playbooks - split tasks in multiple files
	* Tasks are reusable
* Default dir for roles is ```roles``` adjacent to playbook file
* ```main.yml``` inside ```roles/<name>/tasks``` is the entry point
* If you think you might want to change the value of a variable in a role, use a default variable. If you don’t want it to change, then use a regular variable.
* Generate role directory structure
	* ```ansible-galaxy init -p playbooks/roles example```
* Role dependencies should be defined in ```roles/<name>/meta/main.yml```

### Tags
* Used to group tasks or roles
* You can specifically call a set of tasks to run this way instead of the whole playbook
* ```ansible-playbook main.yml --tags <tag name>```

### Local Actions
* Run task on control machine
```
- name: wait for ssh server to be running
      local_action: wait_for port=22 host="{{ inventory_hostname }}"
        search_regex=OpenSSH
```