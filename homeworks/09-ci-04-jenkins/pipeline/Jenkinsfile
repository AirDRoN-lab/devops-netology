pipeline {
    agent {
            label 'linux'
    }
    stages {
        stage('git clone') {
            steps {
                git branch: 'main', credentialsId: 'vm2_vagrant_git', url: 'git@github.com:AirDRoN-lab/ansible-vector-role.git'
                }
            }
        stage('install apps') {
            steps {
                sh "pip3 install  'molecule==3.5.2' 'molecule_docker'"
            }
        }
        stage('molecule test') {
            steps {
                sh "molecule --version"
                sh "molecule test -s ubuntu"
            }
        }
    }
}
