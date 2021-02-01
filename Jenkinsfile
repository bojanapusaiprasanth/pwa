pipeline {
    agent any
    tools {
      // These tools configuration is taken from Global tool configuration
      maven 'My maven'
      jdk 'My Java'
    }
    environment {
      OPERATOR = "LebaraPWA"
          PORT = "8084"
    }
    stages {
      stage('Delete Workspace') {
        steps {
          cleanWs()
          sh "rm -rf /etc/ansible/roles/pwa/files/${OPERATOR}/*"
        }
      }
      stage('Git clone') {
        // Used to clone the Git repo to our system
        steps {
          git 'https://github.com/bojanapusaiprasanth/pwa.git'
        }
      }
      stage('compile code') {
        steps {
          sh 'mvn compile'
        }
      }
      stage('Code Review') {
        steps {
          //warnings next generation plugin should be installed
          sh 'mvn -P metrics pmd:pmd'
        }
        post {
          always {
            recordIssues(tools: [acuCobol(pattern: '**/target/pmd.xml', reportEncoding: 'UTF-8')])
          }
        }
      }
      stage('Junit Test') {
        steps {
          // junit realtime test reporter plugin should be installed
          sh 'mvn test'
        }
        post {
          always {
            junit '**/target/surefire-reports/*.xml'
          }
        }
      }
      stage('Metrics Check') {
        steps {
          // cobertura plugin should be installed
          sh 'mvn cobertura:cobertura -Dcobertura.report.format=xml'
        }
        post {
          always {
            cobertura autoUpdateHealth: false,
             autoUpdateStability: false,
              coberturaReportFile: '**/target/site/cobertura/coverage.xml',
               conditionalCoverageTargets: '70, 0, 0',
                failUnhealthy: false,
                 failUnstable: false,
                  lineCoverageTargets: '80, 0, 0',
                   maxNumberOfBuilds: 0,
                    methodCoverageTargets: '80, 0, 0',
                     onlyStable: false,
                      sourceEncoding: 'ASCII',
                       zoomCoverageChart: false
          }
        }
      }
      stage('SonarQube Analysis') {
        steps {
          // sonarqube plugin needs to be installed and should be configured in configure system in Jenkins
          withSonarQubeEnv('mysonarqube') {
            sh 'mvn sonar:sonar'
          }
        }
      }
      stage('Build Package') {
        steps {
          sh 'mvn package'
        }
      }
      stage('Push Artifacts to Nexus Repo') {
        steps {
          // Push artifacts to nexus plugin should be installed
          script {
            def mavenPom = readMavenPom file: 'pom.xml'
            nexusArtifactUploader artifacts: [
                [artifactId: 'pwa',
                 classifier: '',
                  file: 'target/*.jar',
                   type: 'jar'
                   ]
           ],
            credentialsId: 'Nexus',
             groupId: 'pwa',
              nexusUrl: 'nexus.sidhuco.in',
               nexusVersion: 'nexus3',
                protocol: 'http',
                 repository: 'pwa',
                  version: "${mavenPom.version}"
          }
        }
      }
      stage('Copy the files to ansible') {
        steps {
          sh 'cp -rp config.properties /etc/ansible/roles/pwa/files/${OPERATOR}/'
          sh 'cp -rp config_ar.properties /etc/ansible/roles/pwa/files/${OPERATOR}/'
          sh 'cp -rp messages.properties /etc/ansible/roles/pwa/files/${OPERATOR}/'
          sh 'cp -rp messages_ar.properties /etc/ansible/roles/pwa/files/${OPERATOR}/'
          sh 'cp -rp pwa*.jar /etc/ansible/roles/pwa/files/${OPERATOR}/'
        }
      }
       stage('Invoke Ansible playbook') {
         steps {
           // ansible plugin should be installed and global tool configuration also should be done
           ansiblePlaybook disableHostKeyChecking: true,
            extras: 'host=$OPERATOR,OPERATOR=$OPERATOR,PORT=$PORT',
             installation: 'ansible2',
              playbook: 'pwanew.yml',
               tags: 'deployment'
         }
       }
       stage('Run Docker-Compose to start container') {
         input {
           message "Please select YES or NO to proceed with Deployment"
           ok "Yes, We can Proceed"
           submitter "SaiPrasanth"
           parameters {
             string(name: 'PERSON', defaultValue: 'SaiPrasanth', description: 'Please provide name of person who is approving')
           }
         }
         steps {
           sh "docker-compose up -d --build-arg OPERATOR_NAME=${OPERATOR}"
         }
       }
    }
}
