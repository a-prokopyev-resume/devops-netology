pipeline {

    agent {
        node {
            label 'agent'
        }
    }

    stages {
        stage('Build') {
            steps {
                dir('09-ci-04-jenkins/src/ansible/roles/role1') {
                    script {
                        def Role1_Jenkinsfile = load 'Jenkinsfile'
                        Role1_Jenkinsfile()
                    }
                }
            }
        }
    }
}
