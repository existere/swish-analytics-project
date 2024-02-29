# Swish Analytics DevSecOps Assessment

1. Create an image with python2, python3, R, install a set of requirements and upload it to docker hub. 
2. For the previously created image 
   - Share build times
     - [Initial build](https://github.com/existere/swish-analytics-project/actions/runs/8099393750/job/22135027064) time of 12m 1s
   - How would you improve build times? 
     - After implementing a registry cache [the build](https://github.com/existere/swish-analytics-project/actions/runs/8099393750/job/22138074675) was reduced to 5s for the same image
     - Depending on the set of requirements, it might be faster to use a debian/ubuntu based image since most python packages include precompiled binary wheels on pypi, whereas alpine packages (if available) compile from source
     - Build a multi-stage dockerfile and compare the build times to the current dockerfile which uses the alpine native virtual packages, which are delted before final build
     - use a .dockerignore file
3. Scan the recently created container and evaluate the CVEs that it might contain. 
   - Create a report of your findings and follow best practices to remediate the CVE 
     - [report](https://github.com/existere/swish-analytics-project/actions/runs/8101930095/job/22143279617#step:7:24)
   - What would you do to avoid deploying malicious packages? 
     - In this case I could set the image scan step to fail on error before pushing to the registry and/or procution clusters
4. Use the created image to create a kubernetes deployment with a command that will keep the pod running 
5. Expose the deployed resource 
6. Every step mentioned above have to be in a code repository with automated CI/CD 
7. How would you monitor the above deployment? Explain or implement the tools that you would use
   - explanation 



Using kubernetes you need to provide all your employees with a way of launching multiple development environments (different base images, requirements, credentials, others). The following are the basic needs for it: 
1. UI, CI/CD, workflow or other tool that will allow people to select options for: 
   a. Base image 
   b. Packages 
   c. Mem/CPU/GPU requests 
2. Monitor each environment and make sure that: 
    a. Resources request is accurate (requested vs used)
    b. Notify when resources are idle or underutilized 
    c. Downscale when needed (you can assume any rule defined by you to allow this to happen) 
    d. Save data to track people requests/usage and evaluate performance 
3. The cluster needs to automatically handle up/down scaling and have multiple instance groups/taints/tags/others to be chosen from in order to segregate resources usage between teams/resources/projects/others 
4. SFTP, SSH or similar access to the deployed environment is needed so DNS handling automation is required 
5. Some processes that are going to run inside these environments require between 100-250GB of data in memory 
    a. Could you talk about a time when you needed to bring the data to the code, and how you architected this system? the code is pulling data from a source that is then used by the code to complete a process
    b. If you don’t have an example, could you talk through how you would go about architecting this? 
    c. How would you monitor memory usage/errors? 
