* **Lab 1: Deploy a Swift web application on Amazon ECS Workshop**
	>*In this lab , you will develop a simple products api using Swift and Vapor, a web framework for Swift, and deployed it on Amazon ECS.*

* **Lab 2: Create a Swift mobile app using Mobile Hub and Amazon Cognito**  

  > *In this lab , you will develop a Swift Mobile Ap using AWS Mobile Hub and Amazon Cognito and integrate it to the API you developed in lab 1 or 2*

* **Lab 3: Build and test mobile app using Amazon Device Farm**  

  > *In this lab you will test the mobile App developed in Lab 3 using Amazon Deveice Farm.*

* **Lab 4: Enhance the backend api and deploy to Amazon ECS using CodeCommit and CodePipeline**  

  >*In this lab, you will utilize enahance the product api developed in lab 1, and commit it to AWS CodeCommit and then deploy it on Amazon ECS using Code Pipeline and CloudFormation*


## Deploy a Swift web application on Amazon ECS Workshop

### Overview of Workshop Labs

Swift is a popular programming language used to write applications for Apple's iOS, OS X, watchOS, and tvOS platforms. By leveraging Swift with ECS, you can create a homogeneous, scalable application stack.

To deploy a Swift web application we utilize Vapor which is a Web Framework for Swift that works on iOS, macOS, and Ubuntu; and all of the packages that Vapor offers. Vapor is the fast becoming of the most used web framework for Swift.

In this workshop , you will deploy a sample Swift backend api commiting data to Amazon RDS, enhance the API to your needs, develop a mobile app using Amazon Mobile Hub, Amazon Cognito and finally test it using Device Farm.

At the end of this workshop, you will know how to develop and deploy a complete Swift Stack on AWS.

### Required:

> **Prepare an AWS Account**  
> If you don’t already have an AWS account, create one at http://aws.amazon.com by following the on-screen instructions.
> Use the region selector in the navigation bar to choose the Amazon EC2 region where you want to deploy Swift web application on AWS.

Create a key pair in your preferred region.
You can follow steps here: [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair]()

Also, change the permission on your keypair with the following command.
`chmod 400 <your keypair>`

### Labs
** Please lauch in N.Virginia **

Each of the labs in this workshop is an independent section and you may choose to do some or all of them, or in any order that you prefer.


##Lab 1: Deploy a Swift backend API to Amazon ECS


###Launch the CloudFormation template


1. Deploy the AWS CloudFormation template into your AWS account.
You can change the region by using the region selector in the navigation bar. Change to N.Virginia.


	> The template (quickstart-template) can be found in the lab1/templates folder.
	This stack takes approximately 10 minutes  to create.

2. On the Select Template page, upload the downloaded template, and then choose Next.

3. On the Specify Details page, review the parameters for the template. Enter values for the parameters that require your input. For all other parameters, you can customize the default settings provided by the template. When you finish reviewing and customizing the parameters, choose Next.

4. On the Options page, you can specify tags (key-value pairs) for resources in your stack and set advanced options. When you’re done, choose Next.

5. On the Review page, review and confirm the template settings. Under Capabilities, select the check box to acknowledge that the template will create IAM resources.

6. Choose Create to deploy the stack.
Monitor the status of the stack. When the status is CREATE_COMPLETE, the deployment is complete.

7. You can use the URL displayed in the Outputs tab for the stack to view the resources that were created.

The CloudFormation stack outputs a few commands that you’ll need during the demo. You’ll also need the Cluster IP Address to connect to the application for the final step of the demo

**Configuration**

1. SSH into the Bastion Instance using the
*SSHToBastion* command from the above Cloudformation template

	Please configure awscli using the command
	`aws configure` with your access key and secret for the admin user. Chose `us-east-1` as a default region.

	If you are using a Windows laptop, please the steps listed here: [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html]()

2. Clone the repo provided from *https://github.com/awslabs/swift-ecs-workshop* on the bastion instance using the command
```git clone https://github.com/awslabs/swift-ecs-workshop```

3. Change directory to  swift-ecs-workshop/lab1/swift-product/
Modify the **Config/secrets/mysql.json** file host to your Database instance endpoint from the cloudformation output.

4.	Build, tag, and push a Docker image to ECR

	* Go to the bastion host terminal you ssh'd in Step (1)
	* Build a Docker image
		```docker build -t swift-on-ecs-prebuilt --build-arg SWIFT_VERSION=3.0-RELEASE . ```

	* Retrieve the Docker login command
	`aws ecr get-login --region us-east-1`

	* Run the output of the previous command to log into Docker

	*	Tag the image using the `{{TagPreBuiltImage}}` from Cloudformation outputs.

	*	Push the image to the ECS Repository using `{{PushPreBuiltImage}}` from Cloudformation outputs

5. 	 Go to AWS ECS Console, and Create a Task Definition

	*	Task Definition Name: `swift-on-ecs-task`
	*	Add Container
		*	Image: `{{RepositoryURL}}:latest` . you can find the RepositoryURL from Cloudformation outputs
		*	Maximum memory: 300
		*	Host port: 80
		*	Container port: 8080
		* 	Protocol: `tcp`
		*	Click ‘Add Container’

	*	Click ‘Create’

6.	Create a Service by clicking on the Action's Button -> Create Service

	*	Task Definition: `swift-on-ecs-task:1`
	*	Service name: `swift-on-ecs-service`
	*  Number of tasks : 1


**LAB 1 COMPLETE**

1. Get Container Id, by going to Cluster -> Click on Service -> Click on Task , look under Container Section.

2.  Wait for the service to stabilize, and then connect to the Cluster instance in a browser.
 Open `http://<cluster-instance-ip>/`

>  Output: You should see a Vapor Homepage.

Open a Rest Client and **POST http://cluster:instance:ip/products**

Content-Type = application/json
Request body:

	{
	"name" : "testproduct",
	"description" : "This is a testproduct",
	"price" : 20.50,
	"count" : 5,
	"image_url_1" : "https://d0.awsstatic.com/Test%20Images/Kate%20Test%20Images/ECS_Header.png",
	"image_url_2" : "https://d0.awsstatic.com/Test%20Images/Kate%20Test%20Images/ECS_Header.png"
	}

> **Output**: Response code: 200

3. Run GET **http://cluster:instance:ip/products** from the RESTClient.

**Output** :

 	`[{
	"name" : "testproduct",
	"description" : "This is a testproduct",
	"price" : 20.50,
	"count" : 5,
	"image_url_1" : "https://d0.awsstatic.com/Test%20Images/Kate%20Test%20Images/ECS_Header.png",
	"image_url_2" : "https://d0.awsstatic.com/Test%20Images/Kate%20Test%20Images/ECS_Header.png"
  	}]`

##Lab 2: Create a Swift mobile app using Mobile Hub and Amazon Cognito

**Pre-requisites**
1.	Xcode 7 or 8 installed
2.	Apple ID logged in your Xcode
3.	Make sure you can run any sample Swift app on a simulator.

**Part 1 : Creating an app using Mobile Hub with AWS Cognito for User-sign in **

1.	Go to the AWS console by opening http://aws.amazon.com in a web browser
2.	In the list of service find “Mobile Hub”. Click on Mobile hub.
3.	The welcome page for Mobile hub will show you an option to create a new project. Alternatively, if you have already use Mobile Hub it will show the list of projects that you had created.
4.	Let us name the project “Intent 2016”.
5.	Once you create the project the next page show a cards layout wherein you will see AWS services that can be configured and added to your app.
6.	We want to add a simple login using Facebook to our sample application. We will be using AWS Cognito for this.
7.	Click on User-sign in card.
8.	You should see 3 options with Facebook, Google and Custom offered as choices. Select Facebook.
9.	If you click on the documentation column on the right side it will show you the instructions to enable Facebook developer account.
10.	Follow the steps for enabling Facebook developer account.
11.	Once Facebook developer account is activated we want to copy the App id of our sample application so that we can use Facebook login in our sample app.
12.	Paste the App id in the AWS Mobile Hub console page where we let off.
13.	 Next on the left hand side menu, click on the “Integrate” option.
14.	The page should show an option for us to “Download the sample app”
15.	Download the app.

**Part 2: Adding more UI and code to the downloaded app to enable listing a product listing.**
1.	Open the downloaded app in Xcode.
2.	Select iPhone 6s simulator as the device target
3.	Run the app.
4.	Once the app is up and running you will find that it has one existing option, which indicates the user sign in process through Cognito.
5.	We want to add another option to the app main page. This page when clicked will show up the product listing. We will add the corresponding code to the web service, which will return a JSON data getting serialized to an object and display in this new page.

6.	Download the zip package from https://github.com/awslabs/swift-ecs-workshop/tree/master/lab3/zipforlab3.zip” which contains the three files below:

	ProductListing.storyboard

	ProductListingViewController.swift

	MainViewController.swift

7.	Copy ProductListing.storyboard and ProductListingViewController.swift
 to the sample you built using mobile hub under the following location:

	MobileHub Sample Folder/MySampleApp/MySampleApp/ProductListingViewController.swift

	MobileHub Sample Folder/MySampleApp/MySampleApp/ProductListing.storyboard

8. Overwrite MainViewController.swift by copying it from the unziped package and pasting it under mobile hub sample app at the following location:

	MobileHub Sample Folder/MySampleApp/MySampleApp/App/MainViewController.swift

9. Open Xcode again to add files to your project.

	a. Right click on MySampleApp→App and choose “Add Files to MySampleApp”.

	b. Choose ProductListing.storyboard and ProductListingViewController.swift.    

	c. Check “Copy items if needed”.

	d. Click “Add”.

10. Open ProductListingViewController.swift

11. Search for “let url” and replace the existing URL with the URL for your service that your built in lab 1 and 2.
12. Save the project.

13. Build the project.

14. Run it for iPhone 6s.

15. In the app, first sign in using Facebook using the “Sign-in” button on the top right hand corner.

16. Once you are successfully signed in, go back to main page in the app and click on “Access Swift DB”.

##Lab 3: Testing the app on Device Farm

1.	Once you have successfully run the app we want to test the app on device farm.
2.	First we want to retrieve the .ipa file of the app that we just built.
3.	In Xcode, first build the app for a generic device type by selecting Produtct→Build
4.	Here you may run in to signing issues where Xcode requires you to have a valid provisioning profile and signing identities in order to build an app that can be deployed on devices.  Make sure you have an Apple ID singed in your Xcode.
5.	To resolve any code signing issues, make sure you have the following configuration if you are not an apple developer or do not have xcode setup to build apps.

	a.	Ensure that you have an Apple ID signed in your Xcode.

	b.	Click on MySampleApp project in the project explorer.

	c.	This should open a project and target list on right side of project file explorer window.

	d.	Click on project MySampleApp.

	e.	Click on Build Settings.

	f.	Scroll down to “Code Signing” section.

	g.	Expand Code Signing identity.

	h.	Select Debug → Don’t code sign

	i.	Select Debug → Any iOS SDK → iOS Developer

	j.	Select Release → Don’t code sign

	k.	Select Release → Any iOS SDK → iOS Developer

	l.	Now select MySampleApp Target

	m.	Scroll down to “Code Signing” section

	n.	Expand Code Signing identity.

	o.	Select Debug → iOS Developer

	p.	Select Debug → Any iOS SDK → iOS Developer

	q.	Select Release → iOS Developer

	r.	Select Release → Any iOS SDK → iOS Developer

6.	This should generate a MySample.app file under Products folder.
7.	Right click on the MySample.app file and select “Show in Finder”.
8.	Create an empty folder and call it “Payload” (case-sensitive).
9.	Copy the MySample.app file in the “Payload” folder.
10.	Archive “Payload” folder and rename the zip file to Sample.ipa
11.	We now have the ipa file which we will upload to AWS Device Farm and run tests against.
12.	Open aws.amazon.com console.
13.	On the console home page under Mobile Services select Device Farm.
14.	Create a new Project. Give it a name “Intent 2016”.
15.	Under project “Intent 2016” click on “Create a new Run”.
16.	First we want to upload our iOS app. Click on the Android/Apple logo button.
17.	Next click on the “Upload” button. This will open a Finder window, which will ask for the ipa file. Select our Sample.ipa file.
18.	Next click on “Next step”.


##Lab 4: Enhance the backend api and deploy to Amazon ECS using CodeCommit and CodePipeline


**Noe:**Use the Bastion host created in lab1 for connecting to CodeCommit repository below.
This lab utilizes the resources provisioned in lab1.

Please continue using AWS region us-east-1 (N. Virginia/US Standard)

In this lab, you will create an automated workflow that will provision, configure and orchestrate a pipeline triggering deployment of any changes to your swift package. You will orchestrate all of the changes into a deployment pipeline to achieve continuous delivery using CodePipeline and Jenkins. You can deploy new features and/or fixes and make those available to your users in just minutes, not days or weeks.

**Note:**While you can perform these actions independent, you can leverage the set up created for Lab1 and continue utilizing existing infrastructure.

#### Step 1: Create a CodeCommit repository and Connect (your Bastion host) with this repository

Follow the instructions below to Create and Connect to an AWS CodeCommit Repository. You may also refer to the instructions at AWS CodeCommit documentation

1.	Go to AWS Console and select CodeCommit. Click “Create New repository” button.  Enter a unique repository name and a description ex. swift-product and click “Create repository”.
https://git-codecommit.us-east-1.amazonaws.com/v1/repos/swift-Product

2.	You can use https or ssh to connect to your CodeCommit repository. We’ll connect via SSH in this lab. The steps need initial set up for AWS CodeCommit and steps for Linux/MacOS is provided as below. For other platform, refer to this link
	* Create a new IAM user at IAM console. (Use your credentials from Lab1)
	* Add the following managed policies for the IAM user. 	
		WSCodeCommitFullAccess
		AmazonEC2ContainerRegistryFullAccess
		AmazonEC2ContainerServiceFullAccess
		IAMReadOnlyAccess
		IAMUserSSHKeys

	* On the Bastion host, open a terminal window on Bastion host and type
		* cd $HOME/.ssh
		* ssh-keygen
			When prompted, use a name like lab2codecommit_rsa and you can leave passphrase as blank. Hit enter.
		* cat lab2codecommit_rsa.pub

	* Go to IAM, select the user you have created and click on Security Credentials tab.
		* Click Upload SSH Public key button. Copy the contents from file ‘lab2codecommit_rsa.pub’ in the text box and save.

	* Go back to terminal and type
		* touch config
		* chmod 600 config
		*	sudo vim config  and paste the following
		*(Note: Ensure that this is the first entry in the config file)*

>          Host git-codecommit.*.amazonaws.com   
>          User <SSH_KEY_ID_FROM_IAM>  Value for the SSH key id from Step c above
>          IdentityFile ~/.ssh/lab2codecommit_rsa

  * Verify your SSH connection. Type the following and confirm that you get a successful response.
> ssh git-codecommit.us-east-1.amazonaws.com

#### Step 2: Commit the Source Code and Configuration files into your Codecommit repository

1.	On the Bastion host, clone a local copy of CodeCommt repo you created earlier in your home directory.
git clone ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/swift-product
This will create a folder “swift-product” in your path where you executed the git clone command.

Copy the contents of lab2/swift-products-example/ directory into this new folder. The contents provide from git clone ssh://git.amazon.com/pkg/Amazon-ecs-swift-workshop
~/lab2/swift-products-example$ cp -r * ~/swift-product/

2.	Commit all of the copied contents into your CodeCommit repository.
git add --all
	 git commit -m "Initial Commit"
git push origin master	-- Tip: Verify the file .git/config for remote==”origin” and branch==”master”				

You are using this CodeCommit repository to store you swift application code along with docker configuration files.  In Lab1, you have built a docker image and pushed the image to ECS.

#### Step 3: Deploy the automated Swift package via CloudFormation template.

Pick the template from https://s3.amazonaws.com/ecs-swift-bootcamp/swift-on-ecs-CDV1.json.
Template is also provided at
https://code.amazon.com/packages/Amazon-ecs-swift-workshop/trees/mainline/--/lab2/templates

The template accepts the following parameters:

AppName
ecs-swift-app <- Name of your application
DesiredCapacity
1 <- Provide appropriate desired capacity
ECSCFNURL
https://s3.amazonaws.com/ecs-swift-bootcamp/swift-on-ecs-CD.json <- S3 link to this cloudformation template
ECSRepoName
ecs-swift-bootcamp-ecr-repo <- Name of ECR repo where ECS image is stored
ImageTag
latest <- Image tag
InstanceType
t2.micro
KeyName
xxKeyPair <- Key pair name for SSH access
MaxSize
1 <-  Desired max size
RepositoryBranch
master
RepositoryName
swift-Product <- Name of the CodeCommit repository
SSHLocation
0.0.0.0/0
YourIP
0.0.0.0/0 <- Provide your public IP

The stack takes approximately 15 minutes to create all resources.

The template creates a number of AWS resources to facilitate the automated workflow.

•	Virtual Private Cloud (VPC) – A VPC with VPC resources such as: VPCGatewayAttachment, SecurityGroup, SecurityGroupIngress, SecurityGroupEgress, SubnetNetworkAclAssociation, NetworkAclEntry, NetworkAcl, SubnetRouteTableAssociation, Route, RouteTable, InternetGateway, and Subnet
•	Auto Scaling Group – An auto scaling group to scale the underlying EC2 infrastructure in the ECS Cluster. It’s used in conjunction with the Launch Configuration.
•	Auto Scaling Launch Configuration – A launch configuration to scale the underlying EC2 infrastructure in the ECS Cluster. It’s used in conjunction with the Auto Scaling Group.
•	Jenkins –Jenkins to execute the actions that we defined in CodePipeline. For example, a bash script that updates the CloudFormation stack when an ECS Service is updated. This action is orchestrated via CodePipeline and then executed on the Jenkins server on one of its configured jobs. 
•	CodePipeline – CodePipeline describes Continuous Delivery workflow. In particular, it integrates with CodeCommit and Jenkins to run actions every time you commit new code to the CodeCommit repo.
•	IAM Instance Profile – “An instance profile is a container for an IAM role that you can use to pass role information to an EC2 instance when the instance starts.”
•	IAM Roles – Roles that have access to certain AWS resources for the EC2 instances (for ECS), Jenkins and CodePipeline
•	ECS Cluster – “An ECS cluster is a logical grouping of container instances that you can place tasks on.”
•	ECS Service – An ECS service, you can run a specific number of instances of a task definition simultaneously in an ECS cluster
•	ECS Task Definition – A task definition is the core resource within ECS. This is where you define which Docker images to run, CPU/Memory, ports, commands and so on.
•	Elastic Load Balancer – The ELB provides the endpoint for the application. The ELB dynamically determines which EC2 instance in the cluster is serving the running ECS tasks at any given time.
•	RDS MySQL instance – Contents the product details for the Swift application package

A code change committed to CodeCommit repository will trigger image creation, create a task definition, create the service and run the task in an auto-scaled pool of containers running behind an elastic load balancer.

#### Step 4: Configure your swift package to connect with RDS containing product data.
Open the following file
	~/swift-product/Config/secrets$ cat mysql.json
and update host parameter with RDS endpoint that has been created for you in CloudFormation template ( Check RDS Console for endpoint)
	{
  "host": "<Your RDS endpoint here, do not include port number>",
  "user": "admin",
  "password": "password",
  "database": "testDB",
  "port": "3306",
  "encoding": "utf8"
}

Commit the changes to your CodeCommit repo
	git add --all
  	git status
  	git commit -m "db change"
    git push origin master

Once the changes are checked in, verify that your CodePipeline is executing, creating a new Docker image and deploying on ECS.

#### Step 5: Validation.

You can monitor the build process on the UI for the Jenkis server created for you in CloudFormation. Get the public IP address of the Jenkins server from EC2 console and view the Jenkins build progress.
An update to the CloudFormation stack will be triggered once Jenkins server returns a successful result to CodePipeline.

Once the stack update is completed, refer to the output of your CloudFormation and click on ‘AppURL’


You will see a URL similar to:
http://<stackname>-EcsElb-<container>-<image>.us-east-1.elb.amazonaws.com/

You should see the Vapor homepage.
Congratulations: Your Swift package is deployed on ECS container automatically.

Check out the product page by adding “/products” to the URL above.



###Cleanup

* **Reset Steps**
	1.	Scale the service down to zero running tasks.
	2.	Delete the CloudFormation stack and re-create it.

* **Removal Steps**
	1.	Scale the service down to zero running tasks.
	2.	Delete the CloudFormation stack.



## Appendix

> *Add additional idea for customers to take this further*
