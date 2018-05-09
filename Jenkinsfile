pipeline {
  agent any

  parameters {
    string(defaultValue: "test", description: "build type", name: "type")
  }

  stages {
    stage('prepare') {
      steps {
        echo "build type: ${params.type}"
        sh "env"
      }
    }

    stage('test') {
      when {
        expression {
          return params.type == "test"
        }
      }
      steps {
        sh 'fastlane ios test'
      }
    }

  }
}
