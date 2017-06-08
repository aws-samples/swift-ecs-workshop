* **Lab 1: Deploy a Swift web application on Amazon ECS Workshop**
	>*In this lab , you will develop a simple products api using Swift and Vapor, a web framework for Swift, and deployed it on Amazon ECS.*

* **Lab 2: Create a Swift mobile app using Mobile Hub and Amazon Cognito**  

  > *In this lab , you will develop a Swift Mobile Ap using AWS Mobile Hub and Amazon Cognito and integrate it to the API you developed in lab 1 or 2*

* **Lab 3: Build and test mobile app using Amazon Device Farm**  

  > *In this lab you will test the mobile App developed in Lab 3 using Amazon Deveice Farm.*

* **Lab 4: Deploy to Amazon ECS using CodeCommit and CodePipeline**  

  >*In this lab, you will enhance the product api developed in lab 1, and commit it to AWS CodeCommit and then deploy it on Amazon ECS using Code Pipeline and CloudFormation*


## Deploy a Swift web application on Amazon ECS Workshop

### Overview of Workshop Labs

Swift is a popular programming language used to write applications for Apple's iOS, OS X, watchOS, and tvOS platforms. By leveraging Swift with ECS, you can create a homogeneous, scalable application stack.

To deploy a Swift web application we utilize Vapor which is a Web Framework for Swift that works on iOS, macOS, and Ubuntu; and all of the packages that Vapor offers. Vapor is the fast becoming of the most used web framework for Swift.

In this workshop , you will deploy a sample Swift backend api commiting data to Amazon RDS, enhance the API to your needs, develop a mobile app using Amazon Mobile Hub, Amazon Cognito and finally test it using Device Farm.

![](https://s3-us-west-2.amazonaws.com/es-swift-bootcamp/image/swift-ecs-workshop.png)

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
** Please launch in N.Virginia **

Each of the labs in this workshop is an independent section and you may choose to do some or all of them, or in any order that you prefer.


## Lab 1: Deploy a Swift API to Amazon ECS


### Launch the CloudFormation template


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
`git clone https://github.com/awslabs/swift-ecs-workshop`

3. Change directory to swift-ecs-workshop/lab1/swift-product/

4. Modify the **Config/secrets/mysql.json** file host to your Database instance endpoint from the cloudformation output.

5.	Build, tag, and push a Docker image to ECR

	* Still in swift-ecs-workshop/lab1/swift-product/, build a Docker image
		```docker build -t swift-on-ecs-prebuilt --build-arg SWIFT_VERSION=3.0-RELEASE . ```

	* Retrieve the Docker login command
	`aws ecr get-login --region us-east-1`

	* Run the output of the previous command to log into Docker. You might see a warning about a deprecated flag. This should be no cause for concern as long as you see the "Login Succeeded." message.

	*	Tag the image using the `{{TagPreBuiltImage}}` from Cloudformation outputs.

	*	Push the image to the ECS Repository using `{{PushPreBuiltImage}}` from Cloudformation outputs

6. 	 Go to AWS ECS Console, and Create a Task Definition

	*	Task Definition Name: `swift-on-ecs-task`
	*	Ignore Task Role, Network Mode and click the Add Container button.
		*	Container name: `swift`
		*	Image: `{{RepositoryURL}}:latest`. you can find the RepositoryURL from Cloudformation outputs
		*	Maximum memory: 300
		*	Host port: 80
		*	Container port: 8080
		* 	Protocol: `tcp`
		*	Click ‘Add Container’

	*	Click ‘Create’

7.	Create a Service by clicking on the Action's Button -> Create Service

	*	Task Definition: `swift-on-ecs-task:1`
	*	Cluster: You can find the cluster name in CloudFormation, Resources tab (ECSCluster).
	*	Service name: `swift-on-ecs-service`
	*  Number of tasks : 1
	* You can leave the rest as-is and hit the Create Service button.


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

For example, if you are going to run the above with `curl` it would look like this: `curl -H "Content-Type: application/json" -X POST -d '{"name" : "testproduct", "description" : "This is a testproduct", "price" : 20.50, "count" : 5, "image_url_1" : "https://d0.awsstatic.com/Test%20Images/Kate%20Test%20Images/ECS_Header.png", "image_url_2" : "https://d0.awsstatic.com/Test%20Images/Kate%20Test%20Images/ECS_Header.png"}' http://<<YOUR_IP>>/products`

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

## Lab 2: Create a Swift mobile app using Mobile Hub and Amazon Cognito

**Pre-requisites**
1.	Xcode 7 or 8 installed

2.	Apple ID logged in your Xcode

3.	Make sure you can run any sample Swift app on a simulator.


**Part 1 : Creating an app using Mobile Hub with AWS Cognito for User-sign in**

1.	Go to the AWS console by opening http://aws.amazon.com in a web browser, and **verify** that you are in the N. Virginia region at the top right corner of the page.
2.	In the list of service find “Mobile Hub”. Click on Mobile hub.
3.	The welcome page for Mobile hub will show you an option to create a new project. Alternatively, if you have already use Mobile Hub it will show the list of projects that you had created.
4.	Give this project a cool name. You will have to tick the 'Allows AWS Mobile Hub to administer resources on my behalf.' line.
5.	Once you create the project the next page show a cards layout wherein you will see AWS services that can be configured and added to your app.
6.	We want to add a simple login using Facebook to our sample application. We will be using AWS Cognito for this.
7.	Click on User-sign in card.
8.	You should see 4 options with Facebook, Google, SAML and Custom offered as choices. Select Facebook.
9.	If you expand the documentation column using the blue arrow on the right side of the page, it will show you the instructions to enable Facebook login.
10.	Follow the steps to enable a Facebook developer account, to create a Facebook app, and to enable your iOS app to login to Facebook.
11.	Once the Facebook developer account is activated we want to copy the App id of our sample application so that we can use Facebook login in our sample app.
12.	Paste the App id in the AWS Mobile Hub console page where we let off.
13.	 Next on the left hand side menu, click on the “Integrate” option.
14.	The page should show an option for us to “Download the sample app”
15.	Download the app.

**Part 2: Adding more UI and code to the downloaded app to enable listing a product listing.**

1.	Open the downloaded app in Xcode. **DO NOT** agree to convert the project if Xcode prompts you to do so.


2.	Select iPhone 6s simulator as the device target

3.	Run the app.

4.	Once the app is up and running you will find that it has one existing option, which indicates the user sign in process through Cognito.

We want to add another option to the app main page. When clicked, it will show the product listing. We will add the corresponding code to the web service, which will return a JSON data getting serialized to an object and display in this new page.

5.	Download the zip package from [GitHub](https://github.com/awslabs/swift-ecs-workshop/tree/master/lab2/zipforlab2.zip) which contains the three files below:

	ProductListing.storyboard

	ProductListingViewController.swift

	MainViewController.swift

6.	Open Finder and copy ProductListing.storyboard and ProductListingViewController.swift from the unzipped package
 to the sample application you downloaded from Mobile Hub under the following location:

	MobileHub Sample Folder/MySampleApp/MySampleApp/ProductListingViewController.swift

	MobileHub Sample Folder/MySampleApp/MySampleApp/ProductListing.storyboard

7. Overwrite MainViewController.swift by copying it from the unzipped package and pasting it under mobile hub sample app at the following location:

	MobileHub Sample Folder/MySampleApp/MySampleApp/App/MainViewController.swift

8. Go back to Xcode to add files to your project.

	a. In the left pane, make sure you have selected the Project Navigator (folder icon), right click on MySampleApp→App and choose “Add Files to MySampleApp”.

	b. Navigate to the relevant folder and choose ProductListing.storyboard and ProductListingViewController.swift.    

	c. Check “Copy items if needed”.

	d. Click “Add”.

9. Open ProductListingViewController.swift

10. Search for “let url” and replace the first instance of existing URL with the URL for your service that you built in lab 1.

11. Enable the application to allow communication via HTTP
	a. Click the top-level MySampleApp project.

	b. In the center pane, click Info and scroll to App Transport Security Settings

	c. Click on App Transport Security Settings and click the + sign.

	d. Select Allow Arbitrary Loads and change the Boolean value to YES

Reference this screenshot for further detail:
![Allow HTTP Communication](/lab2/allow-arbitrary-loads.png)

12. Save the project.

13. Build the project by clicking on Product \ Build in the menu.

14. In the app, first sign-in using Facebook using the “Sign-in” button on the top right hand corner.

15. Once you are successfully signed in, go back to main page in the app and click on “Access Swift DB”.

## Lab 3: Testing the app on Device Farm

1. Once you have successfully run the app we want to test the app on device farm.
2. First we want to retrieve the .ipa file of the app that we just built. As this process may not be seamless for everyone in the room given that you require an Apple Developer account and Xcode configured to do this we have provided a prebuilt IPA file which is exactly the same app that you build using Mobile Hub and modified in Lab 2.
3. The prebuilt IPA can be found here https://github.com/awslabs/swift-ecs-workshop/tree/master/lab3/MySampleApp.ipa with the name "MySampleApp.ipa". We would recommend using this. If you have your Xcode configured and want to build IPA files by yourself, you can follow the steps in the next optional section (Steps to build IPA) below.
4.	Open aws.amazon.com console.
5.	On the console home page under Mobile Services select Device Farm.
6.	Create a new Project. Give it a name “re:Invent 2016”.
7.	Under project “re:Invent 2016” click on “Create a new Run”.
8.	First we want to upload our iOS app. Click on the Android/Apple logo button.
9.	Next click on the “Upload” button. This will open a Finder window, which will ask for the ipa file. Select our MySampleApp.ipa file.
10.	Next click on “Next step”.
11.	By default the test type selected will be “Built-in: Fuzz”. Click on “Next step”
12.	On the Select devices page it will show the top pool of devices. We will work with this pool. Click on “Next Step”.
13.	On the “Specify device state” page we do not want to change anything. Click on "Next step".
14. On the "Review and start run" page, Click on “Review and start run”.
15.	The tests will run for around 15 mins.
16.	Once the tests are finished you can view the detailed report of the test run.

**(Optional) Steps to build IPA**

1. Make sure you have the following configuration if you are not an apple developer or do not have xcode setup to build apps.

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

2.	This should generate a MySample.app file under Products folder.
3.	Right click on the MySample.app file and select “Show in Finder”.
4.	Create an empty folder and call it “Payload” (case-sensitive).
5.	Copy the MySample.app file in the “Payload” folder.
6.	Archive “Payload” folder and rename the zip file to Sample.ipa
7.	We now have the ipa file which we will upload to AWS Device Farm and run tests against.



## Lab 4: Deploy to Amazon ECS using CodeCommit and CodePipeline

**Note:** Use the Bastion host created in lab1 for connecting to CodeCommit repository below

This lab utilizes the resources provisioned in lab1. Please continue using AWS region us-east-1 (N. Virginia/US Standard)

In this lab, you will create an automated workflow that will provision, configure and orchestrate a pipeline triggering deployment of any changes to your swift package. You will orchestrate all of the changes into a deployment pipeline to achieve continuous delivery using CodePipeline and Jenkins. You can deploy new features and/or fixes and make those available to your users in just minutes, not days or weeks.

**Note:** While you can perform these actions independent, you can also leverage the set up created for Lab1 and continue utilizing existing infrastructure.

#### Step 1: Create a CodeCommit repository and Connect (your Bastion host) with this repository

Follow the instructions below to Create and Connect to an AWS CodeCommit Repository. You may also refer to the instructions at AWS CodeCommit documentation

1.	Go to AWS Console and select CodeCommit. Click **Create New repository** button.
	Enter a unique repository name as swift-product and a description ex. swift-product and click **Create repository**. You will get a URL to your CodeCommit repository similar to below
	<https://git-codecommit.us-east-1.amazonaws.com/v1/repos/swift-product>

2.	You can use https or ssh to connect to your CodeCommit repository. We’ll connect via SSH in this lab. The steps need initial set up for AWS CodeCommit and steps for Linux/MacOS is provided as below. For other platform, refer to this link
	<http://docs.aws.amazon.com/codecommit/latest/userguide/how-to-connect.html>
	* Create a new IAM user at IAM console. (Use your credentials from Lab1). Provide this user Programmatic access.
	* Add the following managed policies for the IAM user (Third square: "Attach existing policies directly").
		> *  AWSCodeCommitFullAccess
		> *  AmazonEC2ContainerRegistryFullAccess
		> *  AmazonEC2ContainerServiceFullAccess
		> *  IAMReadOnlyAccess
		> *  IAMUserSSHKeys

	* With a terminal window and connected via SSH to the Bastion host, type:


			cd $HOME/.ssh
			ssh-keygen


	 When prompted, use a name like lab4codecommit_rsa and you can leave passphrase as blank. Hit enter.


			cat lab4codecommit_rsa.pub


	* Go to IAM, select the user you have created and click on Security Credentials tab.
		* Click Upload SSH Public key button. Copy the contents from file ‘lab4codecommit_rsa.pub’ in the text box and save.

	* Go back to terminal and type

			touch config
			chmod 600 config
			sudo vim config  


	 and paste the following
	 **Note:** Ensure that this is the first entry in the config file


			Host git-codecommit.*.amazonaws.com
			User <SSH_KEY_ID_FROM_IAM>  Value for the SSH key id from the user you created in IAM when you uploaded the public key.
			IdentityFile ~/.ssh/lab4codecommit_rsa

  * Verify your SSH connection. Type the following and confirm that you get a successful response.


				ssh git-codecommit.us-east-1.amazonaws.com


#### Step 2: Commit the Source Code and Configuration files into your CodeCommit repository

1.	On the Bastion host, clone a local copy of CodeCommit repo you created earlier in your home directory.

		cd ~
		git clone ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/swift-product


	This will create a folder as the same name as <your CodeCommit Repo name> in your path where you executed the git clone command.

	Copy the contents of **lab4/swift-products-example** directory into this new folder. The contents provide from `git clone https://github.com/awslabs/swift-ecs-workshop.git`

			cd ~/swift-ecs-workshop/lab4/swift-products-example
			cp -r * ~/swift-product/
			cd  ~/swift-product

2. Change the buildspec.yml file to include your AWS account number.

		<your account number>.dkr.ecr.us-east-1.amazonaws.com/swiftrepo:latest

	You can find your AWS account number on the right hand top corner of your AWS console: Click on your user. A drop-down appears, click on "My Account". It will be the very first information you see on the page that appears.

	Note: Do not change the ECR repo name. We are using a separate one for this stack.

3.	Commit all of the copied contents into your CodeCommit repository.

			git add --all
		 	git commit -m "Initial Commit"
			git push origin master

	***Tip: Verify the file .git/config for remote==”origin” and branch==”master”***



#### Step 3: Deploy the automated Swift package via CloudFormation template.

Pick the template from <https://s3-us-west-2.amazonaws.com/es-swift-bootcamp/master.yaml>.

The stack takes approximately 15 minutes to create all resources.

The template creates a number of AWS resources to facilitate the automated workflow.

> *  **Virtual Private Cloud (VPC)** – A VPC with VPC resources such as: VPCGatewayAttachment, SecurityGroup, SecurityGroupIngress, SecurityGroupEgress, SubnetNetworkAclAssociation, NetworkAclEntry, NetworkAcl, SubnetRouteTableAssociation, Route, RouteTable, InternetGateway, and Subnet
> *  **Auto Scaling Group** – An auto scaling group to scale the underlying EC2 infrastructure in the ECS Cluster. It’s used in conjunction with the Launch Configuration.
> *  **Auto Scaling Launch Configuration** – A launch configuration to scale the underlying EC2 infrastructure in the ECS Cluster. It’s used in conjunction with the Auto Scaling Group.
> *  **CodeBuild** –CodeBuild will build your project using the commands given in buildspec.yml 
> *  **CodePipeline** – CodePipeline describes Continuous Delivery workflow. In particular, it integrates with CodeCommit and Jenkins to run actions every time you commit new code to the CodeCommit repo.
> *  **IAM Instance Profile** – “An instance profile is a container for an IAM role that you can use to pass role information to an EC2 instance when the instance starts.”
> *  **IAM Roles** – Roles that have access to certain AWS resources for the EC2 instances (for ECS), Jenkins and CodePipeline
> *  **ECS Cluster** – “An ECS cluster is a logical grouping of container instances that you can place tasks on.”
> *  **ECS Service** – An ECS service, you can run a specific number of instances of a task definition simultaneously in an ECS cluster
> *  **ECS Task Definition** – A task definition is the core resource within ECS. This is where you define which Docker images to run, CPU/Memory, ports, commands and so on.
> *  **Application Load Balancer** – The ALB provides the endpoint for the application. The ALB dynamically determines which EC2 instance in the cluster is serving the running ECS tasks at any given time.
> *  **RDS MySQL instance** – Contents the product details for the Swift application package

A code change committed to CodeCommit repository will trigger image creation, create a task definition, create the service and run the task in an auto-scaled pool of containers running behind an elastic load balancer.

#### Step 4: Validation.

You can monitor the build process on the UI for the Jenkins server created for you in CloudFormation. Get the public IP address of the Jenkins server from EC2 console and view the Jenkins build progress.
An update to the CloudFormation stack will be triggered once Jenkins server returns a successful result to CodePipeline.

Once the stack update is completed, refer to the output of your CloudFormation and click on ‘AppURL’

You will see a URL similar to:
http://<stackname>-EcsElb-<container>-<image>.us-east-1.elb.amazonaws.com/

You should see the Vapor homepage.
**Congratulations:** Your Swift package is deployed on ECS container automatically.

Check out the product page by adding “/products” to the URL above.


Please verify the RDS endpoint in 	<your code commit repo name>/Config/secrets/mysql.json matches the endpoint of the RDS created.

**TroubleShooting**

Open the following file

		cd ~/swift-product/Config/secrets
		vi mysql.json


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



### Cleanup

* **Reset Steps**
	1.	Scale the service down to zero running tasks.
	2. Delete the ECR Repository
	3.	Delete the CloudFormation stack and re-create it.

* **Removal Steps**
	1.	Bring services to 0 desired tasks.
	2.  Delete the ECS service you created in lab 1.
	3.	Delete the CodePipeline artifact S3 bucket. You will find it in the S3 console and its name looks like "<ACCOUNT NUMBER>-codepipelineartifact".
	4.	Delete the ECR Repository called "swiftrepo" as well as the one you created in lab 1 by using the ECS console.
	5.	Delete the CloudFormation stack.
