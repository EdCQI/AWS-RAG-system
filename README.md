# **Intelligent document querying application using a RAG system in AWS**
This project uses Amazon Web Services (AWS) to set up an Amazon Bedrock knowledge base (KB) integrated with an Aurora Serverless PostgreSQL database created from pdf documents on heavy mining and construction machinery stored in an Amazon S3 bucket to build an app with python using Streamlit where users can query for specific information about this machinery. 

The project consists of several components:
1. Stack 1 - Terraform configuration for creating:
   - A VPC (Virtual Private Cloud)
   - An Aurora Serverless PostgreSQL cluster
   - An Amazon S3 Bucket to store the heavy machinery documents used for the KB creation
   - Necessary IAM roles and policies
2. Stack 2 - Terraform configuration for creating:
   - An Amazon Bedrock knowledge base
   - Necessary IAM roles and policies
3. A script with a set of SQL queries necessary to prepare the Postgres database for vector storage (aurora_sql.sql)
4. A python script for uploading the pdf files to an Amazon S3 Bucket (upload_s3.py)
5. A python script for implementing the RAG system using an Large Language Model (LLM) from Amazon Bedrock foundational models (bedrock_utils.py)
6. A python script for building and launching a Streamlit app for the user to make queries (app.py)
7. A Screenshots folder with images that show the result of different steps in the deployment process. Read the names for their description (note that the screenshots of the UI are marked with red capital letters indicating the intended categories with which the system should filter out each user prompt).

The goal is to create the RAG application based on a KB created from the heavy machinery private documents that will allow users to ask for specific information in them using natural language in order to get back accurate in-context responses.

**Technologies used**
 * AI & ML: Amazon Bedrock (for LLMs and KB orchestration)
 * Database: Amazon Aurora Serverless (PostgreSQL) with pgvector extension (for vector storage needed for the KB)
 * Cloud storage: Amazon S3 (for documents used in KB creation)
 * AWS SDK: boto3, AWS CLI
 * Infrastructure as Code (IaC): Terraform
 * Application logic: Python 3.10+
 * User Interface: Streamlit


## RAG application deployment steps
Before you start, you need to have installed:
- AWS CLI
- terraform (version 0.12 or later)
- python (3.10 or later)
- pip (python package manager)
- git

Once installed, proceed:
1. Navigate to the folder where you will clone this repository in your local machine
2. Clone the repository: ```git clone this_repository_url``` (use the actual url)
3. Create a new python virtual environment using venv, virtualenv, conda or any other tool of your choice. Using venv: ```python -m venv name_of_env``` ->  ```name_of_env\Scripts\activate```
4. Activate the environment and install boto3 and streamlit: ```pip install boto3 streamlit```
5. If you haven't done it, configure the AWS credentials using AWS CLI (if you are using an AWS federated access, open the AWS console through your access provider to obtain the initial configuration tokens and store them): ```aws configure``` -> enter tokens (region used in this project was *us-east-1* and output was set to *json*). 
6. Navigate to stack1 folder and initialize terraform. This stack includes VPC, Aurora servlerless and S3: ```terraform init```
7. Review and modify the Terraform variables in stack1/main.tf as needed, particularly:
   - AWS region and AZs (Availability Zones)
   - VPC CIDR (Classless Inter-Domain Routing) block
   - Aurora Serverless configuration
   - s3 bucket
8. Deploy the infrastructure: ```terraform apply```  Review the planned changes and type *yes* to confirm.
9. After the Terraform deployment is complete, copy and store the outputs, as you will need them later.
10. Go to AWS console and open "Aurora and RDS" to prepare the Aurora Postgres database for vector storage -> select Query editor -> choose the database instance just created with terraform  -> select *secrets manager ARN* and paste the saved terraform output named *rds_secret_arn* (no quotes)
11. Once open the Query editor, we´ll prepare the database executing the SQL statements in scripts/aurora_sql.sql file. Paste and run one statement at a time in the same order. After this, the database will be ready for vector storage of KB documents chunks that will be created later.
12. Open stack2/main.tf and paste the terraform outputs of step 9 in their corresponding place: *aurora_arn*, *aurora_endpoint*, *rds_secret_arn* (in *aurora_secret_arn*) and *s3_bucket_name* (in *s3_bucket_arn*). Save the changes.
13. Navigate to stack2 folder (this stack includes the Bedrock KB) and deploy the infrastructure: ```terraform init``` ->  ```terraform apply```  Review the planned changes and type *yes* to confirm.
14. After the Terraform deployment is complete, copy and store the outputs (this time there will only be 2 outputs), as you will also need them later.
15. Open scripts/upload_s3.py file and change the variable "bucket_name" for the first terraform output from step 9 called *s3_bucket_name* (only the last part of the string, the one after the ":::"). This will upload the private pdf documents in scripts/spec-sheets folder that will compose the KB to an Amazon S3 bucket.
16. Navigate to scrpits folder and run the file: ```python upload_s3.py```
17. Back in the AWS console, open "Amazon Bedrock" -> select Build / Knowledge Bases -> select created instance -> select Data source -> select the created S3 bucket -> select Sync. This will sync the KB with the S3 bucket documents, i.e. it will create the chunks from the documents for the RAG system and make them available to the LLM.
18. Review the bedrock_utils.py file for any possible final adjustments needed before running the app. This is where the LLM for the RAG system is defined and where boto3 clients interactions with AWS services are implemented. Also, it has a function that filters out malicious user prompts, categorizing all of them and behaving in an appropriate way as a result.
19. Review the app.py file for any possible final adjustments needed in the UI.
20. Navigate to the root folder and run the streamlit app: ```streamlit run app.py```
21. In the shown UI, select any of the LLMs, adjust the temperature and top_p parameters and paste the *knowledge_base_id* from the second terraform outputs in step 14 (select Enter after pasting it. Don't clear it, as it needs to be written there because it is used in every query).
22. Start using the application making different prompts. The system is designed to filter out malicious prompts. Test them reviewing also the printed outputs in the terminal (not the app) to ensure the prompts are being correctly categorized according to the function implemented in bedrock_utils.py and make any changes if needed to improve the system.
23. If applicable or necessary, delete all AWS created resources for this RAG system in the end when you stop using the application (Aurora serverless VPC, database, S3 bucket and KB), as they can affect your AWS budget.


## Troubleshooting
- For database connection issues, check that the security group allows incoming connections on port 5432 from your IP address.
- If S3 uploads fail, verify that your AWS credentials have permission to write to the specified bucket.
- For any Terraform errors, ensure you're using a compatible version and that all module sources are correctly specified.
- For more detailed troubleshooting, refer to the error messages and logs provided by Terraform and the Python scripts.


## References
- https://github.com/udacity/cd13926-Building-Generative-AI-Applications-with-Amazon-Bedrock-and-Python-project-solution.git
