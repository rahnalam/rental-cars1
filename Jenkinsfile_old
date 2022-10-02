ip_address=""
node(){
stage("Git checkout"){

checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/muraliphani/RentalCars.git']]])
sh "ls -l"

}
  
  stage("Maven Build"){
  sh "mvn install"
  }  
  
  
  
 
 stage("Create ec2 instance"){
  withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSAccess', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
   def directory = "terraform"

     
     dir(directory) {

       sh "terraform init"
	   sh "terraform apply -auto-approve"
	   ip_address = sh(script: "terraform output ec2instance_ip", returnStdout: true).toString().trim()
	   sh "echo ${ip_address}"

     }
     }

}
stage("configure tomcat on ec2"){
    def ansible_home = tool name: 'ansible_home', type: 'org.jenkinsci.plugins.ansible.AnsibleInstallation'
   sh "echo ${ip_address}"
   sh "sed -i 's/<ipaddress>/${ip_address}/g' ansible/inventory"
   sh "cat ansible/inventory"
   sh "cd ansible"
   sh "${ansible_home}/ansible-playbook ansible/tomcat.yml -i ansible/inventory -vvvv"
   //ansiblePlaybook credentialsId: 'ansible-key', disableHostKeyChecking: true, installation: 'ansible_home', inventory: 'ansible/inventory', playbook: 'ansible/tomcat.yml'

   withCredentials([sshUserPrivateKey(credentialsId: 'tomcatpem', keyFileVariable: '', passphraseVariable: '', usernameVariable: '')]) {
   def directory = "ansible"
   dir(directory){
   sh "sed -i 's/<ipaddress>/${ip_address}/g' inventory"
   //sh "${ansible_home}/ansible -m ping all -i ${ip_address} -i inventory"
   sh "${ansible_home}/ansible-playbook tomcat.yml -i inventory"
   }
}
}

 stage("Deploy to tomcat"){
  sh "echo ${ip_address}"
  sshagent(['tomcatpem']) {
    sh "scp -o StrictHostKeyChecking=no target/RentalCars.war ubuntu@${ip_address}:/home/ec2-user/apache-tomcat-9.0.63/webapps"
}
  }
  
  
  stage("sonarqube"){
       scannerHome = tool 'SonarQubeScanner'
       withSonarQubeEnv('sonar') {
            sh "${scannerHome}/bin/sonar-scanner"
        }
       timeout(time: 10, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
  
 }
 
 
  stage("Upload to nexus"){
  nexusArtifactUploader artifacts: [[artifactId: '$BUILD_ID', classifier: '', file: 'target/RentalCars.war', type: 'war']], 
    credentialsId: 'nexusrepologin', groupId: 'prod', nexusUrl: '34.221.193.230:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'devtest1', version: '$BUILD_ID'
  
  }
  
  
}
